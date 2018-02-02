//
//  HNScraper.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation
public class HNScraper {
    // ==================================================
    // MARK: Private members
    // ==================================================
    private init() {}
    
    
    // TODO: put those canstant in the parsingConfig json file
    public static let baseUrl = "https://news.ycombinator.com/"
    
    // Following variables are used by the parsing function.
    // They have to be filled before those function are called.
    private var postsHtmlToBeParsed: String?
    private var commentsHtmlToBeParsed: String?
    
    
    // ==================================================
    // MARK: - types definition
    // ==================================================
    
    /**
     *  The first parameter is the list of downloaded posts. It can be empty
     *  in case of error or if no posts were found on the particular page.
     *  The second parameter is the (relative) link to the next page of the list.
     *  The third parameter contains the eventual error produced by either the
     *  request processing or the parsing of the response.
     */
    public typealias PostListDownloadCompletionHandler = (([HNPost], String?, HNScraperError?) -> Void) // (list, linkForMore, error)
    
    /// Supported post list pages
    public enum PostListPageName {
        /// Home page
        case news
        // Today's front page
        case front
        /// Latest submissions
        case new
        /// Jobs only (new first)
        case jobs
        /// Asks only (new first)
        case asks
        /// Shows only (top)
        case shows
        /// Shows only (latest)
        case newshows
        /// All news with most active discussion thread first
        case active
        /// Highest (recent) score
        case best
        /// More recent, only by new users
        case noob
    }
    
    /// Errors thrown by the scraper
    public enum HNScraperError: Error {
        /// The configuration file is needed but couldn't be downloaded/find locally
        case missingOrCorruptedConfigFile
        /// When a method fails to parse structured data
        case parsingError
        /// A specified url is either malformed or point to a non-existing ressource
        case invalidURL
        /// No internet connection
        case noInternet
        /// The user isn't logged in while the action he asked needs him to be.
        case notLoggedIn
        /// No data could be retrieved from the specified location
        case noData
        /// Problem on server side
        case serverUnreachable
        /// When the username used to make a request doesn't exist (doesn't apply to login attempts)
        case noSuchUser
        /// When the post id used to make a request doesn't exist
        case noSuchPost
        case unknown
        
        init?(_ error: RessourceFetcher.RessourceFetchingError?) {
            if error == nil {
                return nil
            }
            if error == .noIternet {
                self = .noInternet
            } else if error == .noData {
                self = .noData
            } else if error == .invalidURL || error == .badHTTPRequest400Range {
                self = .invalidURL
            } else if error == .serverError500Range ||  error == .serverUnreachable || error == .securityIssue {
                self = .serverUnreachable
            } else if error == .parsingError {
                self = .parsingError
            } else {
                self = .unknown
            }
        }
    }
    
    /// Dictionnary that associates a name of a post list page with its url
    let postListPages: [PostListPageName: String] = [.news: baseUrl + "news",
                                                           .front: baseUrl + "front",
                                                           .new: baseUrl + "newest",
                                                           .jobs: baseUrl + "jobs",
                                                           .asks: baseUrl + "ask",
                                                           .shows: baseUrl + "show",
                                                           .newshows: baseUrl + "shownew",
                                                           .active: baseUrl + "active",
                                                           .best: baseUrl + "best",
                                                           .noob: baseUrl + "noobstories"]
    
    
    
    public static let shared = HNScraper()
    
    
    
    // ==================================================
    // MARK: - Download list of posts
    // ==================================================
    
    /**
     Fetch the parseConfig file and the html of a page containing a
     list of hn posts. Parse this page and build a list a HNPost objects.
     - paramaters:
     - page: the list to download
     - completion: handler called with the list of HNPosts as parameter when completed
     */
    public func getPostsList(page: PostListPageName, completion: @escaping PostListDownloadCompletionHandler) {
        let url: String! = postListPages[page]!
        self.getPostsList(url: url, completion: completion)
        
    }
    /**
     Fetch the parseConfig file and the html of a page containing a
     list of hn posts. Parse this page and build a list a HNPost objects.
     - parameters:
         - url: the url of the page to download and parse
         - completion: handler called with the list of HNPosts as parameter when completed
     */
    private func getPostsList(url: String, completion: @escaping PostListDownloadCompletionHandler) {
        self.getHtmlAndParsingConfig(url: url) { (html, error) in
            if html == nil {
                completion([], nil, error ?? .noData)
                return
            }
            self.postsHtmlToBeParsed = html
            self.parseDownloadedPosts(completion: completion)
        }
    }
    
    /**
     Fetches the discussion page of a post and the parseConfig file. Parses the webpage and builds an HNPost object from it.
     - parameters:
         - id: the id of the post to retrieve
         - completion: handler called with the HNPost and the associated comments as parameter when completed
     */
    public func getPost(ById id: String, buildHierarchy: Bool = true, completion: @escaping ((HNPost?, [HNComment], HNScraperError?) -> Void)) {
        self.getHtmlAndParsingConfig(url: HNScraper.baseUrl + "item?id=\(id)") { (html, error) in
            if html == nil {
                completion(nil, [], error ?? .noData)
                return
            }
            if html! == "No such item." {
                completion(nil, [], .noSuchPost)
                return
            }
            guard let parseConfig = HNParseConfig.shared.data else {
                completion(nil, [], error ?? .missingOrCorruptedConfigFile)
                return
            }
            self.commentsHtmlToBeParsed = html
            if let post = HNPost(fromHtml: html!, withParsingConfig: parseConfig) {
                self.parseDownloadedComments(ForPost: post, buildHierarchy: buildHierarchy, completion: completion)
            } else {
                completion(nil, [], .parsingError)
            }
            
        }
    }
    
    /**
     Download the a page's html and pass it to the completion handler
     - parameters:
     - url: the url of the page
     - completion: the closure called with the html content as
     parameter when the download is completed
     */
    private func downloadHtmlPage(urlString: String, cookie: HTTPCookie? = nil, completion: @escaping ((String?, HNScraperError?) -> Void)) {
        RessourceFetcher.shared.fetchData(urlString: urlString, completion: {(data, error) -> Void in
            if data == nil {
                completion(nil, HNScraperError(error) ?? .noData)
            } else {
                if let decodedHtml = String(data: data!, encoding: .utf8) {
                    completion(decodedHtml, HNScraperError(error))
                } else {
                    completion(nil, HNScraperError(error) ?? .parsingError)
                }
            }
            
        })
    }
    
    public func testPostFromDiscussionThread(urlString: String, completion: @escaping ((String?, HNScraperError?) -> Void)) {
        self.getHtmlAndParsingConfig(url: urlString, completion: completion)
    }
    
    /**
     *  Parse the html of a list of posts, contained in the
     *  var postsHtmlToBeParsed,  turn it into a list
     *  of HNPosts and passes it to the completion handler
     *  - Note: This method needs the configFile to be accessible
     *      and the postsHtmlToBeParsed variable to be correctly
     *      filled. For better error management, you may want
     *      check that before calling it.
     */
    private func parseDownloadedPosts(completion: PostListDownloadCompletionHandler) {
        let parseConfig = HNParseConfig.shared.data
        let html = self.postsHtmlToBeParsed
        if html == nil {
            completion([], nil, .noData)
            return
        }
        if parseConfig == nil {
            completion([], nil, .missingOrCorruptedConfigFile)
            return
        }
        
        var postAr: [HNPost] = [] // stores the results
        var linkForMore: String? = nil // link to next page ofthe list
        var postsConfig: [String : Any]? = (parseConfig != nil && parseConfig!["Post"] != nil) ? parseConfig!["Post"] as? [String : Any] : nil
        var htmlComponents: Array<String> = []
        if postsConfig != nil && postsConfig!["CS"] != nil {
            htmlComponents = html!.components(separatedBy: postsConfig!["CS"] as! String)
        } else {
            completion([], nil, .missingOrCorruptedConfigFile)
            return
        }
        
        if htmlComponents.count == 0 {
            completion([], nil, nil)
            return
        }
        
        var htmlComponentCounter = 0
        htmlComponents.remove(at: 0)
        for htmlComponent in htmlComponents {
            
            if let newPost = HNPost(fromHtml: htmlComponent, withParsingConfig: parseConfig!) {
                postAr.append(newPost)
            } else {
                // TODO: better logging
                print("There was an error while parsing a downloaded post.") // returns a parsingError only if all the components fail to be parsed.
            }
            
            // If last item of the page, try to grab the link for next page.
            if (htmlComponentCounter == htmlComponents.count - 1) {
                linkForMore = parseLinkForMore(html: htmlComponent, withParsingConfig: parseConfig!)
            }

            htmlComponentCounter += 1
        }
        if postAr.count == 0 && htmlComponents.count > 0{
            completion([], linkForMore, .parsingError)
        } else {
            completion(postAr, linkForMore, nil)
        }
    }
    
    /// Fetch the next page of a post list page using the "link for more" provided by the getPostsList method.
    public func getMoreItems(linkForMore: String, completionHandler: @escaping PostListDownloadCompletionHandler) {
        self.getPostsList(url: HNScraper.baseUrl + linkForMore, completion: completionHandler)
    }
    
    /**
     *  Parse the last part of the html page of the posts list to find the link to the next page.
     *  - parameters:
     *      - html: the part of the html of the list page containing the link to the next page.
     *  - note: In case of an error, it will just return nil, no error is reported.
     */
    private func parseLinkForMore(html: String, withParsingConfig parseConfig: [String: Any]) -> String? {
        let scanner: Scanner = Scanner(string: html)
        //var postsConfig: [String : Any]? = (parseConfig["Post"] != nil) ? parseConfig["Post"] as? [String : Any] : nil
        let postsConfig: [String : Any]? = parseConfig["Post"] as? [String: Any]
        if postsConfig == nil {
            return nil
        }
        var linkConfig: [String : String]? = postsConfig!["LinkForMore"] as? [String: String]
        if linkConfig == nil {
            return nil
        }
        var trash: NSString? = ""
        
        scanner.scanUpTo(linkConfig!["S"]!, into: &trash)
        var linkForMore: NSString? = ""
        scanner.scanString(linkConfig!["S"]!, into: &trash)
        scanner.scanUpTo(linkConfig!["E"]!, into: &linkForMore)
        var finalLinkForMore = (linkForMore?.replacingOccurrences(of: "/", with: ""))!
        finalLinkForMore = finalLinkForMore.replacingOccurrences(of: "&amp;", with: "&")
        return finalLinkForMore
    }
    
    /**
     Download the html page pointed by the specified url and
     retrieve the parsing configuration json file symultaniously,
     then call the completion handler when the two actions are
     completed.
     This method is usefull to any other method that needs to
     download a webpage and parse it useing the configuration file.
     */
    private func getHtmlAndParsingConfig(url: String, completion: @escaping ((String?, HNScraperError?) -> Void)) {
        let group = DispatchGroup()
        var _html: String?
        var parsingError: HNScraperError?
        // Fetch the page
        group.enter()
        downloadHtmlPage(urlString: url, completion: {(html, error) -> Void in
            parsingError = error
            _html = html
            group.leave()
        })
        // Check for the parsing configuration data. If not locally found, download it
        if HNParseConfig.shared.data == nil {
            group.enter()
            HNParseConfig.shared.getDictionnary(completion: {(config, error) -> Void in
                group.leave() // TODO: what if an error occurs here?
            })
        }
        
        // Call the completion handler when the two files are downloaded
        group.notify(queue: .main) {
            completion(_html, parsingError)
        }
        
    }
    
    
    // ==================================================
    // MARK: - Download discussion threads
    // ==================================================
    
    /// - Note: this is an alias for the method `getPost(ById:buildHierarchy:completion)`
    public func getComments(ByPostId postId: String, buildHierarchy: Bool = true, completion: @escaping ((HNPost?, [HNComment], HNScraperError?) -> Void)) {
        self.getPost(ById: postId, buildHierarchy: buildHierarchy, completion: completion)
    }
    
    /**
     Fetches the comments assiciated to the specified post.
     - parameters:
         - post: the post to retrieve the comments for
         - buildHierarchy: indicates if the comments must be nested or must all be placed at the root of the array
     - Note: the type of the post has to be specified in order to handle a askHN or a job correctly
     */
    public func getComments(ForPost post: HNPost, buildHierarchy: Bool = true, completion: @escaping ((HNPost, [HNComment], HNScraperError?) -> Void)) {
        let url = HNScraper.baseUrl + "item?id=\(post.id)"
        
        getHtmlAndParsingConfig(url: url, completion: { html, error -> Void in
            if html == nil {
                completion(post, [], error ?? .noData)
                return
            }
            if html! == "No such item." {
                completion(post, [], .noSuchPost)
                return
            }
            self.commentsHtmlToBeParsed = html
            self.parseDownloadedComments(ForPost: post, buildHierarchy: buildHierarchy, completion: completion)
        })
    }
    
    // TODO: That method is ugly, That method is ugly, That method's ugly, 'at method's ugly, thod's ugly, thod's gly, thod's y, Hodor
    private func parseDownloadedComments(ForPost post:HNPost, buildHierarchy: Bool = true, completion: ((HNPost, [HNComment], HNScraperError?) -> Void)) {
        let parseConfig = HNParseConfig.shared.data
        let html = self.commentsHtmlToBeParsed
        if html == nil {
            completion(post, [], .noData)
            return
        }
        if parseConfig == nil {
            completion(post, [], .missingOrCorruptedConfigFile)
            return
        }
        
        var rootComments: [HNComment] = [] // parsed comments in hierarchical form
        var allComments: [HNComment] = [] // parsed comments in linear form
        var lastCommentByLevel: [Int: HNComment] = [:] // Last parsed comment for each level, used to find the parent of a comment
        
        
        // Set Up
        var commentDict: [String : Any]? = (parseConfig != nil && parseConfig!["Comment"] != nil) ? parseConfig!["Comment"] as? [String: Any] : nil
        if (commentDict == nil) {
            completion(post, [], .missingOrCorruptedConfigFile)
            return
        }
        
        var htmlComponents = commentDict!["CS"] != nil ? html!.components(separatedBy: commentDict!["CS"] as! String) : nil
        if (htmlComponents == nil) {
            completion(post, [], .missingOrCorruptedConfigFile)
            return
        }
        
        
        if commentDict!["Reply"] != nil && (commentDict!["Reply"] as! [String: Any])["R"] != nil && html!.contains((commentDict!["Reply"] as! [String: Any])["R"]! as! String) {
            var cDict: [String: Any] = [:]
            let scanner = Scanner(string: html!)
            
            let parts = (commentDict!["Reply"] as! [String: Any])["Parts"] as! [[String : Any]]
            for part in parts {
                var new: NSString? = ""
                let isTrash = part["I"] as! String == "TRASH"
                scanner.scanBetweenString(stringA: part["S"] as! String, stringB: part["E"] as! String, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    cDict[part["I"] as! String] = new
                }
                
            }
            post.replyAction = cDict["action"] as? String ?? ""
            post.replyParent = cDict["parent"] as? String ?? ""
            post.replyHmac = cDict["hmac"] as? String ?? ""
            post.replyText = cDict["replyText"] as? String ?? ""
            post.replyGoto = cDict["goto"] as? String ?? ""
        }
        
        // For a post of type Job or Ask, the first and only rootComment will be the question/job itself
        if post.type == .askHN {
            if let newComment = HNComment.parseAskHNComment(html: htmlComponents![0], withParsingConfig: parseConfig!) {
                allComments.append(newComment)
                rootComments.append(newComment)
                lastCommentByLevel[0] = newComment
            } else {
                print("error parsing AskHN comment")
                completion(post, [], .parsingError)
                return
            }
            
        }
        
        if post.type == .jobs {
            if let newComment = HNComment.parseJobComment(html: htmlComponents![0], withParsingConfig: parseConfig!) {
                allComments.append(newComment)
                rootComments.append(newComment)
                lastCommentByLevel[0] = newComment
            } else {
                print("error parsing Job comment")
                completion(post, [], .parsingError)
                return
            }
            
        }
        
        // 1st object is garbage.
        htmlComponents?.remove(at: 0)
        for htmlComponent in htmlComponents! {
            
            if let newComment = HNComment(fromHtml: htmlComponent, withParsingConfig: parseConfig!, levelOffset: (post.type == .jobs || post.type == .askHN) ? 1 : 0) {
                if newComment.level == 0 { // If root comment
                    rootComments.append(newComment)
                } else { // looking for parent
                    if let parent = lastCommentByLevel[newComment.level-1] {
                        newComment.replyTo = parent
                        parent.addReply(newComment)
                    }
                }
                allComments.append(newComment)
                lastCommentByLevel[newComment.level] = newComment
                
            } else {
                print("error parsing comment")
            }
            
            
        }
        // TODO: return error if every comment fail to be parsed (i.e. htmlComponents.count> 0 && comments.count == 0)
        if buildHierarchy {
            completion(post, rootComments, nil)
        } else {
            completion(post, allComments, nil)
        }
        
        
    }
    
    
    // ==================================================
    // MARK: - Download User specifi data
    // ==================================================
    
    /*
     Fetch the list of posts submited by the user with
     the specified username and pass it to the completion
     handler when done.
     */
    public func getSubmissions(ForUserWithUsername username: String, completion: @escaping PostListDownloadCompletionHandler) {
        let url = HNScraper.baseUrl + "submitted?id=\(username)"
        getUserSpecificPostList(urlString: url, completion: completion)
    }
    
    /*
     Fetch the list of posts favorited by the user with
     the specified username and pass it to the completion
     handler when done.
     */
    public func getFavorites(ForUserWithUsername username: String, completion: @escaping PostListDownloadCompletionHandler) {
        let url = HNScraper.baseUrl + "favorites?id=\(username)"
        getUserSpecificPostList(urlString: url, completion: completion)
    }
    
    /*
     Check that the user exists and fetch the list of submission/favorite (according to specified url)
     */
    private func getUserSpecificPostList(urlString: String, completion: @escaping PostListDownloadCompletionHandler) {
        getHtmlAndParsingConfig(url: urlString, completion: { html, error -> Void in
            if html == nil {
                completion([], nil, error ?? .noData)
                return
            }
            if html! == "No such user." {
                completion([], nil, .noSuchUser)
                return
            }
            self.postsHtmlToBeParsed = html
            self.parseDownloadedPosts(completion: completion)
        })
    }
    
    
    /*
     Fetch the list of comments written by the user with
     the specified username and pass it to the completion
     handler when done.
     */
    /*public func getComments(ForUserWithUsername username: String, completion: @escaping (([HNComment]) -> Void)) {
     let url = HNScraper.baseUrl + "submitted?id=\(username)"
     getHtmlAndParsingConfig(url: url, completion: { html -> Void in
     self.postsHtmlToBeParsed = html
     self.parseDownloadedPosts(completion: completion)
     })
     }*/ // TODO
    
    // ==================================================
    // MARK: - Actions on posts/comments
    // ==================================================
    
    
    private func voteOnHNObject(AtUrl urlString: String, objectId: String, up: Bool, completion: @escaping ((HNScraperError?) -> Void)) {
        if !HNLogin.shared.isLoggedIn() {
            completion(.notLoggedIn)
            return
        }
        // The upvote url is change so that the goto parameter points to the post page.
        // That allows the verification to work even if the link is old and that the post isn't anymore on the page pointed by goto.
        var urlComponent = URLComponents(string: urlString)
        for (index, param) in (urlComponent?.queryItems ?? []).enumerated() {
            if param.name == "goto" {
                urlComponent?.queryItems![index].value = "item?id=" + objectId
            }
        }
        if let newUrlString = urlComponent?.string {
            downloadHtmlPage(urlString: newUrlString, cookie: HNLogin.shared.sessionCookie, completion: { html, error -> Void in
                if html == nil {
                    completion(error ?? .noData)
                } else {
                    if html!.contains("<a id='un_" + objectId) == up {
                        completion(nil)
                    } else {
                        completion(error ?? .unknown)
                    }
                }
                
            })
        } else {
            completion(.invalidURL)
        }
        
        
    }
    /// Use the upvote link of a post/comment to upvote it.
    /// If the upvote is successful, nil is passed to the completion handle, otherwise the error is transmitted.
    private func upvoteHNObject(AtUrl urlString: String, objectId: String, completion: @escaping ((HNScraperError?) -> Void)) {
        self.voteOnHNObject(AtUrl: urlString, objectId: objectId, up: true, completion: completion)
    }
    private func unvoteHNObject(AtUrl urlString: String, objectId: String, completion: @escaping ((HNScraperError?) -> Void)) {
        self.voteOnHNObject(AtUrl: urlString, objectId: objectId, up: false, completion: completion)
    }
    
    /// Upvote a comment. For this to be successfull, the upvoteUrl must be correctly set in the comment instance and the user must be logged in.
    public func upvote(Comment comment: HNComment, completion: @escaping ((HNScraperError?) -> Void)) {
        let url = HNScraper.baseUrl + comment.upvoteUrl.replacingOccurrences(of: "&amp;", with: "&")
        self.upvoteHNObject(AtUrl: url, objectId: comment.id, completion: completion)
    }
    /// Upvote a post. For this to be successfull, the upvoteUrl must be correctly set in the post instance and the user must be logged in.
    public func upvote(Post post: HNPost, completion: @escaping ((HNScraperError?) -> Void)) {
        if post.upvoteAdditionURL != nil {
            let url = HNScraper.baseUrl + post.upvoteAdditionURL!.replacingOccurrences(of: "&amp;", with: "&")
            self.upvoteHNObject(AtUrl: url, objectId: post.id, completion: completion)
        } else {
            completion(.invalidURL)
        }
        
    }
    public func unvote(Post post: HNPost, completion: @escaping ((HNScraperError?) -> Void)) {
        if post.upvoteAdditionURL != nil {
            let url = HNScraper.baseUrl + post.upvoteAdditionURL!.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "how=up", with: "how=un")
            self.unvoteHNObject(AtUrl: url, objectId: post.id, completion: completion)
        } else {
            completion(.invalidURL)
        }
        
    }
    public func unvote(Comment comment: HNComment, completion: @escaping ((HNScraperError?) -> Void)) {
        let url = HNScraper.baseUrl + comment.upvoteUrl.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "how=up", with: "how=un")
        self.unvoteHNObject(AtUrl: url, objectId: comment.id, completion: completion)
    }
    
    /// Favorite a post. For this to be successfull, the upvoteUrl must be correctly set in the post instance and the user must be logged in.
    public func favorite(Post post: HNPost, completion: @escaping ((HNScraperError?) -> Void)) {
        if !HNLogin.shared.isLoggedIn() {
            completion(.notLoggedIn)
            return
        }
        if post.upvoteAdditionURL != nil {
            let url = HNScraper.baseUrl + post.upvoteAdditionURL!.replacingOccurrences(of: "&amp;", with: "&")
                                                                .replacingOccurrences(of: "how=up", with: "how=un")
                                                                .replacingOccurrences(of: "vote?id=", with: "fave?id=")
            
            downloadHtmlPage(urlString: url, cookie: HNLogin.shared.sessionCookie, completion: { html, error -> Void in
                // The favortie url redirect to the list of favorite of the user. We check if the id of the favorited post is in the post list (in the html).
                if html == nil {
                    completion(error ?? .noData)
                } else {
                    if html!.contains("id='" + post.id + "'") {
                        completion(nil)
                    } else {
                        completion(error ?? .unknown)
                    }
                }
            })
        } else {
            completion(.invalidURL)
        }
        
    }
    // TODO: func favorited(post, un=false, completion)
    public func unfavorite(Post post: HNPost, completion: @escaping ((HNScraperError?) -> Void)) {
        if !HNLogin.shared.isLoggedIn() {
            completion(.notLoggedIn)
            return
        }
        if post.upvoteAdditionURL != nil {
            let url = HNScraper.baseUrl + post.upvoteAdditionURL!.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "how=up", with: "un=t").replacingOccurrences(of: "vote?id=", with: "fave?id=")
            
            downloadHtmlPage(urlString: url, cookie: HNLogin.shared.sessionCookie, completion: { html, error -> Void in
                // The id of the unfavorited post must be absent from the html
                if html == nil {
                    completion(error ?? .noData)
                } else {
                    if !html!.contains("id='" + post.id + "'") {
                        completion(nil)
                    } else {
                        completion(error ?? .unknown)
                    }
                }
            })
        } else {
            completion(.invalidURL)
        }

    }
    
    public func getUserFrom(Username username: String, completion: ((HNUser?, HNScraperError?) -> Void)?) {
        getHtmlAndParsingConfig(url: HNScraper.baseUrl + "user?id=" + username, completion: { html, error -> Void in
            if html == nil {
                completion?(nil, error ?? .noData)
                return
            }
            if HNParseConfig.shared.data == nil {
                completion?(nil, .missingOrCorruptedConfigFile)
                return
            }
            if html!.contains("No such user.") {
                completion?(nil, .noSuchUser)
                return
            }
            completion?(HNUser(fromHtml: html!, withParsingConfig: HNParseConfig.shared.data!), error)
        })
    }
    
    
}
