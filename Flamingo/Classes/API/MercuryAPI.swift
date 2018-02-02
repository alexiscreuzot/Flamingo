//
//  MercuryAPI.swift
//  Flamingo
//
//  Created by Alex on 31/01/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation
import Moya

public enum Mercury {
    case parser(url: String)
}

extension Mercury: TargetType {
    
    public var headers: [String : String]? {
        switch self {
        case .parser:
            return ["x-api-key":"efLOQxdLjWyofaR5bSsAwX98Mm3G8TyDWFFaIsJp"]
        }
    }
    
    public var baseURL: URL { return URL(string: "https://mercury.postlight.com")! }
    
    public var path: String {
        switch self {
        case .parser:
            return "/parser"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .parser(let url):
            return .requestParameters(parameters: ["url" : url], encoding: URLEncoding.default)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .parser:
            return "".data(using: String.Encoding.utf8)!
        }
    }
}
