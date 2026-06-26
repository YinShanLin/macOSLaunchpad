# 启动台 (Launchpad)

macOS Launchpad 复刻版——以窗口形式展示所有已安装 App，支持搜索、快速启动。

## 功能

- 扫描 `/Applications`、`~/Applications`、`/System/Applications` 等系统目录
- 网格布局展示所有 App 图标和名称
- 悬停放大动效，单击启动
- 顶部搜索框实时过滤
- 深色不透明背景，原生毛玻璃元素
- 支持全屏模式

## 构建

```bash
swift build -c release
```

或一键构建 `.app` 包：

```bash
./build_app.sh        # 构建
./build_app.sh --open # 构建并启动
./build_app.sh -i     # 构建并安装到 /Applications
```

## 技术栈

- **语言**: Swift 6
- **框架**: SwiftUI + AppKit
- **构建**: Swift Package Manager
- **图标**: Core Graphics 程序化生成

## 项目结构

```
├── Sources/ApplicationsCenter/
│   ├── ApplicationsCenterApp.swift   # @main 入口，窗口配置
│   ├── LaunchpadView.swift           # 主视图（搜索 + 网格）
│   ├── AppIconView.swift             # App 图标组件
│   ├── AppItem.swift                 # 数据模型
│   └── LaunchpadViewModel.swift      # ViewModel
├── Scripts/
│   └── generate_icon.swift           # 图标生成脚本
├── build_app.sh                      # 构建打包脚本
└── Package.swift                     # SPM 配置
```
