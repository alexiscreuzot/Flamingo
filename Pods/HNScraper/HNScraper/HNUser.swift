//
//  HNUser.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation

public class HNUser {
    public var username: String!
    public var karma: Int!
    public var age: Date!
    public var aboutInfo: String?
    public var isNoob: Bool! = false // TODO
    
    
    public init(username: String, karma: Int, age: Date, aboutInfo: String? = nil) {
        self.username = username
        self.age = age
        self.karma = karma
        self.aboutInfo = aboutInfo
    }
    /**
     *  - parameters:
     *      - age: the number of days in the past relatively to current date.
     *
     */
    public convenience init(username: String, karma: String, age: String, aboutInfo: String?) {
        self.init(username: username, karma: Int(karma.replacingOccurrences(of: " ", with: "")) ?? 0, age: HNUser.dateFromNumberOfDays(Int(age) ?? 0), aboutInfo: aboutInfo)
    }
    
    public convenience init?(fromHtml html: String, withParsingConfig parseConfig: [String : Any]) {
        var userDict: [String : Any]? = parseConfig["User"] != nil ? parseConfig["User"] as? [String: Any] : nil
        if (userDict == nil || userDict!["Parts"] == nil) {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var uDict: [String: Any] = [:]
        
        let parts = userDict!["Parts"] as! [[String : Any]]
        for dict in parts {
            var new: NSString? = ""
            let isTrash = (dict["I"] as! String) == "TRASH"
            let start = dict["S"] as! String
            let end = dict["E"] as! String
            if scanner.string.contains(start) && scanner.string.contains(start) {
                scanner.scanBetweenString(stringA: start, stringB: end, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    uDict[dict["I"] as! String] = new
                }
            }
        }
        
        if uDict["user"] == nil {
            return nil
        }
        self.init(username: uDict["user"]  as! String, karma: uDict["karma"] as? String ?? "", age: uDict["age"] as? String ?? "", aboutInfo: uDict["about"]  as? String)
        
    }
    
    /// Converts the number of days from current date to a Date instance.
    private static func dateFromNumberOfDays(_ numberOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -numberOfDays, to: Date())!
    }
    
}
