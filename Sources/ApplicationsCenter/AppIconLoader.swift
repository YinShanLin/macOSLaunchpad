import Cocoa

actor AppIconLoader {
    static let shared = AppIconLoader()

    private let iconCacheDir: URL = {
        AppCacheManager.cacheDir.appendingPathComponent("icons", isDirectory: true)
    }()

    private var memoryCache: [String: NSImage] = [:]

    private func ensureIconCacheDir() {
        let fm = FileManager.default
        guard !fm.fileExists(atPath: iconCacheDir.path) else { return }
        try? fm.createDirectory(at: iconCacheDir, withIntermediateDirectories: true)
    }

    /// 三级缓存加载图标：内存 → 磁盘 → NSWorkspace
    func loadIcon(for app: AppItem) async -> NSImage? {
        // 1. 内存缓存
        if let cached = memoryCache[app.iconCacheKey] {
            return cached
        }

        // 2. 磁盘缓存
        if let diskIcon = loadFromDisk(cacheKey: app.iconCacheKey) {
            memoryCache[app.iconCacheKey] = diskIcon
            return diskIcon
        }

        // 3. NSWorkspace（最慢，后台线程执行）
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let icon = NSWorkspace.shared.icon(forFile: app.url.path)
                let resized = Self.resizeIcon(icon, to: 64)

                Task.detached { [weak self] in
                    await self?.saveToDisk(image: resized, cacheKey: app.iconCacheKey)
                }

                Task { @MainActor in
                    await self.setMemoryCache(key: app.iconCacheKey, image: resized)
                    continuation.resume(returning: resized)
                }
            }
        }
    }

    /// 并行批量加载图标
    func loadIconsBatch(
        for apps: [AppItem],
        onProgress: (@Sendable (Int, Int) -> Void)? = nil
    ) async -> [String: NSImage] {
        var results: [String: NSImage] = [:]
        let total = apps.count
        var completed = 0

        await withTaskGroup(of: (String, NSImage?).self) { group in
            for app in apps {
                group.addTask {
                    let icon = await self.loadIcon(for: app)
                    return (app.id, icon)
                }
            }

            for await (id, icon) in group {
                completed += 1
                if let icon = icon {
                    results[id] = icon
                }
                onProgress?(completed, total)
            }
        }

        return results
    }

    // MARK: - 私有方法

    private func setMemoryCache(key: String, image: NSImage) {
        memoryCache[key] = image
    }

    private func loadFromDisk(cacheKey: String) -> NSImage? {
        let url = iconCacheDir.appendingPathComponent("\(cacheKey).png")
        return NSImage(contentsOf: url)
    }

    private func saveToDisk(image: NSImage, cacheKey: String) {
        ensureIconCacheDir()
        let url = iconCacheDir.appendingPathComponent("\(cacheKey).png")
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { return }
        try? png.write(to: url, options: .atomic)
    }

    private static func resizeIcon(_ image: NSImage, to size: CGFloat) -> NSImage {
        let newSize = NSSize(width: size, height: size)
        let resized = NSImage(size: newSize)
        resized.lockFocus()
        image.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1.0
        )
        resized.unlockFocus()
        return resized
    }
}
