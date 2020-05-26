//
//  HNLogin.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation


// abdurhtl
// !Bullshit?Psw$

public protocol HNLoginDelegate {
    func didLogin(user: HNUser, cookie: HTTPCookie)
}

public class HNLogin {
    private var observers: [HNLoginDelegate] = []
    
    public func addObserver(_ observer: HNLoginDelegate) {
        self.observers.append(observer)
    }
    private init() {
        if let cookie = self.retrieveSessionCookie() {
            self._sessionCookie = cookie
            self.getUsernameFromCookie(cookie, completion: {(user, cookie, error) -> Void in
                if cookie != nil {
                    self._user = user
                    self._sessionCookie = cookie
                    if self.isLoggedIn() {
                        for observer in self.observers {
                            observer.didLogin(user: user!, cookie: cookie!)
                        }
                    }
                }
            })
        }
    }
    
    public enum HNLoginError: Error {
        case badCredentials
        case serverUnreachable
        case noInternet
        case unknown
        
        init?(_ error: RessourceFetcher.RessourceFetchingError?) {
            self.init(HNScraper.HNScraperError(error))
        }
        init?(_ error: HNScraper.HNScraperError?) {
            if error == nil {
                return nil
            }
            if error == .noInternet {
                self = .noInternet
            } else if error == .serverUnreachable || error == .noData {
                self = .serverUnreachable
            } else {
                self = .unknown
            }
        }
    }
    
    public static let shared = HNLogin()
    
    private var _sessionCookie: HTTPCookie?
    private var _user: HNUser?
    
    public var sessionCookie: HTTPCookie? {
        get {
            return _sessionCookie
        }
    }
    public var user: HNUser? {
        get {
            return _user
        }
    }
    
    
    /**
     * Log a user in useing the specified credentials. In case of success, 
     * a HNUser instance is built with the information of the conected 
     * user and passed as paramater to the completion handler along with a 
     * cookie containing the session data.
     */
    public func login(username: String, psw: String, completion: @escaping ((HNUser?, HTTPCookie?, HNLoginError?) -> Void)) {
        let url = HNScraper.baseUrl + "login"
        let encodedPass = psw.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted)
        let bodyString = "acct=\(username)&pw=\(encodedPass!)&whence=news"
        guard let bodyData = bodyString.data(using: .utf8) else {
            completion(nil, nil, .badCredentials)
            return
        }
        
        RessourceFetcher.shared.post(urlString: url, data: bodyData, completion: {data, reponse, error -> Void in
            if data == nil {
                completion(nil, nil, HNLoginError(error) ?? .unknown)
                return
            }
            if let html = String(data: data!, encoding: .utf8) {
                if (!html.contains("Bad login.") && !html.contains("Unknown or expired link.")) {
                    let scanner = Scanner(string: html)
                    var trash: NSString? = ""
                    var karma: NSString? = ""
                    
                    scanner.scanUpTo("/a>&nbsp;(", into: &trash) // TODO: use config file
                    scanner.scanString("/a>&nbsp;(", into: &trash)
                    scanner.scanUpTo(")", into: &karma)
                    self._user = HNUser(username: username, karma: karma! as String, age: "", aboutInfo: "")
                    
                    self.getLoggedInUser(user: self._user!, completion: {(user, cookie, error) -> Void in
                        
                        if self.isLoggedIn() {
                            for observer in self.observers {
                                observer.didLogin(user: user!, cookie: cookie!)
                            }
                        }
                        completion(user, cookie, error)
                    })
                    
                    
                } else {
                    print("Probably wrong password") // TODO: logging
                    completion(nil, nil, .badCredentials)
                }
                
                
            } else {
                print("Post request failed")
                completion(nil, nil, HNLoginError(error) ?? .unknown)
            }
            
        })
        
    }
    
    public func logout() {
        if self._sessionCookie != nil {
            HTTPCookieStorage.shared.deleteCookie(self._sessionCookie!)
            self._sessionCookie = nil
            
        }
        self._user = nil
    }
    
    // TODO: clean this up, use the HNScraper's getUser method
    /**
     * Fetch the informations about a user. 
     * - parameters:
     *      - user: a HNUser object with at least the username of the user you want the info about.
                All the other properties are just copied in the result object or replaced with the newly fetched informations.
     *      - completion:
     */
    private func getLoggedInUser(user: HNUser, completion: @escaping ((HNUser?, HTTPCookie?, HNLoginError?) -> Void)) {
        let url = "https://news.ycombinator.com/user?id=\(user.username!)"
        
        RessourceFetcher.shared.fetchData(urlString: url, completion: {(data, error) -> Void in
            
            if let data = data, let html = String(data: data, encoding: .utf8) {
                var newUser: HNUser?
                // Getting user info
                if !(html.contains("We've limited requests for this url.")) {
                    HNParseConfig.shared.getDictionnary(completion: {(parsingConfig, configFileError) -> Void in
                        if parsingConfig != nil {
                            newUser = HNUser(fromHtml: html, withParsingConfig: parsingConfig!)
                            if newUser == nil {
                                newUser = user
                            }
                        } else {
                            print("couldn't fetch the configFile")
                        }
                        // Getting cookie
                        self._sessionCookie = self.retrieveSessionCookie()
                        self._user = newUser
                        completion(newUser, self._sessionCookie, HNLoginError(error))
                        
                    })
                } else {
                    print("Couldn't fetch user informations")
                    completion(nil, nil, HNLoginError(error) ?? .serverUnreachable)
                }
            } else {
                completion(nil, nil, HNLoginError(error) ?? .unknown)
            }
            
        })
    }
    
    // TODO: better error gesture & logging
    private func getUsernameFromCookie(_ cookie: HTTPCookie, completion: @escaping ((HNUser?, HTTPCookie?, HNLoginError?) -> Void)) {
        let url = "https://news.ycombinator.com/user?id=pg" // any valid url would do
        
        RessourceFetcher.shared.fetchData(urlString: url, completion: {(data, error) -> Void in
            if data != nil {
                if let html = String(data: data!, encoding: .utf8)  {
                    if (!html.contains("<a href=\"logout")) {
                        let scanner = Scanner(string: html)
                        var trash: NSString? = ""
                        var karma: NSString? = ""
                        var userString: NSString? = ""
                        
                        scanner.scanUpTo("<a href=\"threads?id=", into: &trash) // TODO: put that in the parsing config file
                        scanner.scanString("<a href=\"threads?id=", into: &trash)
                        scanner.scanUpTo("\">", into: &userString)
                        scanner.scanUpTo("&nbsp;(", into: &trash)
                        scanner.scanString("&nbsp;(", into: &trash)
                        scanner.scanUpTo(")", into: &karma)
                        
                        let user = HNUser(username: userString! as String, karma: karma! as String, age: "", aboutInfo: "")
                        
                        self.getLoggedInUser(user: user, completion: completion)
                        
                        
                    } else {
                        print("getUsernameFromCookie: bad cookie?") // TODO: Logging
                        completion(nil, nil, HNLoginError(error))
                    }
                    
                    
                } else {
                    print("getUsernameFromCookie: Get request failed: not html?")
                    completion(nil, nil, HNLoginError(error))
                }
            } else {
                print("getUsernameFromCookie: Get request failed: no data")
                completion(nil, nil, HNLoginError(error))
            }
            
            
        })

            
            
    }
    
    private func retrieveSessionCookie() -> HTTPCookie? {
        if let cookieArray = HTTPCookieStorage.shared.cookies(for: URL(string: HNScraper.baseUrl)!) {
            if cookieArray.count > 0 {
                for cookie in cookieArray {
                    if cookie.name == "user" {
                        return cookie
                    }
                }
                
            }
        }
        
        return nil
    }
    
    public func isLoggedIn() -> Bool {
        return self.sessionCookie != nil && self._user != nil
    }
    
    
}
