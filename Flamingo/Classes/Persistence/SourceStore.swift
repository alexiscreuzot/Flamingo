//
//  SourceStore.swift
//  Flamingo
//
//  Native replacement for Realm - File-based persistence using Codable
//

import Foundation

// MARK: - Source Model

struct Source: Codable, Identifiable, Equatable {
    var id: String { domain }
    var domain: String
    var activated: Bool
    
    init(domain: String, activated: Bool = false) {
        self.domain = domain
        self.activated = activated
    }
    
    static func isAllowed(domain: String) -> Bool {
        if let source = SourceStore.shared.source(forDomain: domain) {
            return source.activated
        }
        return true // Allow by default if not in list
    }
}

// MARK: - Source Store

final class SourceStore {
    static let shared = SourceStore()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var sourcesURL: URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("sources.json")
    }
    
    private var cachedSources: [Source]?
    
    private init() {
        encoder.outputFormatting = .prettyPrinted
    }
    
    // MARK: - Public API
    
    var sources: [Source] {
        get {
            if let cached = cachedSources {
                return cached
            }
            let loaded = loadSources()
            cachedSources = loaded
            return loaded
        }
        set {
            cachedSources = newValue
            saveSources(newValue)
        }
    }
    
    func source(forDomain domain: String) -> Source? {
        return sources.first { $0.domain == domain }
    }
    
    func addOrUpdate(_ source: Source) {
        var currentSources = sources
        if let index = currentSources.firstIndex(where: { $0.domain == source.domain }) {
            currentSources[index] = source
        } else {
            currentSources.append(source)
        }
        sources = currentSources
    }
    
    func addOrUpdate(_ newSources: [Source]) {
        var currentSources = sources
        for source in newSources {
            if let index = currentSources.firstIndex(where: { $0.domain == source.domain }) {
                currentSources[index] = source
            } else {
                currentSources.append(source)
            }
        }
        sources = currentSources
    }
    
    func updateActivation(domain: String, activated: Bool) {
        var currentSources = sources
        if let index = currentSources.firstIndex(where: { $0.domain == domain }) {
            currentSources[index].activated = activated
            sources = currentSources
        }
    }
    
    func setAllActivated(_ activated: Bool) {
        var currentSources = sources
        for i in currentSources.indices {
            currentSources[i].activated = activated
        }
        sources = currentSources
    }
    
    func sortedSources() -> [Source] {
        return sources.sorted { $0.domain < $1.domain }
    }
    
    // MARK: - Initialization from Bundle
    
    func initializeFromBundleIfNeeded() {
        guard sources.isEmpty else { return }
        
        // Load from bundle's sources.json
        guard let bundleURL = Bundle.main.url(forResource: "sources", withExtension: "json"),
              let data = try? Data(contentsOf: bundleURL),
              let bundleSources = try? decoder.decode([Source].self, from: data) else {
            return
        }
        
        sources = bundleSources
    }
    
    // MARK: - Private Helpers
    
    private func loadSources() -> [Source] {
        guard fileManager.fileExists(atPath: sourcesURL.path),
              let data = try? Data(contentsOf: sourcesURL),
              let sources = try? decoder.decode([Source].self, from: data) else {
            return []
        }
        return sources
    }
    
    private func saveSources(_ sources: [Source]) {
        do {
            let data = try encoder.encode(sources)
            try data.write(to: sourcesURL, options: .atomic)
        } catch {
            print("Failed to save sources: \(error)")
        }
    }
    
    // MARK: - Export
    
    func toJSON() -> String {
        guard let data = try? encoder.encode(sources),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }
}
