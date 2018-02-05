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

enum State {
    case loading
    case error(message: String)
    case loaded
}

class ArticleCommentsVC : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var footLabel: UILabel!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var stateLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var post : FlamingoPost!
    var currentState : State = .loading {
        didSet {
            UIView.animate(withDuration: 0.4) {
               self.updateUI()
            }
        }
    }
    var comments = [HNComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Header
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
        
        self.refreshComments()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.bounds.height, 0, 0, 0)
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
