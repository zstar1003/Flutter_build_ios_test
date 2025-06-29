# 我的第一个 Flutter 应用

这是一个支持多平台的 Flutter 应用，可以运行在 Android、iOS、Web 和桌面平台上。

## 🚀 快速开始

### 本地开发

```bash
# 获取依赖
flutter pub get

# 运行到 Android 设备
flutter run -d android

# 运行到 Web 浏览器
flutter run -d chrome

# 构建 Android APK
flutter build apk --release
```

### 📱 应用安装

#### Android 安装方法：
1. 从 [Releases](../../releases) 下载最新的 `.apk` 文件
2. 在设备设置中允许"安装未知应用"
3. 直接安装 APK 文件

#### iOS 安装方法：
1. 从 [Releases](../../releases) 下载最新的 `.ipa` 文件
2. 使用 **Sideloadly** 工具安装到 iPhone
3. 在 iPhone 设置中信任开发者证书

## 🔧 自动构建

本项目配置了 GitHub Actions 自动构建：

- **推送代码** → 快速测试验证（代码分析 + 单元测试）
- **创建标签** → 完整构建和发布到 Releases  
- **手动触发** → 可选择构建平台

### 开发流程：

```bash
# 1. 日常开发（触发快速测试）
git add .
git commit -m "feat: 添加新功能"
git push origin main

# 2. 发布新版本（触发完整构建）
git tag v1.0.0
git push origin v1.0.0
```

## 📋 功能特性

- ✅ 支持 Android 和 iOS 双平台
- ✅ 自动化 CI/CD 构建
- ✅ 热重载开发体验
- ✅ 现代化 Material Design 界面

## 🛠️ 开发环境

- Flutter 3.32.5
- Dart 3.8.1
- Android SDK API 35
- iOS 部署目标 12.0+

## 📚 学习资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [第一个 Flutter 应用](https://docs.flutter.dev/get-started/codelab)
- [Flutter 示例代码](https://docs.flutter.dev/cookbook)

---

🎯 **开始开发**: 克隆仓库，运行 `flutter run`，即可开始您的 Flutter 开发之旅！
