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
        var allApps: [AppItem] = []

        for dir in AppItem.appDirectories {
            let fm = FileManager.default
            guard let contents = try? fm.contentsOfDirectory(atPath: dir) else { continue }
            for file in contents {
                let url = URL(fileURLWithPath: dir).appendingPathComponent(file)
                if let app = AppItem(url: url) {
                    allApps.append(app)
                }
            }
        }

        allApps.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        var seen = Set<String>()
        var deduplicated: [AppItem] = []
        for app in allApps {
            if seen.insert(app.name).inserted {
                deduplicated.append(app)
            }
        }

        apps = deduplicated
        isLoading = false
    }
}
