import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/quote.dart';
import '../theme/app_theme.dart';

class CharacterDisplay extends StatelessWidget {
  final Character? character;
  final VoidCallback? onTap;

  const CharacterDisplay({
    super.key,
    this.character,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (character == null) {
      return _buildPlaceholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 角色立绘容器
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getRarityColor(character!.rarity).withOpacity(0.2),
                      _getRarityColor(character!.rarity).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: _getRarityColor(character!.rarity).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // 背景装饰
                    _buildBackgroundPattern(),
                    
                    // 角色立绘
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 头像
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _getRarityColor(character!.rarity),
                                  _getRarityColor(character!.rarity).withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getRarityColor(character!.rarity).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _getProfessionIcon(character!.profession),
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 星级显示
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              int.parse(character!.rarity),
                              (index) => Icon(
                                Icons.star,
                                color: _getRarityColor(character!.rarity),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 右上角职业标签
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRarityColor(character!.rarity).withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          character!.profession,
                          style: TextStyle(
                            color: _getRarityColor(character!.rarity),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 角色信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 代号
                  Text(
                    character!.codename,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 真名
                  Text(
                    character!.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 子职业
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRarityColor(character!.rarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      character!.subProfession,
                      style: TextStyle(
                        color: _getRarityColor(character!.rarity),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HexagonPatternPainter(
          color: _getRarityColor(character?.rarity ?? '1').withOpacity(0.05),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case '6':
        return const Color(0xFFFF6B35); // 橙色
      case '5':
        return const Color(0xFFFFDB4D); // 黄色
      case '4':
        return const Color(0xFF9C88FF); // 紫色
      case '3':
        return const Color(0xFF4ECDC4); // 青色
      case '2':
        return const Color(0xFF96CEB4); // 绿色
      case '1':
        return const Color(0xFFB0B0B0); // 灰色
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getProfessionIcon(String profession) {
    switch (profession) {
      case '近卫':
        return Icons.security;
      case '狙击':
        return Icons.gps_fixed;
      case '重装':
        return Icons.shield;
      case '医疗':
        return Icons.healing;
      case '术师':
        return Icons.auto_awesome;
      case '辅助':
        return Icons.support_agent;
      case '先锋':
        return Icons.directions_run;
      case '特种':
        return Icons.stars;
      default:
        return Icons.person;
    }
  }
}

class HexagonPatternPainter extends CustomPainter {
  final Color color;

  HexagonPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const hexSize = 30.0;
    final hexHeight = hexSize * 1.732; // sqrt(3)
    final hexWidth = hexSize * 2;

    for (double x = -hexWidth; x < size.width + hexWidth; x += hexWidth * 0.75) {
      for (double y = -hexHeight; y < size.height + hexHeight; y += hexHeight) {
        final offset = (x / (hexWidth * 0.75)).floor() % 2 == 1 ? hexHeight / 2 : 0;
        _drawHexagon(canvas, paint, Offset(x, y + offset), hexSize);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * (3.14159 / 180.0);
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

 