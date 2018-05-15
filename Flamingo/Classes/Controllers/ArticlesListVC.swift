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

class ArticleListVC: FluidController, UITableViewDataSource, ArticleDefaultCellDelegate {
    
    enum State {
        case loading
        case error(message: String)
        case loaded(headerImage: UIImage)
    }
    
    static let HeaderHeight: CGFloat = UIScreen.main.bounds.height.goldenRatio.short
    static let CutHeight: CGFloat = 38
    static let DeltaBlur: CGFloat = -250
    
    @IBOutlet var statusBarTopConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var headerImageView : UIImageView!
    @IBOutlet var headerViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var refreshImageView : UIImageView!
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var stateLabel : UILabel!
    @IBOutlet var refreshButton : UIButton!
    
    let maskLayer = CAShapeLayer()
    var animator: UIViewPropertyAnimator?
    var linkForMore : String?
    var posts = [HNPost]()
    var postPreviews = [String : Preview]()
    var imageQueue = Set<URL>()
    
    var selectedPost : FlamingoPost?
    var popupPosition : CGPoint?
    
    var currentState : State = .loading {
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.updateUI()
            }
        }
    }
    
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
        
        self.stateLabel.text = nil
        self.refreshButton.alpha = 0
        self.refreshButton.layer.borderWidth = 1
        self.refreshButton.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.refreshButton.layer.cornerRadius = 5
        
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
        
        self.selectRefresh()
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
        
        let path = UIBezierPath.triangleMaskPath(rect: self.headerView.bounds,
                                                 type: .left(height:  ArticleListVC.CutHeight))
        self.maskLayer.path = path.cgPath
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentsController = segue.destination as? ArticleCommentsVC {
            commentsController.post = self.selectedPost
        } else if let popupController = segue.destination as? DeepPressPopupVC {
            self.definesPresentationContext = true
            popupController.modalPresentationStyle = .overCurrentContext
            popupController.modalTransitionStyle = .crossDissolve
            popupController.post = self.selectedPost
            popupController.position = self.popupPosition
            popupController.onShare = {
                popupController.dismiss(animated: true, completion: {
                    if let link = self.selectedPost?.hnPost.url {
                        UIApplication.shared.open(link, options: [:], completionHandler: nil)
                    }
                })
            }
            popupController.onOpenInSafari = {
                popupController.dismiss(animated: true, completion: {
                    if  var post = self.selectedPost,
                        let link = post.hnPost.url {
                            post.isRead = true
                            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
                            self.present(activityVC, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    // MARK: - Logic
    
    func updateUI() {
        switch currentState {
        case .loading :
            self.tableView.setContentOffset(CGPoint(x:0, y:-self.tableView.contentInset.top), animated: true)
            self.tableView.alpha = 0
            self.stateLabel.text = nil
            self.refreshButton.alpha = 0
            self.animateLoading()
            break
        case .error(let message) :
            self.tableView.alpha = 0
            self.stateLabel.text = message
            self.refreshImageView.alpha = 0
            self.refreshButton.alpha = 1
            break
        case .loaded(let image) :
            self.tableView.reloadData()
            self.tableView.alpha = 1
            self.stateLabel.text = nil
            self.refreshButton.alpha = 0
            self.refreshImageView.alpha = 0
            self.headerImageView.image = image.blend(image: R.image.color_gradient()!, with: .hardLight)
            break
        }
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
    
    // MARK: - Actions
    
    @IBAction func selectRefresh() {
        self.linkForMore = nil
        self.headerImageView.image = nil
        self.requestNextPage()
        self.currentState = .loading
    }
    
    // MARK: - Networking
    
    func requestNextPage() {
        if let linkForMore = linkForMore {
            HNScraper.shared.getMoreItems(linkForMore: linkForMore) { (posts, linkForMore, error) in
                if let error = error {
                    self.currentState = .error(message: error.localizedDescription)
                    return
                }
                self.addPosts(posts, linkForMore: linkForMore)
                
            }
        } else {
            HNScraper.shared.getPostsList(page: .front) { (posts, linkForMore, error) in
                if let error = error {
                    self.currentState = .error(message: error.localizedDescription)
                    return
                }
                if posts.count == 0{
                    self.currentState = .error(message: i18n.commonNothingToShow())
                    return
                }
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
                    
                    if  let urlString = preview?.lead_image_url,
                        !urlString.contains("ycombinator"), // Don't like those
                        let url = URL(string:urlString) {
                            self.imageQueue.insert(url)
                            self.downloadImage(url, post: post)
                    }
                }
            }
        }
    }
    
    func downloadImage(_ url: URL, post: HNPost) {
        
        SDWebImageDownloader.shared().downloadImage(with: url, options: [.allowInvalidSSLCertificates], progress: nil) { (image, _, _, _) in
            
            guard self.headerImageView.image == nil else {
                return
            }
            
            // Check for a good enough image quality
            if  let image = image,
                image.size.width >= 750 {
                
                guard let oldIndex = (self.posts.index{$0 === post}) else { return }
                SDWebImageDownloader.shared().cancelAllDownloads()
                
                if oldIndex != 0 {
                    self.posts.rearrange(from: oldIndex, to: 0)
                }
                
                self.currentState = .loaded(headerImage: image)
            } else {
                self.imageQueue.remove(url)
            }
            
            // In case there isn't anything left to load
            if self.imageQueue.count == 0 {
                self.currentState = .loaded(headerImage: R.image.flamingoBack()!)
            }
        }
    }
    
    // MARK: - ArticleDefaultCellDelegate
    
    func articleCell(_ cell: ArticleDefaultCell, didSelect post: FlamingoPost) {
        self.selectedPost = post
        if let ip = self.tableView.indexPath(for: cell) {
            self.tableView.selectRow(at: ip, animated: true, scrollPosition: .none)
        }
        self.performSegue(withIdentifier: R.segue.articleListVC.comments, sender: self)
    }
    
    func articleCell(_ cell: ArticleDefaultCell, didSelectDeepActions post: FlamingoPost, position: CGPoint) {
        self.selectedPost = post
        self.popupPosition = self.view.convert(position, from: cell.contentView)
        self.performSegue(withIdentifier: R.segue.articleListVC.popup, sender: self)
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
        
        statusBarTopConstraint.constant = (headerViewHeightConstraint.constant - ArticleListVC.CutHeight <= 0)
        ? 0
        : UIApplication.shared.statusBarFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        
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
            self.selectRefresh()
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
        post.isRead = true
        self.showURL(post.url)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
