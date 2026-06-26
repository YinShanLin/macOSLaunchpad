import Cocoa

let side = 1024
let scale: CGFloat = 1.0
let bgColors: [NSColor] = [
    NSColor(red: 46/255, green: 46/255, blue: 64/255, alpha: 1),    // #2E2E40
    NSColor(red: 22/255, green: 22, blue: 40/255, alpha: 1),   // #161628
]
let cellColors: [NSColor] = [
    NSColor(red: 10/255,  green: 132/255, blue: 255/255, alpha: 1),  // blue
    NSColor(red: 48/255,  green: 209/255, blue: 88/255,  alpha: 1),  // green
    NSColor(red: 255/255, green: 159/255, blue: 10/255,  alpha: 1),  // orange
    NSColor(red: 191/255, green: 90/255,  blue: 242/255, alpha: 1),  // purple
    NSColor(red: 255/255, green: 69/255,  blue: 58/255,  alpha: 1),  // red
    NSColor(red: 255/255, green: 214/255, blue: 10/255,  alpha: 1),  // yellow
    NSColor(red: 90/255,  green: 200/255, blue: 250/255, alpha: 1),  // teal
    NSColor(red: 255/255, green: 45/255,  blue: 85/255,  alpha: 1),  // pink
    NSColor(red: 88/255,  green: 86/255,  blue: 214/255, alpha: 1),  // indigo
]

let rect = CGRect(x: 0, y: 0, width: side, height: side)

let image = NSImage(size: rect.size, flipped: false) { _ in
    guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

    // --- clip to app-icon rounded rect ---
    let iconPath = CGPath(roundedRect: rect.insetBy(dx: 4, dy: 4),
                          cornerWidth: 185, cornerHeight: 185, transform: nil)
    ctx.addPath(iconPath)
    ctx.clip()

    // --- background gradient ---
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: bgColors.map { $0.cgColor } as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: 0, y: 0),
                           end: CGPoint(x: 0, y: rect.height),
                           options: [])

    // --- outer subtle border ring ---
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.12).cgColor)
    ctx.setLineWidth(2)
    let borderPath = CGPath(roundedRect: rect.insetBy(dx: 5, dy: 5),
                            cornerWidth: 183, cornerHeight: 183, transform: nil)
    ctx.addPath(borderPath)
    ctx.strokePath()

    // --- draw 3x3 grid ---
    let cellW: CGFloat = 160
    let gap: CGFloat = 28
    let gridW = 3 * cellW + 2 * gap
    let ox = (rect.width - gridW) / 2
    let oy = (rect.height - gridW) / 2 - 4
    let corner: CGFloat = 32

    for row in 0..<3 {
        for col in 0..<3 {
            let idx = row * 3 + col
            let cx = ox + CGFloat(col) * (cellW + gap)
            let cy = oy + CGFloat(row) * (cellW + gap)
            let cellRect = CGRect(x: cx, y: cy, width: cellW, height: cellW)

            // cell background
            let cellRounded = CGPath(roundedRect: cellRect,
                                     cornerWidth: corner, cornerHeight: corner,
                                     transform: nil)
            ctx.addPath(cellRounded)
            ctx.setFillColor(cellColors[idx].cgColor)
            ctx.fillPath()

            // top highlight gloss
            ctx.addPath(cellRounded)
            ctx.clip()
            let glossGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [NSColor.white.withAlphaComponent(0.35).cgColor,
                         NSColor.white.withAlphaComponent(0.0).cgColor] as CFArray,
                locations: [0, 0.55]
            )!
            ctx.drawLinearGradient(glossGradient,
                                   start: CGPoint(x: 0, y: cellRect.maxY),
                                   end: CGPoint(x: 0, y: cellRect.minY),
                                   options: [])
            ctx.resetClip()

            // bottom inner shadow ring
            ctx.setStrokeColor(NSColor.black.withAlphaComponent(0.25).cgColor)
            ctx.setLineWidth(1)
            let shadowPath = CGPath(roundedRect: cellRect.insetBy(dx: 0.5, dy: 0.5),
                                    cornerWidth: corner, cornerHeight: corner, transform: nil)
            ctx.addPath(shadowPath)
            ctx.strokePath()

            // 2nd color accent (smaller inner rect)
            if idx == 4 { // center cell — subtle accent
                let inner = cellRect.insetBy(dx: 32, dy: 32)
                let innerPath = CGPath(roundedRect: inner,
                                       cornerWidth: 16, cornerHeight: 16, transform: nil)
                ctx.addPath(innerPath)
                ctx.setFillColor(NSColor.white.withAlphaComponent(0.15).cgColor)
                ctx.fillPath()

                // small triangle "play" inside center
                ctx.move(to: CGPoint(x: inner.midX - 12, y: inner.midY + 16))
                ctx.addLine(to: CGPoint(x: inner.midX + 18, y: inner.midY))
                ctx.addLine(to: CGPoint(x: inner.midX - 12, y: inner.midY - 16))
                ctx.closePath()
                ctx.setFillColor(NSColor.white.withAlphaComponent(0.7).cgColor)
                ctx.fillPath()
            }
        }
    }

    // --- subtle overall top shine ---
    ctx.resetClip()
    ctx.addPath(iconPath)
    ctx.clip()
    let shineGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [NSColor.white.withAlphaComponent(0.08).cgColor,
                 NSColor.white.withAlphaComponent(0.0).cgColor] as CFArray,
        locations: [0, 0.3]
    )!
    ctx.drawLinearGradient(shineGradient,
                           start: CGPoint(x: 0, y: rect.height),
                           end: CGPoint(x: 0, y: rect.height * 0.6),
                           options: [])

    return true
}

// --- output ---
let outDir = URL(fileURLWithPath: CommandLine.arguments[1])
let fm = FileManager.default
try? fm.createDirectory(at: outDir, withIntermediateDirectories: true)

let sizes: [(name: String, size: Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]

for (name, size) in sizes {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: .alphaFirst,
        bytesPerRow: 0,
        bitsPerPixel: 32
    )!
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    let pngData = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
    try pngData.write(to: outDir.appendingPathComponent("\(name).png"))
    print("  ✓ \(name).png  \(size)×\(size)")
}
