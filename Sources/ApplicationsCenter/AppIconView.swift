import SwiftUI

struct AppIconView: View {
    let app: AppItem

    @State private var isHovering = false

    private let iconSize: CGFloat = 64
    private let cellWidth: CGFloat = 96

    var body: some View {
        VStack(spacing: 6) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                .frame(maxWidth: cellWidth * 0.85)
        }
        .frame(width: cellWidth, height: cellWidth + 16)
        .contentShape(Rectangle())
        .onHover { hovering in isHovering = hovering }
        .onTapGesture { app.launch() }
    }
}
