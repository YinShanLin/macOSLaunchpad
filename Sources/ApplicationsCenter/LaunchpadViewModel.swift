import Cocoa

@MainActor
class LaunchpadViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var searchText = ""
    @Published var isLoading = true

    var filteredApps: [AppItem] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        Task { await loadApps() }
    }

    func loadApps() async {
        isLoading = true

        // I/O 与图标解码在后台线程执行，仅最终赋值回到主线程
        let directories = AppItem.appDirectories
        var scanned = await Task.detached(priority: .userInitiated) {
            AppItem.scanAll(in: directories)
        }.value

        scanned.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        var seen = Set<String>()
        var deduplicated: [AppItem] = []
        for app in scanned {
            if seen.insert(app.name).inserted {
                deduplicated.append(app)
            }
        }

        apps = deduplicated
        isLoading = false
    }
}
