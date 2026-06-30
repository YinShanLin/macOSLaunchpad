import Cocoa
import CoreServices
import CommonCrypto

struct AppItem: Identifiable, Hashable, Codable, @unchecked Sendable {
    let name: String
    let url: URL
    let modificationDate: Date?
    let iconCacheKey: String

    var id: String { url.path }

    init?(url: URL) {
        guard url.pathExtension == "app" else { return nil }

        let attrs = (try? FileManager.default.attributesOfItem(atPath: url.path)) ?? [:]
        self.modificationDate = attrs[.modificationDate] as? Date
        self.url = url
        self.name = Self.displayName(for: url)

        let pathData = url.path.data(using: .utf8) ?? Data()
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        pathData.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(pathData.count), &hash) }
        let pathHash = hash.prefix(8).map { String(format: "%02x", $0) }.joined()
        let modStamp = Int64((modificationDate?.timeIntervalSince1970 ?? 0) * 1000)
        self.iconCacheKey = "\(pathHash)_\(modStamp)"
    }

    /// 优先用 Spotlight 元数据 kMDItemDisplayName（与原生启动台一致，返回本地化名如"计算器"），
    /// 并去掉 `.app` 后缀；失败回退到文件显示名。
    private static func displayName(for url: URL) -> String {
        if let item = MDItemCreate(kCFAllocatorDefault, url.path as CFString),
           let raw = MDItemCopyAttribute(item, kMDItemDisplayName) as? String,
           !raw.isEmpty {
            return (raw as NSString).deletingPathExtension
        }
        return fmDisplayName(url)
    }

    private static func fmDisplayName(_ url: URL) -> String {
        let name = FileManager.default.displayName(atPath: url.path)
        return (name as NSString).deletingPathExtension
    }

    func launch() {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: config)
    }

    static let appDirectories: [String] = [
        "/Applications",
        "\(NSHomeDirectory())/Applications",
        "/System/Applications",
        "/System/Library/CoreServices/Applications",
    ]

    /// 递归扫描目录收集所有 `.app`。`.skipsPackageDescendants` 让枚举器遇到
    /// bundle（如 `.app`）即跳过其内部，无需手动 skipDescendants。
    nonisolated static func scanAll(in directories: [String]) -> [AppItem] {
        let fm = FileManager.default
        var result: [AppItem] = []
        var seenPaths = Set<String>()

        for dir in directories {
            let dirURL = URL(fileURLWithPath: dir)
            guard let enumerator = fm.enumerator(
                at: dirURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for case let fileURL as URL in enumerator {
                guard fileURL.pathExtension == "app" else { continue }
                guard seenPaths.insert(fileURL.path).inserted else { continue }
                if let app = AppItem(url: fileURL) {
                    result.append(app)
                }
            }
        }
        return result
    }
}
