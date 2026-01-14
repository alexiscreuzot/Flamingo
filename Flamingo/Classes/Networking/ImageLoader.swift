//
//  ImageLoader.swift
//  Flamingo
//
//  Native replacement for SDWebImage using URLSession + NSCache
//

import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    private var activeTasks: [URL: Task<UIImage?, Error>] = [:]
    
    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB
            diskCapacity: 200 * 1024 * 1024,    // 200 MB
            diskPath: "ImageCache"
        )
        self.session = URLSession(configuration: config)
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024  // 50 MB
    }
    
    // MARK: - Public API
    
    func loadImage(from url: URL) async throws -> UIImage? {
        let cacheKey = url.absoluteString as NSString
        
        // Check memory cache
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check if there's already a task for this URL
        if let existingTask = activeTasks[url] {
            return try await existingTask.value
        }
        
        // Create new download task
        let task = Task<UIImage?, Error> {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Cache the image
            let cost = data.count
            cache.setObject(image, forKey: cacheKey, cost: cost)
            
            return image
        }
        
        activeTasks[url] = task
        
        defer {
            activeTasks[url] = nil
        }
        
        return try await task.value
    }
    
    func cancelAllDownloads() {
        for (_, task) in activeTasks {
            task.cancel()
        }
        activeTasks.removeAll()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        let cacheKey = url.absoluteString as NSString
        return cache.object(forKey: cacheKey)
    }
}

// MARK: - UIImageView Extension

extension UIImageView {
    
    private static var taskKey: UInt8 = 0
    
    private var loadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &Self.taskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &Self.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func loadImage(
        from url: URL?,
        placeholder: UIImage? = nil,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        // Cancel previous task
        loadTask?.cancel()
        
        // Set placeholder
        self.image = placeholder
        
        guard let url = url else {
            completion?(nil)
            return
        }
        
        loadTask = Task { @MainActor in
            do {
                if let image = try await ImageLoader.shared.loadImage(from: url) {
                    if !Task.isCancelled {
                        self.image = image
                        completion?(image)
                    }
                } else {
                    completion?(nil)
                }
            } catch {
                if !Task.isCancelled {
                    completion?(nil)
                }
            }
        }
    }
    
    func cancelImageLoad() {
        loadTask?.cancel()
        loadTask = nil
    }
}
