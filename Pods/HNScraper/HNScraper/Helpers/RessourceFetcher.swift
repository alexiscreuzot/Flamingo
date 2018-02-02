//
//  HNHelpers.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import UIKit



/// Singleton implementation of a GET/POST request sender
class RessourceFetcher {
    public typealias FetchCompletion = (_ data: Data?, _ error: RessourceFetchingError?) -> Void
    public typealias JsonFetchCompletion = (_ json: Dictionary<String, Any>?, _ error: RessourceFetchingError?) -> Void
    
    public enum RessourceFetchingError: Error {
        case invalidURL
        case badHTTPRequest400Range
        case serverError500Range
        case serverUnreachable
        case noIternet
        case securityIssue
        case parsingError
        case noData
        case unknown
    }
    
    
    /// Turns a URLError to a simpler RessourceFetchingError
    private func errorParsing(_ error: Error) -> RessourceFetchingError {
        if let urlError = error as? URLError {
            if [URLError.unsupportedURL , URLError.badURL].contains(urlError.code) {
                return .invalidURL
            } else if [URLError.notConnectedToInternet , URLError.networkConnectionLost, URLError.internationalRoamingOff].contains(urlError.code) {
                return .noIternet
            } else if [URLError.secureConnectionFailed , URLError.appTransportSecurityRequiresSecureConnection].contains(urlError.code) {
                return .securityIssue
            } else if [URLError.cannotConnectToHost, URLError.timedOut, URLError.cannotFindHost].contains(urlError.code) {
                return .serverUnreachable
            } else {
                return .unknown
            }
            
        } else {
            return .unknown
        }
    }
    
    private init() {
        
    }
    
    static let shared = RessourceFetcher()
    
    /// Fetches the ressource pointed by the specified url and passes it to the completionHandler
    func fetchData(urlString: String, completion: @escaping FetchCompletion, timeout: TimeInterval = 20) {
        if let url = URL(string: urlString) {
            let req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
            self.execRequest(req, completion: {(data, response, error) -> Void in
                completion(data, error)
            })
        } else {
            completion(nil, .invalidURL)
        }
    }
    
    /// Creates a dataTask with the specified request and passes the response to the completion closure. Basically just helps handling URLErrors.
    private func execRequest(_ request: URLRequest, completion: @escaping ((Data?, URLResponse?, RessourceFetchingError?) -> Void)) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            var ressourceFetchingError: RessourceFetchingError?
            if data == nil {
                ressourceFetchingError = .noData
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 500 {
                    ressourceFetchingError = .serverError500Range
                } else if httpResponse.statusCode >= 400 {
                    ressourceFetchingError = .badHTTPRequest400Range
                }
            }
            if error != nil {
                ressourceFetchingError = self.errorParsing(error!)
            }
            DispatchQueue.main.async(execute: { ()->() in
                completion(data, response, ressourceFetchingError)
            })
            
        })
        task.resume()
    }
    
    /// Fetch the ressource pointed by the specified url and try to parse it to a json dictionnary. The result is passed to the completion closure.
    func getJson(url: String, completion: @escaping JsonFetchCompletion) {
        self.fetchData(urlString: url, completion: {(data, error) -> Void in
            if error != nil {
                completion(nil, error)
            } else if data == nil {
                completion(nil, .noData)
            } else {
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
                    else {
                        completion(nil, .parsingError)
                        return
                }
                completion(json, nil)
                
                
            }
        })
    }
    
    /// Send a POST request to the specified URL with the specified data and cookie
    func post(urlString: String, data: Data, cookies: [HTTPCookie] = [], completion: @escaping ((Data?, URLResponse?, RessourceFetchingError?) -> Void)) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil, .invalidURL)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpShouldHandleCookies = true
        request.allHTTPHeaderFields = [:]
        request.httpMethod = "POST"
        request.httpBody = data
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        
        self.execRequest(request, completion: {(data, response, error) -> Void in
            completion(data, response, error)
        })
    }
    
    func get(urlString: String, cookies: [HTTPCookie] = [], completion: @escaping ((Data?, URLResponse?, RessourceFetchingError?) -> Void)) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil, .invalidURL)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpShouldHandleCookies = true
        request.allHTTPHeaderFields = [:]
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        
        
        self.execRequest(request, completion: {(data, response, error) -> Void in
            completion(data, response, error)
        })
    }
}




