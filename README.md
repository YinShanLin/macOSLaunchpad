<p align="center">
  <img src="启动台.app/Contents/Resources/AppIcon.icns" width="120" />
</p>

<h1 align="center">启动台</h1>

<p align="center">
  <b>macOS Launchpad 复刻版</b><br>
  以窗口形式展示所有已安装 App，支持搜索、快速启动，还原原生 Launchpad 的操作体验。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0+-blue?logo=apple" />
  <img src="https://img.shields.io/badge/Swift-6-orange?logo=swift" />
  <img src="https://img.shields.io/badge/arch-ARM64-black?logo=apple" />
  <img src="https://img.shields.io/badge/build-SPM-green" />
</p>

---

## 🚀 快速开始

### 下载

> [**📥 下载最新版本**](启动台.zip) — 解压后拖入 `/Applications` 即可使用

| 平台 | 架构 | 要求 |
|:---:|:---:|:---:|
| macOS 14.0+ | ARM64 (Apple Silicon) | — |

### 从源码构建

```bash
git clone git@github.com:YinShanLin/macOSLaunchpad.git
cd macOSLaunchpad
./build_app.sh --open
```

---

## ✨ 功能特性

<table>
<tr>
<td width="50%" valign="top">

### ⚡ 极速体验

- **三级图标缓存** — 内存 → 磁盘 → NSWorkspace，首次后毫秒级加载
- **增量刷新** — App 列表缓存到磁盘，二次启动比对差异，仅加载新增图标
- **后台线程扫描** — `Task.detached` 异步加载，不阻塞 UI

</td>
<td width="50%" valign="top">

### 🎨 原生视觉

- **窗口毛玻璃** — 系统原生 `NSVisualEffectView` 毛玻璃 + 半透明窗口
- **响应式布局** — 三档自适应图标大小（48/64/80px），随窗口宽度动态调整
- **悬停动效** — 图标悬停放大 + 阴影增强（弹簧动画）

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 🔍 智能搜索

- **实时过滤** — 搜索框聚焦高亮 + 渐变动画，输入即过滤
- **搜索建议** — 无匹配结果时自动推荐相关应用
- **键盘导航** — Enter 快捷启动首个结果，Escape 清空/隐藏

</td>
<td width="50%" valign="top">

### 🛡️ 可靠体验

- **名称本地化** — Spotlight 元数据获取本地化显示名（如「计算器」）
- **递归扫描** — 覆盖 `/Applications`、`~/Applications`、`/System/Applications` 等目录
- **无障碍支持** — VoiceOver 可访问，含 accessibilityLabel / action / tooltip

</td>
</tr>
</table>

---

## 🛠️ 自行构建

```bash
# 仅编译
swift build -c release

# 一键构建 .app 包
./build_app.sh

# 构建并启动
./build_app.sh --open

# 构建、安装到 /Applications 并启动
./build_app.sh --install
```

---

## 🏗️ 技术架构

| 层级 | 技术 | 说明 |
|:---:|:---:|:---|
| **语言** | Swift 6 | 并发安全（async/await、actor） |
| **UI** | SwiftUI + AppKit | 原生系统级渲染 |
| **构建** | SPM | Swift Package Manager |
| **图标** | Core Graphics | 程序化生成应用图标 |

---

## 📁 项目结构

```
macOSLaunchpad/
│
├── Sources/ApplicationsCenter/
│   ├── ApplicationsCenterApp.swift    ← @main 入口，窗口与毛玻璃配置
│   ├── LaunchpadView.swift            ← 主视图（搜索、网格、键盘交互）
│   ├── AppIconView.swift              ← App 图标组件（动效、无障碍）
│   ├── AppItem.swift                  ← 数据模型（递归扫描、Spotlight 名称）
│   ├── AppCacheManager.swift          ← 磁盘缓存 + 增量 diff
│   ├── AppIconLoader.swift            ← 三级图标缓存（actor 并发）
│   └── LaunchpadViewModel.swift       ← ViewModel（两阶段加载、增量刷新）
│
├── Scripts/
│   └── generate_icon.swift            ← Core Graphics 图标生成脚本
│
├── build_app.sh                       ← 编译 → 打包 → 签名一体化脚本
├── Package.swift                      ← SPM 配置
├── 启动台.zip                          ← 预编译 `.app` 包
└── README.md
```

---

## 📄 许可证

MIT License

---

<p align="center">
  <sub>Made with ❤️ for macOS</sub>
</p>
