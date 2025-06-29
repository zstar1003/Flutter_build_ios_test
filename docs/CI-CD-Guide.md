# CI/CD 自动构建指南

本项目配置了完整的 GitHub Actions 自动构建流程，支持 Android 和 iOS 双平台自动构建和发布。

## 🔧 配置的 Workflows

### 1. 开发测试 (`.github/workflows/dev-test.yml`)
- **触发条件**: 推送到主分支、Pull Request  
- **功能**: 代码分析 + 单元测试
- **运行环境**: ubuntu-latest
- **用途**: 日常开发验证

### 2. iOS 专用构建 (`.github/workflows/ios-build.yml`)
- **触发条件**: 创建标签、手动触发
- **构建产物**: `.ipa` 文件
- **运行环境**: macOS-latest

### 3. Android 专用构建 (`.github/workflows/android-build.yml`)
- **触发条件**: 创建标签、手动触发
- **构建产物**: Debug/Release `.apk` 文件 + `.aab` 文件
- **运行环境**: ubuntu-latest

### 4. 多平台构建 (`.github/workflows/multi-platform-build.yml`) **[推荐发布]**
- **触发条件**: 创建标签、手动触发
- **构建产物**: iOS `.ipa` + Android `.apk` 同时构建
- **运行环境**: macOS + Ubuntu 并行

## 🚀 如何使用

### 方法 1: 开发测试流程（日常开发）

```bash
# 1. 日常开发推送（触发快速测试）
git add .
git commit -m "feat: 添加新功能"
git push origin main

# GitHub Actions 会自动:
# - 运行代码分析 (flutter analyze)
# - 执行单元测试 (flutter test)
# - 验证代码质量
```

### 方法 2: 发布流程（版本发布）

```bash
# 1. 创建版本标签（触发完整构建）
git tag v1.0.0
git push origin v1.0.0

# 2. 自动触发构建和发布
# GitHub Actions 会自动:
# - 构建 iOS 和 Android 版本
# - 创建 GitHub Release
# - 上传安装包文件
```

### 方法 3: 手动触发构建

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择 "Multi-Platform Build & Release"
4. 点击 **Run workflow**
5. 选择要构建的平台 (iOS/Android)
6. 点击 **Run workflow** 开始构建

## 📱 安装应用

### Android 安装:

1. **下载 APK**:
   - 访问 [Releases](../../releases) 页面
   - 下载最新的 `FlutterApp_Android_*.apk` 文件

2. **安装到设备**:
   ```bash
   # 方法1: 直接在手机上安装
   - 允许"安装未知应用"
   - 点击 APK 文件安装
   
   # 方法2: 通过 ADB 安装
   adb install FlutterApp_Android_*.apk
   ```

### iOS 安装:

1. **下载 IPA**:
   - 访问 [Releases](../../releases) 页面
   - 下载最新的 `FlutterApp_iOS_*.ipa` 文件

2. **使用 Sideloadly 安装**:
   ```bash
   # 1. 下载 Sideloadly (Windows/Mac)
   # 2. 连接 iPhone 到电脑
   # 3. 拖拽 IPA 文件到 Sideloadly
   # 4. 输入 Apple ID 登录
   # 5. 点击安装
   ```

3. **信任开发者证书**:
   - 设置 → 通用 → VPN与设备管理
   - 找到您的 Apple ID
   - 点击"信任"

## 🔍 构建状态检查

### 查看构建进度:
1. GitHub 仓库 → **Actions** 标签
2. 查看正在运行的 workflow
3. 点击具体的 job 查看日志

### 下载构建产物:
1. 进入完成的 workflow run
2. 滚动到底部的 **Artifacts** 部分
3. 下载对应的构建文件

## ⚠️ 注意事项

### iOS 限制:
- **免费 Apple ID**: 应用有效期 7 天，需要重新安装
- **付费开发者账号**: 应用有效期 1 年
- 每个 Apple ID 最多安装 3 个应用

### Android 限制:
- 需要开启"允许安装未知应用"
- 某些设备可能需要额外的权限设置

## 🛠️ 自定义配置

### 修改应用信息:
```yaml
# 编辑 pubspec.yaml
name: your_app_name
description: "Your app description"
version: 1.0.0+1
```

### 修改构建配置:
```yaml
# 编辑 .github/workflows/multi-platform-build.yml
# 可以修改:
# - Flutter 版本
# - 构建参数
# - 文件名格式
# - 发布说明
```

## 📊 构建时间估算

| 平台 | 预计时间 | 资源消耗 |
|------|----------|----------|
| Android | 3-5 分钟 | 低 |
| iOS | 8-12 分钟 | 高 |
| 多平台 | 10-15 分钟 | 中等 |

## 🎯 最佳实践

### 开发流程:
1. **日常开发**: 频繁推送代码，依赖快速测试验证
2. **功能完成**: 确保所有测试通过后再考虑发布
3. **版本发布**: 使用语义化版本标签 `v1.0.0`, `v1.1.0`, `v2.0.0`

### 版本管理:
1. **为每个版本写详细的更新日志**
2. **在发布前进行充分测试**
3. **定期清理旧的 Artifacts**

### CI/CD 优化:
1. **推送代码时只运行快速测试** (节省资源)
2. **标签发布时构建完整应用包** (保证质量)
3. **合理使用手动触发** (特殊情况下的灵活构建)

---

🚀 **开始使用**: 推送代码并创建标签，让 CI/CD 为您自动构建和发布应用！ 