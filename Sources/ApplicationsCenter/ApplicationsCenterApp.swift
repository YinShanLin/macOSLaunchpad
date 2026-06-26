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
            window.collectionBehavior = [.fullScreenPrimary]

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
}
