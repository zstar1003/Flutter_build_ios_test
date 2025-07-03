import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quote_provider.dart';
import 'screens/home_screen.dart';
import 'screens/image_test_screen.dart';
import 'theme/app_theme.dart';
import 'utils/image_checker.dart';

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
  
  // 检测图片是否损坏，打印结果
  await runImageChecker();
  
  runApp(const ArknightsApp());
}

class ArknightsApp extends StatelessWidget {
  const ArknightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuoteProvider(),
      child: MaterialApp(
        title: '今日方舟',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const ImagePreloader(),
        routes: {
          '/image-test': (_) => const ImageTestScreen(),
        },
      ),
    );
  }
}

class ImagePreloader extends StatefulWidget {
  const ImagePreloader({super.key});

  @override
  State<ImagePreloader> createState() => _ImagePreloaderState();
}

class _ImagePreloaderState extends State<ImagePreloader> {
  bool _isLoading = true;
  String _loadingStatus = '正在加载资源...';
  bool _started = false; // 防止didChangeDependencies多次执行

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _preloadImages();
    }
  }

  Future<void> _preloadImages() async {
    try {
      setState(() {
        _loadingStatus = '预加载图片资源...';
      });

      // 预加载关键图片
      final List<String> imagePaths = [
        'assets/logo/logo_laios.png',
        'assets/operater/1.png',
        'assets/operater/2.png',
        'assets/operater/3.png',
        'assets/operater/4.png',
        'assets/operater/5.png',
      ];

      for (String path in imagePaths) {
        try {
          await precacheImage(AssetImage(path), context);
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          debugPrint('预加载图片失败: $path - $e');
        }
      }

      setState(() {
        _loadingStatus = '准备就绪！';
      });

      // 短暂延迟后跳转到主界面
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('图片预加载过程中出错: $e');
      // 即使预加载失败，也继续到主界面
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                _loadingStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
