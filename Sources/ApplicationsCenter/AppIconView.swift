import SwiftUI
import AppKit

struct AppIconView: View {
    let app: AppItem
    let icon: NSImage?
    let iconSize: CGFloat

    @State private var isHovering = false
    @State private var isPressed = false

    /// 根据 iconSize 动态计算 cellWidth，保证网格布局与图标尺寸协调
    static func cellWidth(for iconSize: CGFloat) -> CGFloat {
        iconSize + 36
    }

    private var cellWidth: CGFloat {
        Self.cellWidth(for: iconSize)
    }

    var body: some View {
        VStack(spacing: 8) {
            iconContent
                .scaleEffect(isPressed ? 0.92 : (isHovering ? 1.1 : 1.0))
                .shadow(
                    color: .black.opacity(isPressed ? 0.2 : (isHovering ? 0.3 : 0.15)),
                    radius: isPressed ? 2 : (isHovering ? 12 : 5),
                    y: isPressed ? 1 : (isHovering ? 5 : 2)
                )
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
                .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isHovering)

            Text(app.name)
                .font(.system(size: max(11, iconSize * 0.1875), weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
                .lineLimit(isHovering ? nil : 2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(maxWidth: cellWidth * 0.85)
                .animation(.easeOut(duration: 0.15), value: isHovering)
        }
        .frame(width: cellWidth, height: iconSize + 28)
        .contentShape(Rectangle())
        .onHover { hovering in isHovering = hovering }
        .help(app.name)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                app.launch()
                NSApp.hide(nil)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(app.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { app.launch() }
    }

    @ViewBuilder
    private var iconContent: some View {
        if let icon = icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: iconSize, height: iconSize)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: iconSize * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.08), .white.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: iconSize, height: iconSize)

                Image(systemName: "questionmark")
                    .font(.system(size: iconSize * 0.35, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }
}
