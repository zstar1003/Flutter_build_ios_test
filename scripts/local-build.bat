@echo off
chcp 65001 > nul
title Flutter 本地构建脚本

echo.
echo ======================================
echo      Flutter 本地构建脚本
echo ======================================
echo.

echo 🔍 检查 Flutter 环境...
flutter doctor
if %errorlevel% neq 0 (
    echo ❌ Flutter 环境检查失败！
    pause
    exit /b 1
)

echo.
echo 📦 获取依赖包...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 依赖包获取失败！
    pause
    exit /b 1
)

echo.
echo 🧪 运行测试...
flutter test
if %errorlevel% neq 0 (
    echo ❌ 测试失败！
    pause
    exit /b 1
)

echo.
echo 🧹 清理旧的构建文件...
flutter clean

echo.
echo 🔨 构建 Android Release APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Android 构建失败！
    pause
    exit /b 1
)

echo.
echo 📱 重命名 APK 文件...
set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
copy "build\app\outputs\flutter-apk\app-release.apk" "build\app\outputs\flutter-apk\FlutterApp_Android_%timestamp%.apk"

echo.
echo ✅ 构建完成！
echo.
echo 📦 构建产物:
echo    - Android APK: build\app\outputs\flutter-apk\FlutterApp_Android_%timestamp%.apk
echo.
echo 📱 您可以将 APK 文件安装到 Android 设备上测试。
echo.
echo ⚠️  注意: iOS 构建需要在 macOS 环境中进行。
echo.

pause 