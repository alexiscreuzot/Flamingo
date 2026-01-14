//
//  HNClient.swift
//  Flamingo
//
//  Native replacement for HNScraper using URLSession
//

import Foundation

// MARK: - Models

struct HNPost: Identifiable {
    let id: String
    let title: String
    let url: URL?
    let urlDomain: String
    let username: String
    let created: String?
    let commentCount: Int
    let score: Int
    var isRead: Bool {
        get {
            guard let readIds = UserDefaults.standard.value(forKey: "read_status_key") as? [String] else {
                return false
            }
            return readIds.contains(id)
        }
        set {
            var readIds = UserDefaults.standard.value(forKey: "read_status_key") as? [String] ?? []
            if newValue && !readIds.contains(id) {
                readIds.append(id)
                UserDefaults.standard.set(readIds, forKey: "read_status_key")
            }
        }
    }
}

struct HNComment: Identifiable {
    let id: String
    let username: String?
    let text: String?
    let created: String?
    let level: Int
}

// MARK: - HN API Client

enum HNPageType: String {
    case front = "news"
    case news = "newest"
    case ask = "ask"
    case show = "show"
    case jobs = "jobs"
}

actor HNClient {
    static let shared = HNClient()
    
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public API
    
    func getPostsList(page: HNPageType) async throws -> [HNPost] {
        let endpoint: String
        switch page {
        case .front:
            endpoint = "\(baseURL)/topstories.json"
        case .news:
            endpoint = "\(baseURL)/newstories.json"
        case .ask:
            endpoint = "\(baseURL)/askstories.json"
        case .show:
            endpoint = "\(baseURL)/showstories.json"
        case .jobs:
            endpoint = "\(baseURL)/jobstories.json"
        }
        
        guard let url = URL(string: endpoint) else {
            throw HNError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let ids = try JSONDecoder().decode([Int].self, from: data)
        
        // Fetch first 30 posts
        let limitedIds = Array(ids.prefix(30))
        return try await fetchPosts(ids: limitedIds)
    }
    
    func getMoreItems(after lastId: String?, ids: [Int]) async throws -> [HNPost] {
        // Fetch next batch of posts
        let startIndex = ids.firstIndex(where: { String($0) == lastId }).map { $0 + 1 } ?? 0
        let nextIds = Array(ids.dropFirst(startIndex).prefix(20))
        return try await fetchPosts(ids: nextIds)
    }
    
    func getComments(forPostId postId: String) async throws -> [HNComment] {
        guard let url = URL(string: "\(baseURL)/item/\(postId).json") else {
            throw HNError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let item = try JSONDecoder().decode(HNItem.self, from: data)
        
        guard let kids = item.kids else {
            return []
        }
        
        return try await fetchComments(ids: kids, level: 0)
    }
    
    // MARK: - Private Helpers
    
    private func fetchPosts(ids: [Int]) async throws -> [HNPost] {
        try await withThrowingTaskGroup(of: HNPost?.self) { group in
            for id in ids {
                group.addTask {
                    try await self.fetchPost(id: id)
                }
            }
            
            var posts: [HNPost?] = []
            for try await post in group {
                posts.append(post)
            }
            
            // Maintain order
            return ids.compactMap { id in
                posts.compactMap { $0 }.first { $0.id == String(id) }
            }
        }
    }
    
    private func fetchPost(id: Int) async throws -> HNPost? {
        guard let url = URL(string: "\(baseURL)/item/\(id).json") else {
            return nil
        }
        
        let (data, _) = try await session.data(from: url)
        let item = try JSONDecoder().decode(HNItem.self, from: data)
        
        guard item.type == "story" || item.type == "job" else {
            return nil
        }
        
        let postURL = item.url.flatMap { URL(string: $0) }
        let domain = postURL?.host?.replacingOccurrences(of: "www.", with: "") ?? "news.ycombinator.com"
        
        return HNPost(
            id: String(item.id),
            title: item.title ?? "",
            url: postURL ?? URL(string: "https://news.ycombinator.com/item?id=\(item.id)"),
            urlDomain: domain,
            username: item.by ?? "",
            created: item.time.map { timeAgo(from: $0) },
            commentCount: item.descendants ?? 0,
            score: item.score ?? 0
        )
    }
    
    private func fetchComments(ids: [Int], level: Int) async throws -> [HNComment] {
        var allComments: [HNComment] = []
        
        for id in ids {
            guard let url = URL(string: "\(baseURL)/item/\(id).json") else { continue }
            
            do {
                let (data, _) = try await session.data(from: url)
                let item = try JSONDecoder().decode(HNItem.self, from: data)
                
                guard item.type == "comment", item.deleted != true, item.dead != true else {
                    continue
                }
                
                let comment = HNComment(
                    id: String(item.id),
                    username: item.by,
                    text: item.text,
                    created: item.time.map { timeAgo(from: $0) },
                    level: level
                )
                allComments.append(comment)
                
                // Fetch nested comments
                if let kids = item.kids {
                    let nestedComments = try await fetchComments(ids: kids, level: level + 1)
                    allComments.append(contentsOf: nestedComments)
                }
            } catch {
                continue
            }
        }
        
        return allComments
    }
    
    private func timeAgo(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - HN API Response Model

private struct HNItem: Decodable {
    let id: Int
    let type: String?
    let by: String?
    let time: Int?
    let title: String?
    let url: String?
    let text: String?
    let score: Int?
    let descendants: Int?
    let kids: [Int]?
    let deleted: Bool?
    let dead: Bool?
}

// MARK: - Errors

enum HNError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        }
    }
}
