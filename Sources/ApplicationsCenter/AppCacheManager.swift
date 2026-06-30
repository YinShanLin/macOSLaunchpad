import Foundation

enum AppCacheManager {
    static let cacheDir: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("ApplicationsCenter", isDirectory: true)
    }()

    private static let appListURL: URL = {
        cacheDir.appendingPathComponent("app_list.json")
    }()

    static func ensureCacheDir() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: cacheDir.path) {
            try fm.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }

    static func loadCachedAppList() -> [AppItem]? {
        guard FileManager.default.fileExists(atPath: appListURL.path),
              let data = try? Data(contentsOf: appListURL) else { return nil }
        return try? JSONDecoder().decode([AppItem].self, from: data)
    }

    static func saveAppList(_ apps: [AppItem]) {
        guard let data = try? JSONEncoder().encode(apps) else { return }
        try? ensureCacheDir()
        try? data.write(to: appListURL, options: .atomic)
    }

    /// 对比缓存与新鲜扫描结果，返回 (新增, 移除, 未变)
    static func diff(cached: [AppItem], fresh: [AppItem]) -> (
        added: [AppItem], removed: [AppItem], unchanged: [AppItem]
    ) {
        let cachedSet = Set(cached.map(\.url.path))
        let freshSet = Set(fresh.map(\.url.path))

        let added = fresh.filter { !cachedSet.contains($0.url.path) }
        let removed = cached.filter { !freshSet.contains($0.url.path) }
        let unchanged = fresh.filter { cachedSet.contains($0.url.path) }

        return (added, removed, unchanged)
    }
}
