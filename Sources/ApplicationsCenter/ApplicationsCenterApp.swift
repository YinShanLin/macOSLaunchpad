import SwiftUI

@main
struct ApplicationsCenterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup(id: "launchpad") {
            LaunchpadView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            applyWindowSettings(window)
        } else {
            // SwiftUI WindowGroup 的窗口在此时可能尚未创建，等其出现后配置（一次性）。
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleWindowDidBecomeKey(_:)),
                name: NSWindow.didBecomeKeyNotification,
                object: nil
            )
        }
    }

    @objc private func handleWindowDidBecomeKey(_ note: Notification) {
        guard let window = note.object as? NSWindow else { return }
        NotificationCenter.default.removeObserver(
            self, name: NSWindow.didBecomeKeyNotification, object: nil
        )
        applyWindowSettings(window)
    }

    private func applyWindowSettings(_ window: NSWindow) {
        window.collectionBehavior = [.fullScreenPrimary]
        window.isOpaque = false
        window.backgroundColor = .clear

        if let screen = NSScreen.main {
            let w = screen.visibleFrame.width * 0.85
            let h = screen.visibleFrame.height * 0.85
            let x = (screen.visibleFrame.width - w) / 2 + screen.visibleFrame.minX
            let y = (screen.visibleFrame.height - h) / 2 + screen.visibleFrame.minY
            window.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true)
        }

        window.makeKeyAndOrderFront(nil)
    }
}
