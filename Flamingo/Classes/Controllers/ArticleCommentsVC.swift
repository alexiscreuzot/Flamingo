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

enum State {
    case loading
    case error(message: String)
    case loaded
}

class ArticleCommentsVC : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headerImageView: UIImageView!
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
    var isFirstLayout = true
    
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
        self.tableView.alpha = 0
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.backgroundView?.backgroundColor = UIColor.clear
        
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
    
    func fetchHeaderImage() {
        guard   let imageUrlString = post.preview?.lead_image_url,
                let url = URL(string: imageUrlString) else {
            return
        }
        
        SDWebImageDownloader.shared().downloadImage(with: url, options: [.allowInvalidSSLCertificates], progress: nil) { (image, _, _, _) in
            
            if  let image = image {
                self.headerImageView.image = image.blend(image: R.image.color_gradient()!, with: .hardLight)
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
                self.currentState = .error(message: "Nothing to show")
            }
        }
    }
    
    func updateUI() {
        switch currentState {
        case .loading :
            loadingIndicator.startAnimating()
            tableView.alpha = 0
            stateLabel.text = "Loading comments"
            break
        case .error(let message) :
            tableView.alpha = 0
            loadingIndicator.stopAnimating()
            stateLabel.text = message
            break
        case .loaded :
            loadingIndicator.stopAnimating()
            tableView.alpha = 1
            stateLabel.text = ""
            self.tableView.reloadData()
            break
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset =     -(self.tableView.contentOffset.y
                                + self.tableView.contentInset.top
                                + self.tableView.layoutMargins.top)
        
        // Header image bounce & blur
        headerTopConstraint.constant = contentOffset * 1.0
        self.view.layoutIfNeeded()
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: self.headerImageView.bounds.maxY - 20))
        path.addLine(to: CGPoint(x: self.headerImageView.bounds.maxX, y: self.headerImageView.bounds.maxY))
        path.addLine(to: CGPoint(x: self.headerImageView.bounds.maxX, y: 0))
        path.close()
        self.maskLayer.path = path.cgPath
    }
    
    // MARK:- UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = self.comments[indexPath.row ]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.commentCell, for: indexPath)!
        cell.setComment(comment)
        return cell
    }
}
