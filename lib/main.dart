import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quote_provider.dart';
import 'screens/home_screen.dart';
import 'screens/image_test_screen.dart';
import 'theme/app_theme.dart';
// import 'utils/image_checker.dart'; // 移除不再使用的import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置横屏模式
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // 沉浸式隐藏系统栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // 设置图片加载错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    // 一律打印完整异常 & 堆栈，方便排查
    debugPrint('⚠️ FlutterError 捕获: ${details.exceptionAsString()}');
    debugPrint(details.stack?.toString() ?? '无 Stack');
    FlutterError.presentError(details); // 保持系统行为
  };
  
  // 移除图片检查逻辑
  // await runImageChecker();
  
  runApp(const ArknightsApp());
}

class ArknightsApp extends StatelessWidget {
  const ArknightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuoteProvider(),
      child: MaterialApp(
        title: '羲和',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(), // 直接进入主屏幕
        routes: {
          '/image-test': (_) => const ImageTestScreen(),
        },
      ),
    );
  }
}

// 移除整个 ImagePreloader 组件
