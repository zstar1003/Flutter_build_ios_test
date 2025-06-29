# Flutter 本地构建 PowerShell 脚本
$Host.UI.RawUI.WindowTitle = "Flutter 本地构建"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "      Flutter 本地构建脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Flutter 环境
Write-Host "🔍 检查 Flutter 环境..." -ForegroundColor Yellow
flutter doctor
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter 环境检查失败！" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 获取依赖
Write-Host ""
Write-Host "📦 获取依赖包..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依赖包获取失败！" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 运行测试
Write-Host ""
Write-Host "🧪 运行测试..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 测试失败！" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 清理构建
Write-Host ""
Write-Host "🧹 清理旧的构建文件..." -ForegroundColor Yellow
flutter clean

# 构建 Android APK
Write-Host ""
Write-Host "🔨 构建 Android Release APK..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Android 构建失败！" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 重命名文件
Write-Host ""
Write-Host "📱 重命名 APK 文件..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$commitShort = (git rev-parse --short HEAD 2>$null) -replace "`n", ""
if (-not $commitShort) { $commitShort = "local" }

$originalApk = "build\app\outputs\flutter-apk\app-release.apk"
$newApkName = "FlutterApp_Android_${timestamp}_${commitShort}.apk"
$newApkPath = "build\app\outputs\flutter-apk\$newApkName"

if (Test-Path $originalApk) {
    Copy-Item $originalApk $newApkPath
    Write-Host "✅ APK 文件已重命名为: $newApkName" -ForegroundColor Green
} else {
    Write-Host "⚠️  未找到原始 APK 文件" -ForegroundColor Yellow
}

# 完成信息
Write-Host ""
Write-Host "✅ 构建完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📦 构建产物:" -ForegroundColor Cyan
Write-Host "   - Android APK: $newApkPath" -ForegroundColor White
Write-Host ""
Write-Host "📱 您可以将 APK 文件安装到 Android 设备上测试。" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  注意: iOS 构建需要在 macOS 环境中进行。" -ForegroundColor Yellow
Write-Host ""

# 询问是否打开文件夹
$choice = Read-Host "是否打开构建文件夹？ (y/N)"
if ($choice -eq 'y' -or $choice -eq 'Y') {
    Start-Process explorer "build\app\outputs\flutter-apk\"
}

Write-Host "按任意键退出..." -ForegroundColor Gray
Read-Host 