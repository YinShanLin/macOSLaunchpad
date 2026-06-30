# 启动台 (Launchpad)

macOS Launchpad 复刻版。以窗口形式展示所有已安装 App，支持搜索、快速启动，还原原生 Launchpad 的操作体验。

## 功能

- **递归扫描** — 自动遍历 `/Applications`、`~/Applications`、`/System/Applications` 等目录
- **自适应网格** — 根据窗口宽度动态调整列数，拖拽缩放即时重排
- **窗口毛玻璃** — 系统原生 `NSVisualEffectView` 毛玻璃 + 半透明窗口，与 macOS 风格一致
- **名称本地化** — 通过 Spotlight 元数据获取 App 本地化显示名（如"计算器"、"系统设置"）
- **实时搜索** — 顶部搜索框输入即过滤，Enter 快捷启动首个匹配结果
- **键盘导航** — Escape 清空搜索 / 隐藏窗口，自动聚焦搜索框
- **即时隐藏** — 点击 App 图标自动隐藏本窗口，专注使用
- **悬停动效** — 图标悬停放大 + 阴影增强（弹簧动画）
- **无障碍支持** — VoiceOver 可访问，含 accessibilityLabel / action
- **全屏模式** — 支持 macOS 原生全屏

## 下载

[⬇️ 启动台.zip](启动台.zip) — 预编译 `.app` 包，解压后拖入 `/Applications` 即可使用。

> 要求 macOS 14.0+，仅限 Apple Silicon (arm64)。

## 自行构建

```bash
swift build -c release
```

或一键构建 `.app` 包：

```bash
./build_app.sh          # 构建
./build_app.sh --open   # 构建并启动
./build_app.sh --install # 构建、安装到 /Applications 并启动
```

## 技术栈

- **语言**: Swift 6
- **框架**: SwiftUI + AppKit
- **构建**: Swift Package Manager
- **图标**: Core Graphics 程序化生成

## 项目结构

```
├── Sources/ApplicationsCenter/
│   ├── ApplicationsCenterApp.swift   # @main 入口，窗口与毛玻璃配置
│   ├── LaunchpadView.swift           # 主视图（搜索、网格、键盘交互）
│   ├── AppIconView.swift             # App 图标组件（动效、无障碍）
│   ├── AppItem.swift                 # 数据模型（递归扫描、Spotlight 名称）
│   └── LaunchpadViewModel.swift      # ViewModel（后台加载、搜索过滤）
├── Scripts/
│   └── generate_icon.swift           # Core Graphics 图标生成脚本
├── build_app.sh                      # 编译 → 打包 → 签名一体化脚本
├── Package.swift                     # SPM 配置
└── README.md
```
