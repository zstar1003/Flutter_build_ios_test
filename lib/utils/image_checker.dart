import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:typed_data';

/// 全局保存解码失败的 asset 路径，其他组件可读取进行降级处理。
final Set<String> badImageAssets = <String>{};

/// 需要检测的图片资源列表。如有需要可自行扩展。
const List<String> _assetsToCheck = [
  // operater
  'assets/operater/1.png',
  'assets/operater/2.png',
  'assets/operater/3.png',
  'assets/operater/4.png',
  'assets/operater/5.png',
  // charpack
  'assets/charpack/1.png',
  'assets/charpack/2.png',
  'assets/charpack/3.png',
  'assets/charpack/4.png',
  'assets/charpack/5.png',
  'assets/charpack/6.png',
  'assets/charpack/7.png',
  'assets/charpack/8.png',
  'assets/charpack/9.png',
  'assets/charpack/10.png',
  // bg
  'assets/bg/1.png',
  'assets/bg/2.png',
  'assets/bg/3.png',
  'assets/bg/4.png',
  'assets/bg/5.png',
  'assets/bg/6.png',
  'assets/bg/7.png',
  'assets/bg/8.png',
  'assets/bg/9.png',
  'assets/bg/10.png',
  // logo
  'assets/logo/logo.png',
  'assets/logo/logo_laios.png',
];

Future<void> _tryDecode(Uint8List bytes) async {
  await ui.instantiateImageCodec(bytes);
}

/// 在启动阶段调用，逐张解码 PNG。若失败，则记录到 [badImageAssets] 并打印日志。
Future<void> runImageChecker() async {
  debugPrint('🔍 开始检测图片完整性，共 ${_assetsToCheck.length} 张...');
  for (final path in _assetsToCheck) {
    try {
      final data = await rootBundle.load(path);
      await _tryDecode(data.buffer.asUint8List());
      debugPrint('✅ $path 正常');
    } catch (e) {
      badImageAssets.add(path);
      debugPrint('❌ $path 解码失败: $e');
    }
  }
  if (badImageAssets.isEmpty) {
    debugPrint('🎉 所有图片均可正常解码');
  } else {
    debugPrint('⚠️  共发现 ${badImageAssets.length} 张有问题的图片，请检查以上 ❌ 记录');
  }
} 