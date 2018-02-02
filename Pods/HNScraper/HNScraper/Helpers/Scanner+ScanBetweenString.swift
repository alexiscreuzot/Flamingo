//
//  Scanner+ScanBetweenString.swift
//  HNScraper
//
//  Created by Stéphane Sercu on 29/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation
extension Scanner {
    func scanBetweenString(stringA: String, stringB: String, into: AutoreleasingUnsafeMutablePointer<NSString?>?) {
        var trash: NSString? = ""
        self.scanUpTo(stringA, into: &trash)
        self.scanString(stringA, into: &trash)
        self.scanUpTo(stringB, into: into)
    }
}
