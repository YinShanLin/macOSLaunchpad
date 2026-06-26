import Cocoa

struct AppItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    let icon: NSImage

    init?(url: URL) {
        guard url.pathExtension == "app" else { return nil }
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return nil }
        self.url = url
        self.name = fm.displayName(atPath: url.path)
        self.icon = Self.loadIcon(from: url)
    }

    private static func loadIcon(from url: URL) -> NSImage {
        if let bundle = Bundle(url: url) {
            let iconName: String? = {
                if let raw = bundle.infoDictionary?["CFBundleIconFile"] as? NSString {
                    let name = raw.deletingPathExtension
                    if let path = bundle.path(forResource: name, ofType: "icns") {
                        return path
                    }
                }
                if let raw = bundle.infoDictionary?["CFBundleIconFile"] as? NSString {
                    let name = raw.deletingPathExtension
                    if let path = bundle.path(forResource: name, ofType: nil) {
                        return path
                    }
                }
                return nil
            }()
            if let path = iconName, let image = NSImage(contentsOfFile: path) {
                return image
            }
        }
        return NSWorkspace.shared.icon(forFile: url.path)
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
}
