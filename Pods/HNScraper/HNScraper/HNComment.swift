//
//  HNComment.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation

public class BaseComment {
    public var replies: [BaseComment]! = []
    public var level: Int! = 0
    public weak var replyTo: BaseComment?
    
    public convenience init() {
        self.init(level: 0, replyTo: nil)
    }
    public init(level: Int, replyTo: BaseComment?) {
        self.level = level
        self.replyTo = replyTo
    }
    public func addReply(_ reply: BaseComment) {
        self.replies.append(reply)
    }
    
}

public class HNComment: BaseComment {
    public convenience init() {
        self.init(level: 0, replyTo: nil)
    }
    public override init(level: Int, replyTo: BaseComment?) {
        super.init(level: level, replyTo: replyTo)
    }
    public enum HNCommentType {
        case defaultType
        case askHN
        case jobs
    }
    
    
    public var type: HNCommentType! = .defaultType
    public var text: String! = ""
    public var id: String! = ""
    public var username: String! = "anonymous"
    public var parentId: Int! = -1
    public var created: String! = ""
    public var replyUrl: String! = ""
    public var links: [String]! = []
    public var upvoteUrl: String! = ""
    public var downvoteUrl: String! = ""
    
    
    public convenience init?(fromHtml html: String, withParsingConfig parseConfig: [String : Any], levelOffset: Int = 0) {
        self.init()
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var upvoteString: NSString? = ""
        let downvoteString: NSString? = ""
        var level: NSString? = ""
        var cDict: [String : Any] = [:]
        
        
        // Get Comment Level
        scanner.scanBetweenString(stringA: (commentDict!["Level"] as! [String: String])["S"]!, stringB: (commentDict!["Level"] as! [String: String])["E"]!, into: &level)
        if (level != nil) {
            self.level = Int(level!.intValue) / 40 + levelOffset // TODO: add this constant in the parseConfig
        } else {
            self.level = levelOffset
        }
        
        
        
        
        
        // If Logged In - Grab Voting Strings
        if (html.contains((commentDict!["Upvote"] as! [String: String])["R"]!)) {
            // Scan Upvote String
            scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into:&upvoteString)
            if (upvoteString != nil) {
                self.upvoteUrl = upvoteString!.replacingOccurrences(of: "&amp;", with: "&")
            }
            // Check for downvote String
            if (html.contains((commentDict!["Downvote"] as! [String: String])["R"]!)) {
                scanner.scanBetweenString(stringA: (commentDict!["Downvote"] as! [String: String])["S"]!, stringB: (commentDict!["Downvote"] as! [String: String])["E"]!, into:&upvoteString)
                if (downvoteString != nil) {
                    self.downvoteUrl = downvoteString!.replacingOccurrences(of: "&amp;", with: "&")
                }
            }
        }
        scanner.scanLocation = 0
        
        let regs = commentDict!["REG"] as! [[String : Any]]
        for dict in regs {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        self.id = cDict["CommentId"] as? String ?? ""
        self.text = cDict["Text"] as? String ?? ""
        self.username = cDict["Username"] as? String ?? ""
        self.created = cDict["Time"] as? String ?? ""
        self.replyUrl = cDict["ReplyUrl"] as? String ?? ""
        
        
        
    }
    
    public static func parseAskHNComment(html: String, withParsingConfig parseConfig: [String : Any]) -> HNComment? {
        var cDict: [String : Any] = [:]
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var upvoteUrl: NSString? = ""
        
        
        if html.contains((commentDict!["Upvote"] as! [String: String])["R"]!) {
            scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into: &upvoteUrl)
            if (upvoteUrl != nil) {
                upvoteUrl = upvoteUrl!.replacingOccurrences(of: "&amp;", with: "&") as NSString
            }
        }
        let asks = commentDict!["ASK"] as! [[String : Any]]
        for dict in asks {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        let newComment = HNComment()
        newComment.level = 0
        newComment.username = cDict["Username"] as? String ?? ""
        newComment.created = cDict["Time"] as? String ?? ""
        newComment.text = cDict["Text"] as? String ?? ""
        //newComment.links = ...
        newComment.type = .askHN
        newComment.upvoteUrl = String(describing: upvoteUrl) as String //(upvoteUrl?.length)! > 0 ? upvoteUrl : "";
        newComment.id = cDict["CommentId"] as? String ?? ""
        return newComment
    }
    public static func parseJobComment(html: String, withParsingConfig parseConfig: [String : Any]) -> HNComment? {
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var cDict: [String : Any] = [:]
        
        let jobs = commentDict!["JOBS"] as! [[String : Any]]
        for dict in jobs {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        let newComment = HNComment()
        newComment.level = 0
        newComment.text = cDict["Text"] as? String ?? ""
        //newComment.links = ...
        newComment.type = .jobs
        
        return newComment
    }
}
