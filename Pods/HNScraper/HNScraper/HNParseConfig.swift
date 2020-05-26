//
//  HNParseConfig.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation


/**
 Manage to download, store and cache the json file
 used to parse the pages of the website.
 */
public class HNParseConfig {
    private let savingKey = "HNParseConfig"
    private let url = "https://raw.githubusercontent.com/tsucres/HNScraper/v0.2.2/hn.json"
    private var _config: [String: Any]? = nil
    private init() {}
    public static let shared = HNParseConfig()
    
    /// Returns the data if in cache (if not it returns
    /// nil, you need to call getDictionnary to fetch the file)
    public var data:[String: Any]? {
        get {
            if (_config == nil) {
                _config = cacheData
            }
            return _config
        }
    }
    /// Looks for the data in local storage
    private var cacheData: [String: Any]? {
        get {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: self.savingKey) != nil {
                return (defaults.object(forKey: self.savingKey) as! [String: Any])
            } else {
                return nil
            }
        }
    }
    /**
     The completion handler is called with the configration data as
     parameter when the json file has been fetched. It firstly
     checks in the clocal storage if it has already been fetched.
     */
    internal func getDictionnary(completion: @escaping (([String: Any]?, RessourceFetcher.RessourceFetchingError?) -> Void)) {
        if self.data != nil {
            completion(self.data, nil)
        } else {
            self.downloadConfigFile(completion: completion)
        }
    }
    
    
    /// Downloads the configFile and store it locally. If a configFile is already saved, it's replaced.
    internal func downloadConfigFile(completion: @escaping (([String: Any]?, RessourceFetcher.RessourceFetchingError?) -> Void)) {
        RessourceFetcher.shared.getJson(url: self.url, completion: { (json, error) -> Void in
            if (json != nil) {
                let defaults = UserDefaults.standard
                defaults.set(json, forKey: self.savingKey)
                self._config = json
                completion(json, error)
            } else {
                completion(nil, error ?? .noData)
            }
        })
    }
    
    /// Downloads the configFile and store it locally. If a configFile is already saved, it's replaced.
    public func forceRedownload(completion: @escaping ((HNScraper.HNScraperError?) -> Void)) {
        self.downloadConfigFile { (_, ressourceFetcherError) in
            completion(HNScraper.HNScraperError.init(ressourceFetcherError))
        }
    }
}
