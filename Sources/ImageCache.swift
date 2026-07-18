import CryptoKit
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

    /// Bumped whenever the on-disk cache key format changes. A mismatch causes the
    /// whole cache directory to be wiped on next launch, so stale orphan files (from
    /// the old `String.hashValue` scheme, which was randomized per process) are purged.
    private static let cacheVersion = 2
    private static let versionFileName = ".cache-version"

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

        // Migrate / purge if the on-disk format changed.
        migrateCacheIfNeeded()
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

    /// Synchronously look up an image that is already cached (in memory or on disk).
    /// Performs no network I/O. Returns `nil` if the image is not yet cached.
    public func cachedImage(for urlString: String) -> PlatformImage? {
        let cacheKey = cacheKey(for: urlString)

        if let memoryImage = cache.object(forKey: cacheKey as NSString) {
            return memoryImage
        }

        if let diskImage = loadImageFromDisk(cacheKey: cacheKey) {
            cache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }

        return nil
    }

    /// Prefetch a batch of icon URLs into the disk cache in the background.
    /// Skips URLs that are already cached. Fire-and-forget; does not touch the UI.
    public func prefetch(urlStrings: [String]) {
        guard !urlStrings.isEmpty else { return }

        Task { [weak self] in
            for urlString in urlStrings {
                guard let self else { return }
                // Skip if already cached in memory or on disk.
                if self.cachedImage(for: urlString) != nil { continue }

                // `loadImage` hits the network only when nothing is cached.
                _ = await self.loadImage(from: urlString)
            }
        }
    }

    /// Clear all cached images
    public func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private Methods

    /// Deterministic, process-independent cache key derived from the URL string via
    /// SHA-1. `String.hashValue` was used previously but is randomized per process,
    /// which made the disk cache effectively useless (a new file per launch).
    private func cacheKey(for urlString: String) -> String {
        let digest = Insecure.SHA1.hash(data: Data(urlString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
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

    /// Wipe and recreate the cache directory when the on-disk format version changes,
    /// removing orphan files left behind by the old `hashValue`-based keys.
    private func migrateCacheIfNeeded() {
        let versionURL = cacheDirectory.appendingPathComponent(Self.versionFileName)
        let storedVersion = try? String(contentsOf: versionURL, encoding: .utf8)
        let current = String(Self.cacheVersion)

        if storedVersion == current { return }

        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? current.write(to: versionURL, atomically: true, encoding: .utf8)
    }
}
