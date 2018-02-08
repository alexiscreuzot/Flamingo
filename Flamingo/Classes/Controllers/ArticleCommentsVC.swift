//
//  ArticleCommentsVC.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 05/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit
import HNScraper
import SDWebImage
import SafariServices

class ArticleCommentsVC : UIViewController, UITableViewDataSource, UITableViewDelegate, CommentCellDelegate {
    
    enum State {
        case loading
        case error(message: String)
        case loaded
    }

    @IBOutlet var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var loaderView: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var footLabel: UILabel!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var stateLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    let maskLayer = CAShapeLayer()
    var post : FlamingoPost!
    var currentState : State = .loading {
        didSet {
            UIView.animate(withDuration: 0.4) {
               self.updateUI()
            }
        }
    }
    var comments = [HNComment]()
    var collapsingIds = Set<String>()
    var collapsedIds = Set<String>()
    var filteredComments : [HNComment] {
        return self.comments.filter { c1 in !self.collapsedIds.contains(c1.id) }
    }
    var heightsDict = [String: CGFloat]()
    var isFirstLayout = true
    var isPerformingCollapse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Header
        self.headerImageView.layer.mask = self.maskLayer
        let attributes: [NSAttributedStringKey : Any] = [.font : self.footLabel.font,
                                                         .foregroundColor : self.footLabel.textColor]
        self.titleLabel.text = self.post.hnPost.title
        self.summaryLabel.text = self.post.preview?.excerpt
        self.footLabel.attributedText = self.post.infosAttributedString(attributes: attributes, withComments: true)
        self.view.sendSubview(toBack: self.headerView)
        
        // TableView
        self.tableView.estimatedRowHeight = 999
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .clear
        
        let tableBackView = UIView()
        tableBackView.backgroundColor = .clear
        self.tableView.backgroundView = tableBackView
        
        let tapToRead = UITapGestureRecognizer(target: self, action: #selector(showArticle))
        tableBackView.addGestureRecognizer(tapToRead)
        
        self.fetchHeaderImage()
        self.refreshComments()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLayout {
            let top = self.headerView.bounds.height - self.view.safeAreaInsets.top - 8
            self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0)
            isFirstLayout = false
        }
    }
    
    // MARK: - Networking
    
    func fetchHeaderImage() {
        guard   let imageUrlString = post.preview?.lead_image_url,
                let url = URL(string: imageUrlString) else {
                    self.headerImageView.image = R.image.flamingoBack()
                    self.loaderView.stopAnimating()
            return
        }
        
        SDWebImageDownloader.shared().downloadImage(with: url, options: [.allowInvalidSSLCertificates], progress: nil) { (image, _, _, _) in
            self.loaderView.stopAnimating()
            if  let image = image {
                self.headerImageView.image = image.blend(image: R.image.color_gradient()!, with: .hardLight)
            } else {
                self.headerImageView.image = R.image.flamingoBack()
            }
        }
    }
    
    func refreshComments() {
        self.currentState = .loading
        
        HNScraper.shared.getComments(ForPost: post.hnPost, buildHierarchy: false) { (_, comments, error) in
            if let error = error  {
                self.currentState = .error(message: error.localizedDescription)
                return
            }
            self.comments = comments
            if !self.comments.isEmpty {
                self.currentState = .loaded
            } else {
                self.currentState = .error(message: i18n.commonNothingToShow())
            }
        }
    }
    
    // MARK: - Logic
    
    func updateUI() {
        switch currentState {
        case .loading :
            loadingIndicator.startAnimating()
            stateLabel.text = i18n.articleCommentsLoading()
            break
        case .error(let message) :
            loadingIndicator.stopAnimating()
            stateLabel.text = message
            break
        case .loaded :
            loadingIndicator.stopAnimating()
            stateLabel.text = nil
            self.tableView.reloadData()
            break
        }
    }
    
    @objc func showArticle() {
        self.showURL(self.post.hnPost.url)
    }
    
    // MARK:- Comments Utils
    
    func isCollapser(comment: HNComment) -> Bool {
        return self.collapsingIds.contains(comment.id)
    }
    
    func collapsableUnder(comment: HNComment) -> [HNComment] {
        var collapsableComments = [HNComment]()
        let baseLevel = comment.level ?? 0
        var isUnder = false
        for com in self.comments {
            if !isUnder {
                isUnder = (comment.id == com.id)
                continue
            }
            if com.level <= baseLevel {
                break
            }
            collapsableComments.append(com)
        }
        return collapsableComments
    }
    
    func collapseUnder(comment: HNComment) {
        let ids = Set(self.collapsableUnder(comment: comment).map {$0.id})
        self.collapsedIds = self.collapsedIds.union(ids)
    }
    
    func uncollapseUnder(comment: HNComment) {
        let ids = Set(self.collapsableUnder(comment: comment).map {$0.id})
        self.collapsingIds = self.collapsingIds.subtracting(ids) // We uncollapse any collapsed inside
        self.collapsedIds = self.collapsedIds.subtracting(ids)
    }
    
    // MARK:- CommentCellDelegate
    
    func commentCell(_ cell: CommentCell, didSelect url: URL) {
        self.showURL(url)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isPerformingCollapse {return}
        let contentOffset =     -(self.tableView.contentOffset.y
                                + self.tableView.contentInset.top
                                + self.tableView.layoutMargins.top)
        
        // Header image bounce & blur
        headerTopConstraint.constant = contentOffset * 0.66
        self.view.layoutIfNeeded()
        
        let path = UIBezierPath.triangleMaskPath(rect: self.headerImageView.bounds,
                                                 type: .left(height: 20))
        self.maskLayer.path = path.cgPath
    }
    
    // MARK:- UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = self.filteredComments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.commentCell, for: indexPath)!
        let isCollapser = self.isCollapser(comment: comment)
        cell.setComment(comment, isCollapser: isCollapser)
        cell.delegate = self
        return cell
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let comment = self.filteredComments[indexPath.row]
        self.heightsDict[comment.id] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = self.filteredComments[indexPath.row]
        return self.heightsDict[comment.id] ?? UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = self.filteredComments[indexPath.row]
        if self.isCollapser(comment: comment) {
            self.collapsingIds.remove(comment.id)
            self.uncollapseUnder(comment: comment)
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        } else {
            if self.collapsableUnder(comment: comment).count > 0 {
                self.collapsingIds.insert(comment.id)
                self.collapseUnder(comment: comment)
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            } else {
                // Nothing to collapse!
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }        
    }

}
