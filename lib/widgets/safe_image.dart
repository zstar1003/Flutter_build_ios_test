import 'package:flutter/material.dart';
import 'dart:io';

class SafeImage extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeImage({
    Key? key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('图片加载失败: $assetPath');
        debugPrint('错误详情: $error');
        
        return errorWidget ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
      },
    );
  }
}

// 用于角色背景图片的专用组件
class CharacterBackgroundImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;

  const CharacterBackgroundImage({
    Key? key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImage(
      assetPath: imagePath,
      fit: fit,
      alignment: alignment,
      errorWidget: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.landscape,
            size: 100,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }
}

// 用于角色立绘的专用组件
class CharacterIllustrationImage extends StatelessWidget {
  final String imagePath;
  final String characterName;
  final BoxFit fit;
  final Alignment alignment;

  const CharacterIllustrationImage({
    Key? key,
    required this.imagePath,
    required this.characterName,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.centerLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeImage(
      assetPath: imagePath,
      fit: fit,
      alignment: alignment,
      errorWidget: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 80,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              Text(
                characterName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 