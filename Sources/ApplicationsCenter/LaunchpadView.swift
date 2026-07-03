import SwiftUI
import AppKit

struct LaunchpadView: View {
    @StateObject private var viewModel = LaunchpadViewModel()
    @FocusState private var searchFocused: Bool

    var body: some View {
        ZStack {
            ZStack {
                VisualEffectView(material: .sheet, blending: .behindWindow)
                    .ignoresSafeArea()
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                searchBar
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredApps.isEmpty {
                    emptyView
                } else {
                    appGrid
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                searchFocused = true
            }
        }
        .background {
            Button("") {
                if !viewModel.searchText.isEmpty {
                    viewModel.searchText = ""
                    searchFocused = true
                } else {
                    NSApp.hide(nil)
                }
            }
            .keyboardShortcut(.escape)
            .hidden()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white.opacity(0.9))

            if viewModel.loadProgress.total > 0 {
                VStack(spacing: 8) {
                    Text("正在加载应用...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))

                    progressBar
                }
            } else {
                Text("正在扫描应用...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var progressBar: some View {
        let progress = viewModel.loadProgress.total > 0
            ? Double(viewModel.loadProgress.current) / Double(viewModel.loadProgress.total)
            : 0.0

        return VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.15))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.4))
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            .frame(maxWidth: 240)

            Text("\(viewModel.loadProgress.current) / \(viewModel.loadProgress.total)")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()

            if viewModel.searchText.isEmpty {
                Image(systemName: "questionmark.app")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(.white.opacity(0.4))
                    .shadow(color: .black.opacity(0.3), radius: 4)

                Text("未检测到已安装应用")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.5), radius: 2)

                Text("请确认 /Applications 目录中存在应用")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.3), radius: 1)

                Button {
                    Task { await viewModel.loadApps() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                        Text("重新扫描")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .thin))
                    .foregroundColor(.white.opacity(0.4))
                    .shadow(color: .black.opacity(0.3), radius: 4)

                Text("没有找到匹配的应用")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.5), radius: 2)

                let suggestions = searchSuggestions
                if !suggestions.isEmpty {
                    VStack(spacing: 6) {
                        Text("你是否在找：")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))

                        ForEach(suggestions.prefix(3), id: \.self) { name in
                            Button {
                                viewModel.searchText = name
                            } label: {
                                Text(name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchSuggestions: [String] {
        let query = viewModel.searchText.lowercased()
        return viewModel.apps
            .map { $0.name }
            .filter { $0.lowercased().contains(query) || query.contains($0.lowercased().prefix(3)) }
            .sorted { lhs, rhs in
                let lMatch = lhs.lowercased().hasPrefix(query)
                let rMatch = rhs.lowercased().hasPrefix(query)
                if lMatch != rMatch { return lMatch }
                return lhs.localizedStandardCompare(rhs) == .orderedAscending
            }
    }

    // MARK: - App Grid

    private var appGrid: some View {
        GeometryReader { geo in
            let iconSize = responsiveIconSize(for: geo.size.width)
            let hPadding = max(32, min(80, geo.size.width * 0.06))
            let count = max(4, min(12, Int((geo.size.width - hPadding * 2) / AppIconView.cellWidth(for: iconSize))))
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: count)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredApps) { app in
                        AppIconView(app: app, icon: viewModel.iconImages[app.id], iconSize: iconSize)
                    }
                }
                .padding(.horizontal, hPadding)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.automatic)
        }
    }

    private func responsiveIconSize(for width: CGFloat) -> CGFloat {
        if width < 900 { return 48 }
        if width > 1200 { return 80 }
        return 64
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(searchFocused ? 0.9 : 0.7))
                .font(.system(size: 14, weight: .medium))

            TextField("搜索应用...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.95))
                .tint(.white.opacity(0.9))
                .focused($searchFocused)
                .submitLabel(.go)
                .onSubmit {
                    if let first = viewModel.filteredApps.first {
                        first.launch()
                        NSApp.hide(nil)
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    searchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    // 视觉 hover 态由修饰符处理
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(searchFocused ? 0.28 : 0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(searchFocused ? .white.opacity(0.5) : .white.opacity(0.3), lineWidth: searchFocused ? 1.5 : 1)
        )
        .shadow(color: searchFocused ? .white.opacity(0.08) : .clear, radius: 6)
        .animation(.easeOut(duration: 0.2), value: searchFocused)
        .frame(maxWidth: 400)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blending: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blending
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blending
    }
}
