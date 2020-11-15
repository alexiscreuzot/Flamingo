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
import RealmSwift
import ReadabilityKit

@objc class ArticleListVC: FluidController, UITableViewDataSource, ArticleDefaultCellDelegate {
    
    enum State {
        case loading
        case error(_ error: Error)
        case loaded(headerImage: UIImage)
    }
    
    static let HeaderHeight: CGFloat = UIScreen.main.bounds.height.goldenRatio.short
    static let CutHeight: CGFloat = 38
    static let DeltaBlur: CGFloat = -250
    
    @IBOutlet var statusBarTopConstraint : NSLayoutConstraint!
    @IBOutlet var statusBarEffectView: UIVisualEffectView!
    
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var headerTitleLabel : UILabel!
    @IBOutlet var headerImageView : UIImageView!
    @IBOutlet var headerViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var refreshImageView : UIImageView!
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var stateLabel : UILabel!
    @IBOutlet var refreshButton : UIButton!
    
    let realm = try! Realm()
    let maskLayer = CAShapeLayer()
    
    var pageType: HNScraper.PostListPageName = .front
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return CustomPreferences.colorTheme.statusBarStyle
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Header
        self.headerTitleLabel.text = self.title
        self.headerView.layer.mask = self.maskLayer
        let blend = (self.pageType == .front) ? R.image.color_gradient()! : R.image.color_gradient_blue()!
        self.headerImageView.image = blend
        
        // TableView
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.alpha = 0
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        let top = ArticleListVC.HeaderHeight - ArticleListVC.CutHeight
        
        self.stateLabel.text = nil
        self.stateLabel.textColor = UIColor.lightGray
        self.refreshButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.refreshButton.alpha = 0
        self.refreshButton.layer.borderWidth = 1
        self.refreshButton.layer.borderColor = UIColor.lightGray.cgColor
        self.refreshButton.layer.cornerRadius = 5
        
        let bottomInset: CGFloat = self.view.safeAreaInsets.bottom
        self.tableView.contentInset = UIEdgeInsets.init(top: top, left: 0, bottom: bottomInset, right: 0)
        
        // Events
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetBlur),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        
        
        if CommandLine.arguments.contains("screenshots") {
            self.effectView.isHidden = true
            self.updateUI()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateUI()
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

        // Refresh if state not loaded
        switch currentState {
        case .loaded(_):
            break
        default:
            self.selectRefresh()
            break
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
            commentsController.fromPageType = self.pageType
            commentsController.post = self.selectedPost
        }
    }
    
    // MARK: - Logic
    
    func updateUI() {
        switch currentState {
        case .loading :
            //            self.tableView.setContentOffset(CGPoint(x:0, y:-self.tableView.contentInset.top), animated: true)
            self.tableView.alpha = 0
            self.stateLabel.text = nil
            self.refreshButton.alpha = 0
            self.animateLoading()
            break
        case .error(let error) :
            self.tableView.alpha = 0
            self.stateLabel.text = error.localizedDescription
            self.refreshImageView.alpha = 0
            self.refreshButton.alpha = 1
            break
        case .loaded(let image) :
            self.tableView.reloadData()
            self.tableView.alpha = 1
            self.stateLabel.text = nil
            self.refreshButton.alpha = 0
            self.refreshImageView.alpha = 0
            
            let blend = (self.pageType == .front) ? R.image.color_gradient()! : R.image.color_gradient_blue()!
            
            if self.traitCollection.userInterfaceStyle == .dark {
                self.headerImageView.image = image.blend(image: blend, with: .multiply)
            } else {
                self.headerImageView.image = image.blend(image: blend, with: .hardLight)
            }
            
            break
        }
    }
    
    func animateLoading() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowAnimatedContent, animations: {
            self.refreshImageView.transform = self.refreshImageView.transform.rotated(by: CGFloat.pi * 0.3)
            self.refreshImageView.alpha = 1
        }, completion: { _ in
            switch self.currentState {
            case .loading :
                self.animateLoading()
            default:
                break
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
        
        guard CustomPreferences.hasSetSources else {
            self.currentState = .error(FlamingoError.sourcesNotConfigured.error)
            return
        }
        
        self.linkForMore = nil
        self.headerImageView.image = nil
        self.requestNextPage()
        self.currentState = .loading
    }
    
    // MARK: - Networking
    
    func addSourceFromPosts(_ posts: [HNPost]) {
        let newSources: [Source] = posts.compactMap {
            guard !$0.urlDomain.isEmpty else { return nil }
            return Source(domain: $0.urlDomain, activated:true)
        }
        
        try! realm.write() {
            realm.add(newSources, update: .all)
        }
    }
    
    func requestNextPage() {
        if let linkForMore = linkForMore {
            HNScraper.shared.getMoreItems(linkForMore: linkForMore) { (posts, linkForMore, error) in
                if let error = error {
                    self.currentState = .error(error)
                    return
                }
                
                let filteredPosts = posts.filter({ post -> Bool in
                    return Source.isAllowed(domain: post.urlDomain)
                })
                
                self.addSourceFromPosts(filteredPosts)
                self.addPosts(filteredPosts, linkForMore: linkForMore)
            }
        } else {
            HNScraper.shared.getPostsList(page: self.pageType) { (posts, linkForMore, error) in
                if let error = error {
                    self.currentState = .error(error)
                    return
                }
                
                let filteredPosts = posts.filter({ post -> Bool in
                    return Source.isAllowed(domain: post.urlDomain)
                })
                
                if filteredPosts.count == 0 {
                    self.currentState = .error(FlamingoError.nothingToShow.error)
                    return
                }
                
                self.addSourceFromPosts(filteredPosts)
                self.createFeed(filteredPosts, linkForMore: linkForMore)
            }
        }
    }
    
    func createFeed(_ posts: [HNPost], linkForMore: String?) {
        self.linkForMore = linkForMore
        self.posts = posts.filter({ post -> Bool in
            return Source.isAllowed(domain: post.urlDomain)
        })
        self.loadPreviews()
    }
    
    func addPosts(_ posts: [HNPost], linkForMore: String?) {
        self.linkForMore = linkForMore
        let addedPosts = posts.filter({ post -> Bool in
            return Source.isAllowed(domain: post.urlDomain)
        })
        self.posts.append(contentsOf: addedPosts)
        self.tableView.reloadData()
    }
    
    func loadPreviews() {
        for post in posts {
            guard let url = post.url else { continue }
            
            Readability.parse(url: url, completion: { data in
                guard let data = data else { return }
                
                let preview = Preview.init(data: data)
                self.postPreviews[post.id] = preview
                
                if  let urlString = preview.lead_image_url,
                    !urlString.contains("ycombinator"), // Don't like those
                    let url = URL(string:urlString) {
                    self.imageQueue.insert(url)
                    self.downloadImage(url, post: post)
                }
            })
        }
    }
    
    func downloadImage(_ url: URL, post: HNPost) {
        
        SDWebImageDownloader.shared.downloadImage(with: url, options: [.allowInvalidSSLCertificates], progress: nil) { (image, _, _, _) in
            
            guard self.headerImageView.image == nil else {
                return
            }
            
            // Check for a good enough image quality
            if  let image = image,
                image.size.width >= 750 {
                
                guard let oldIndex = (self.posts.firstIndex{$0 === post}) else { return }
                SDWebImageDownloader.shared.cancelAllDownloads()
                
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
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset = self.tableView.contentOffset.y + self.tableView.contentInset.top
        
        // Header image bounce & blur
        headerViewHeightConstraint.constant = max(ArticleListVC.HeaderHeight - contentOffset, 0)
        self.view.layoutIfNeeded()
        
        let startOffset = ArticleListVC.DeltaBlur * 0.1
        
        let topInset: CGFloat = self.view.safeAreaInsets.top
        let percent = (contentOffset - startOffset + topInset) / ArticleListVC.DeltaBlur
        animator?.fractionComplete = (contentOffset < startOffset) ? percent : 0
        
         let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        statusBarTopConstraint.constant = (headerViewHeightConstraint.constant - ArticleListVC.CutHeight <= 60)
            ? 0
            : height
        
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
