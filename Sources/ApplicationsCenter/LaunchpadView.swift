import SwiftUI

struct LaunchpadView: View {
    @StateObject private var viewModel = LaunchpadViewModel()
    @State private var isSearching = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.25),
                    Color(red: 0.10, green: 0.10, blue: 0.18),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.filteredApps) { app in
                                AppIconView(app: app)
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.bottom, 60)
                    }
                    .scrollIndicators(.hidden)
                }
            }
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
                .onHover { hovering in isSearching = hovering }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
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
        .frame(width: 400)
    }
}

