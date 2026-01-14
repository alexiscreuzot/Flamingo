//
//  JSONSerializer.swift
//  Flamingo
//
//  Created by Alexis Creuzot on 27/09/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import Foundation

class JSONSerializer {
    static func serializeSources() {
        // Sources are now initialized via SourceStore.shared.initializeFromBundleIfNeeded()
        // This method is kept for compatibility but no longer needed
        SourceStore.shared.initializeFromBundleIfNeeded()
    }
}
