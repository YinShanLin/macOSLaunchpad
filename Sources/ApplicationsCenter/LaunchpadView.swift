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
                // 叠一层深色，降低毛玻璃透出的桌面亮度，使白色文字与图标清晰可读
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                searchBar
                    .padding(.top, 40)
                    .padding(.bottom, 24)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Spacer()
                } else if viewModel.filteredApps.isEmpty {
                    Spacer()
                    Text(viewModel.searchText.isEmpty ? "未找到应用" : "无匹配应用")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .shadow(color: .black.opacity(0.5), radius: 2)
                    Spacer()
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

    private var appGrid: some View {
        GeometryReader { geo in
            let count = max(4, min(12, Int((geo.size.width - 120) / AppIconView.cellWidth)))
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.filteredApps) { app in
                        AppIconView(app: app, icon: viewModel.iconImages[app.id])
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 18, weight: .medium))

            TextField("搜索应用...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.white)
                .tint(.white)
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
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: 480)
    }
}

/// 真正的窗口级毛玻璃背景。需配合窗口 `isOpaque = false` + `backgroundColor = .clear` 使用。
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
