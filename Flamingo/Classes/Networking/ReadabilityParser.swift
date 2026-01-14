//
//  ReadabilityParser.swift
//  Flamingo
//
//  Native replacement for ReadabilityKit - extracts article metadata from HTML
//

import Foundation

struct ReadabilityData {
    let title: String?
    let description: String?
    let text: String?
    let topImage: String?
}

actor ReadabilityParser {
    static let shared = ReadabilityParser()
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }
    
    func parse(url: URL) async -> ReadabilityData? {
        do {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                return nil
            }
            
            return extractMetadata(from: html, baseURL: url)
        } catch {
            return nil
        }
    }
    
    private func extractMetadata(from html: String, baseURL: URL) -> ReadabilityData {
        let title = extractTitle(from: html)
        let description = extractDescription(from: html)
        let topImage = extractImage(from: html, baseURL: baseURL)
        let text = extractText(from: html)
        
        return ReadabilityData(
            title: title,
            description: description,
            text: text,
            topImage: topImage
        )
    }
    
    private func extractTitle(from html: String) -> String? {
        // Try og:title first
        if let ogTitle = extractMetaContent(from: html, property: "og:title") {
            return ogTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Try twitter:title
        if let twitterTitle = extractMetaContent(from: html, name: "twitter:title") {
            return twitterTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Fall back to <title> tag
        if let range = html.range(of: "<title[^>]*>(.*?)</title>", options: [.regularExpression, .caseInsensitive]) {
            let titleTag = String(html[range])
            return titleTag
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .removingHTMLEntities
        }
        
        return nil
    }
    
    private func extractDescription(from html: String) -> String? {
        // Try og:description first
        if let ogDesc = extractMetaContent(from: html, property: "og:description") {
            return ogDesc.trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
        }
        
        // Try twitter:description
        if let twitterDesc = extractMetaContent(from: html, name: "twitter:description") {
            return twitterDesc.trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
        }
        
        // Try meta description
        if let metaDesc = extractMetaContent(from: html, name: "description") {
            return metaDesc.trimmingCharacters(in: .whitespacesAndNewlines).removingHTMLEntities
        }
        
        return nil
    }
    
    private func extractImage(from html: String, baseURL: URL) -> String? {
        // Try og:image first
        if let ogImage = extractMetaContent(from: html, property: "og:image") {
            return resolveURL(ogImage, baseURL: baseURL)
        }
        
        // Try twitter:image
        if let twitterImage = extractMetaContent(from: html, name: "twitter:image") {
            return resolveURL(twitterImage, baseURL: baseURL)
        }
        
        // Try to find first large image in content
        let imgPattern = "<img[^>]+src=[\"']([^\"']+)[\"'][^>]*>"
        if let regex = try? NSRegularExpression(pattern: imgPattern, options: .caseInsensitive) {
            let nsString = html as NSString
            let results = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in results.prefix(5) {
                if match.numberOfRanges > 1 {
                    let srcRange = match.range(at: 1)
                    let src = nsString.substring(with: srcRange)
                    // Skip small images, icons, tracking pixels
                    if !src.contains("1x1") && !src.contains("pixel") && !src.contains("icon") && !src.contains("logo") {
                        return resolveURL(src, baseURL: baseURL)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractText(from html: String) -> String? {
        // Remove scripts and styles
        var cleanHTML = html
        cleanHTML = cleanHTML.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        cleanHTML = cleanHTML.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        cleanHTML = cleanHTML.replacingOccurrences(of: "<!--[\\s\\S]*?-->", with: "", options: .regularExpression)
        
        // Try to find article content
        let articlePatterns = [
            "<article[^>]*>([\\s\\S]*?)</article>",
            "<div[^>]*class=\"[^\"]*content[^\"]*\"[^>]*>([\\s\\S]*?)</div>",
            "<div[^>]*class=\"[^\"]*article[^\"]*\"[^>]*>([\\s\\S]*?)</div>",
            "<main[^>]*>([\\s\\S]*?)</main>"
        ]
        
        for pattern in articlePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = cleanHTML as NSString
                if let match = regex.firstMatch(in: cleanHTML, options: [], range: NSRange(location: 0, length: nsString.length)) {
                    if match.numberOfRanges > 1 {
                        let contentRange = match.range(at: 1)
                        let content = nsString.substring(with: contentRange)
                        return stripHTML(content)
                    }
                }
            }
        }
        
        // Fall back to body content
        if let bodyRange = cleanHTML.range(of: "<body[^>]*>([\\s\\S]*?)</body>", options: [.regularExpression, .caseInsensitive]) {
            let body = String(cleanHTML[bodyRange])
            return stripHTML(body)
        }
        
        return nil
    }
    
    private func extractMetaContent(from html: String, property: String) -> String? {
        let pattern = "<meta[^>]+property=[\"']\(property)[\"'][^>]+content=[\"']([^\"']+)[\"']|<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+property=[\"']\(property)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let nsString = html as NSString
            if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) {
                for i in 1..<match.numberOfRanges {
                    let range = match.range(at: i)
                    if range.location != NSNotFound {
                        return nsString.substring(with: range)
                    }
                }
            }
        }
        return nil
    }
    
    private func extractMetaContent(from html: String, name: String) -> String? {
        let pattern = "<meta[^>]+name=[\"']\(name)[\"'][^>]+content=[\"']([^\"']+)[\"']|<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+name=[\"']\(name)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let nsString = html as NSString
            if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: nsString.length)) {
                for i in 1..<match.numberOfRanges {
                    let range = match.range(at: i)
                    if range.location != NSNotFound {
                        return nsString.substring(with: range)
                    }
                }
            }
        }
        return nil
    }
    
    private func resolveURL(_ urlString: String, baseURL: URL) -> String? {
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            return urlString
        } else if urlString.hasPrefix("//") {
            return "https:" + urlString
        } else if urlString.hasPrefix("/") {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.path = urlString
            components?.query = nil
            return components?.url?.absoluteString
        }
        return URL(string: urlString, relativeTo: baseURL)?.absoluteString
    }
    
    private func stripHTML(_ html: String) -> String {
        var text = html
        // Remove tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        // Decode entities
        text = text.removingHTMLEntities
        // Normalize whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
