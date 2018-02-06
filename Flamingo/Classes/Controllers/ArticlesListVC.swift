//
//  ViewController.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 10/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import HNScraper
import SDWebImage
import SafariServices
import Moya

class ArticleListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate, ArticleDefaultCellDelegate {
    
    static let HeaderHeight: CGFloat = UIScreen.main.bounds.height.goldenRatio.short
    static let CutHeight: CGFloat = 38
    static let DeltaBlur: CGFloat = -250
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var headerImageView : UIImageView!
    @IBOutlet var headerViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var refreshImageView : UIImageView!
    @IBOutlet var tableView : UITableView!
    
    let maskLayer = CAShapeLayer()
    var animator: UIViewPropertyAnimator?
    var linkForMore : String?
    var posts = [HNPost]()
    var postPreviews = [String : Preview]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Header
        self.title = ""
        self.headerView.layer.mask = self.maskLayer
        
        // TableView
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.alpha = 0
        self.tableView.tableFooterView = UIView()
        let top = ArticleListVC.HeaderHeight - ArticleListVC.CutHeight
        
        let bottomInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        self.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottomInset, 0)
        
        // Events
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetBlur),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        
        self.selectRefreh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.resetBlur()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedRow = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: self.headerView.bounds.maxY - ArticleListVC.CutHeight))
        path.addLine(to: CGPoint(x: self.headerView.bounds.maxX, y: self.headerView.bounds.maxY))
        path.addLine(to: CGPoint(x: self.headerView.bounds.maxX, y: 0))
        path.close()
        self.maskLayer.path = path.cgPath
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Logic
    
    @IBAction func selectRefreh() {
        self.linkForMore = nil
        self.headerImageView.image = nil
        
        self.tableView.setContentOffset(CGPoint(x:0, y:-self.tableView.contentInset.top), animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.35, options: .allowAnimatedContent, animations: {
            self.tableView.alpha = 0
            self.refreshImageView.alpha = 1
        })
        self.requestNextPage()
        self.animateLoading()
    }
    
    func animateLoading() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowAnimatedContent, animations: {
            self.refreshImageView.transform = self.refreshImageView.transform.rotated(by: CGFloat.pi * 0.3)
            self.refreshImageView.alpha = 1
        }, completion: { _ in
            if self.headerImageView.image == nil {
                self.animateLoading()
            }
        })
    }
    
    @objc func resetBlur() {
        self.effectView.effect = nil
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear){
            self.effectView.effect = UIBlurEffect(style: .regular)
        }
    }
    
    @objc func willResignActive() {
        animator?.stopAnimation(true)
    }
    
    // MARK: - Networking
    
    func requestNextPage() {
        if let linkForMore = linkForMore {
            HNScraper.shared.getMoreItems(linkForMore: linkForMore) { (posts, linkForMore, error) in
                self.addPosts(posts, linkForMore: linkForMore)
            }
        } else {
            HNScraper.shared.getPostsList(page: .front) { (posts, linkForMore, error) in
                self.createFeed(posts, linkForMore: linkForMore)
            }
        }
    }
    
    func createFeed(_ posts: [HNPost], linkForMore: String?) {
        self.linkForMore = linkForMore
        self.posts = posts
        self.loadPreviews()
    }
    
    func addPosts(_ posts: [HNPost], linkForMore: String?) {
        self.linkForMore = linkForMore
        self.posts.append(contentsOf: posts)
        self.tableView.reloadData()
    }
    
    func loadPreviews() {
        let provider = MoyaProvider<Mercury>()
        for post in posts {
            guard let url = post.url else { continue }
            provider.request(Mercury.parser(url: url.absoluteString)) { (result) in
                if case .success(let response) = result {
                    let preview = try? response.map(to: Preview.self)
                    self.postPreviews[post.id] = preview
                    self.downloadImage(urlString: preview?.lead_image_url, post: post)
                }
            }
        }
    }
    
    func downloadImage(urlString: String?, post: HNPost) {
        
        guard   let urlString = urlString,
                !urlString.contains("ycombinator"), // I don't like those
                let url = URL(string:urlString) else {
                return
        }
        
        SDWebImageDownloader.shared().downloadImage(with: url, options: [.allowInvalidSSLCertificates], progress: nil) { (image, _, _, _) in
            
            guard self.headerImageView.image == nil else { return}
            
            // Check for a good enough image quality
            if  let image = image,
                image.size.width >= 750 {
                
                guard let oldIndex = (self.posts.index{$0 === post}) else { return }
                SDWebImageDownloader.shared().cancelAllDownloads()
                
                if oldIndex != 0 {
                    self.posts.rearrange(from: oldIndex, to: 0)
                }
                
                self.tableView.reloadData()
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 1
                    self.refreshImageView.alpha = 0
                    self.headerImageView.image = image.blend(image: R.image.color_gradient()!, with: .hardLight)
                })
            }
        }
    }
    
    func showArticle(for url: URL?) {
        if let url = url {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            config.barCollapsingEnabled = true
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - ArticleDefaultCellDelegate
    
    func didSelectComments(post: FlamingoPost, cell: ArticleDefaultCell) {
        let commentsController = R.storyboard.main.articleCommentsVC()!
        commentsController.post = post
        self.navigationController?.pushViewController(commentsController, animated: true)
        
        if let ip = self.tableView.indexPath(for: cell) {
            self.tableView.selectRow(at: ip, animated: true, scrollPosition: .none)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let contentOffset = self.tableView.contentOffset.y + self.tableView.contentInset.top
        
        // Header image bounce & blur
        headerViewHeightConstraint.constant = max(ArticleListVC.HeaderHeight - contentOffset, 0)
        self.view.layoutIfNeeded()
        
        let startOffset = ArticleListVC.DeltaBlur * 0.1
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
        let percent = (contentOffset - startOffset + topInset) / ArticleListVC.DeltaBlur
        animator?.fractionComplete = (contentOffset < startOffset) ? percent : 0
        
        // Refresh button
        if self.headerImageView.image != nil {
            if contentOffset < startOffset {
                refreshImageView.alpha =  percent * 1.5
                refreshImageView.transform =  CGAffineTransform(rotationAngle: refreshImageView.alpha * CGFloat.pi * -0.5)
            } else {
                refreshImageView.alpha = 0
                refreshImageView.transform =  CGAffineTransform.identity
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffset = self.tableView.contentOffset.y + self.tableView.contentInset.top
        if contentOffset < ArticleListVC.DeltaBlur * 0.4 {
            self.selectRefreh()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post: HNPost = self.posts[indexPath.row]
        let prev: Preview? = self.postPreviews[post.id]
        
        let fpost = FlamingoPost(hnPost: post, preview: prev, row: indexPath.row)
        let cell : ArticleDefaultCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleDefaultCell,
                                                 for: indexPath)!
        cell.setPost(fpost)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = self.posts[indexPath.row]
        self.showArticle(for: post.url)
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
       controller.dismiss(animated: true, completion: nil)
    }
}
