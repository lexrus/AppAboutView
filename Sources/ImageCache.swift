import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

@MainActor
public class ImageCache: ObservableObject {
    public static let shared = ImageCache()

    private let cache = NSCache<NSString, PlatformImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        // Setup cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("AppAboutViewIconCache", isDirectory: true)

        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }

        // Configure NSCache limits
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 20 * 1024 * 1024 // 20 MB
    }

    /// Load an image from cache or download it if not cached
    public func loadImage(from urlString: String) async -> PlatformImage? {
        let cacheKey = cacheKey(for: urlString)

        // Check in-memory cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        // Check disk cache
        if let diskImage = loadImageFromDisk(cacheKey: cacheKey) {
            cache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }

        // Download image
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = PlatformImage(data: data) else { return nil }

            // Cache in memory
            cache.setObject(image, forKey: cacheKey as NSString)

            // Cache on disk
            saveImageToDisk(data: data, cacheKey: cacheKey)

            return image
        } catch {
            print("Failed to download image from \(urlString): \(error)")
            return nil
        }
    }

    /// Clear all cached images
    public func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private Methods

    private func cacheKey(for urlString: String) -> String {
        // Use a simple hash of the URL as the cache key
        return "\(urlString.hashValue)"
    }

    private func diskCacheURL(for cacheKey: String) -> URL {
        return cacheDirectory.appendingPathComponent(cacheKey)
    }

    private func loadImageFromDisk(cacheKey: String) -> PlatformImage? {
        let fileURL = diskCacheURL(for: cacheKey)

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = PlatformImage(data: data) else {
            return nil
        }

        return image
    }

    private func saveImageToDisk(data: Data, cacheKey: String) {
        let fileURL = diskCacheURL(for: cacheKey)
        try? data.write(to: fileURL)
    }
}
