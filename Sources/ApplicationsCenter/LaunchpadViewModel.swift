import Cocoa

@MainActor
final class LaunchpadViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var iconImages: [String: NSImage] = [:]
    @Published var searchText = ""
    @Published var isLoading = true
    @Published var isRefreshing = false
    @Published var loadProgress: (current: Int, total: Int) = (0, 0)

    var filteredApps: [AppItem] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        Task { await loadApps() }
    }

    func loadApps() async {
        // 阶段 1：立即显示缓存数据
        if let cached = AppCacheManager.loadCachedAppList(), !cached.isEmpty {
            self.apps = cached
            self.isLoading = false
            let cachedIcons = await AppIconLoader.shared.loadIconsBatch(for: cached)
            self.iconImages = cachedIcons
        }

        // 阶段 2：后台扫描目录
        self.isRefreshing = true
        let directories = AppItem.appDirectories

        let fresh = await Task.detached(priority: .userInitiated) {
            AppItem.scanAll(in: directories)
        }.value

        var sorted = fresh
        sorted.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        var seen = Set<String>()
        var deduplicated: [AppItem] = []
        for app in sorted {
            if seen.insert(app.name).inserted {
                deduplicated.append(app)
            }
        }

        // 阶段 3：与缓存对比，仅增量加载图标
        if let cached = AppCacheManager.loadCachedAppList() {
            let diff = AppCacheManager.diff(cached: cached, fresh: deduplicated)

            if diff.added.isEmpty && diff.removed.isEmpty {
                self.isRefreshing = false
                return
            }

            let newIcons = await AppIconLoader.shared.loadIconsBatch(for: diff.added)
            for (id, icon) in newIcons {
                self.iconImages[id] = icon
            }
            for removed in diff.removed {
                self.iconImages.removeValue(forKey: removed.id)
            }
        } else {
            // 首次启动：加载全部图标
            let allIcons = await AppIconLoader.shared.loadIconsBatch(for: deduplicated) { [weak self] current, total in
                Task { @MainActor in
                    self?.loadProgress = (current, total)
                }
            }
            self.iconImages = allIcons
        }

        self.apps = deduplicated
        AppCacheManager.saveAppList(deduplicated)
        self.isLoading = false
        self.isRefreshing = false
    }
}
