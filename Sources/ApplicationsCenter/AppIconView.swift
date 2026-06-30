import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppItem

    @State private var isHovering = false

    private let iconSize: CGFloat = 64
    /// 与 LaunchpadView 列数计算共享，保证两者一致，避免图标与网格错位。
    static let cellWidth: CGFloat = 100

    var body: some View {
        VStack(spacing: 6) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .shadow(
                    color: .black.opacity(isHovering ? 0.3 : 0.15),
                    radius: isHovering ? 12 : 5,
                    y: isHovering ? 5 : 2
                )
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isHovering)

            Text(app.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: Self.cellWidth * 0.85)
        }
        .frame(width: Self.cellWidth, height: Self.cellWidth + 16)
        .contentShape(Rectangle())
        .onHover { hovering in isHovering = hovering }
        .onTapGesture {
            app.launch()
            NSApp.hide(nil)
        }
        .accessibilityElement()
        .accessibilityLabel(app.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { app.launch() }
    }
}
