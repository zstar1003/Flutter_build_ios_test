import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class CharacterSelector extends StatefulWidget {
  final Function(Character) onCharacterSelected;
  final VoidCallback? onClose;

  const CharacterSelector({
    super.key,
    required this.onCharacterSelected,
    this.onClose,
  });

  @override
  State<CharacterSelector> createState() => _CharacterSelectorState();
}

class _CharacterSelectorState extends State<CharacterSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final double width = isLandscape ? constraints.maxWidth * 0.92 : constraints.maxWidth * 0.85;
                final double height = isLandscape ? constraints.maxHeight * 0.88 : constraints.maxHeight * 0.8;
                return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A2E).withOpacity(0.95),
                        const Color(0xFF16213E).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildHeader(isLandscape),
                      Expanded(
                        child: _buildCharacterGrid(isLandscape),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader([bool isLandscape = false]) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLandscape ? 6 : 10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: isLandscape ? 10 : 14),
          Expanded(
            child: Text(
              '选择干员',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLandscape ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _animationController.reverse().then((_) {
                widget.onClose?.call();
              });
            },
            child: Container(
              padding: EdgeInsets.all(isLandscape ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid([bool isLandscape = false]) {
    return Consumer<QuoteProvider>(
      builder: (context, provider, child) {
        final characters = provider.characters;
        final crossAxisCount = isLandscape ? 8 : 5;
        final aspectRatio = isLandscape ? 0.9 : 0.8;
        return Container(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return _buildCharacterCard(character, isLandscape);
            },
          ),
        );
      },
    );
  }

  Widget _buildCharacterCard(Character character, [bool isLandscape = false]) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCharacterSelected(character);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getRarityColor(character.rarity),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor(character.rarity).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              // 角色立绘背景
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(isLandscape ? 6 : 10),
                  child: Image.asset(
                    character.illustrationUrl,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getRarityColor(character.rarity).withOpacity(0.6),
                              _getRarityColor(character.rarity).withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            _getProfessionIconPath(character.profession),
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getProfessionIcon(character.profession),
                                size: 40,
                                color: Colors.white.withOpacity(0.8),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 渐变遮罩
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.38),
                      ],
                    ),
                  ),
                ),
              ),
              // 名称
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  color: Colors.black.withOpacity(0.45),
                  child: Text(
                    character.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case '6':
        return const Color(0xFFFF6B35); // 橙色
      case '5':
        return const Color(0xFFFFD700); // 金色
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
      case '最强近卫':
        return Icons.security;
      case '狙击':
        return Icons.gps_fixed;
      case '术师':
        return Icons.auto_awesome;
      case '特种':
        return Icons.stars;
      case '辅助':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  // 获取职业图标路径
  String _getProfessionIconPath(String profession) {
    switch (profession) {
      case '近卫':
      case '最强近卫': // 重岳的特殊职业也归类为近卫
        return 'assets/operater/1.png';
      case '狙击':
        return 'assets/operater/2.png';
      case '术师':
        return 'assets/operater/3.png';
      case '特种':
        return 'assets/operater/4.png';
      case '辅助':
        return 'assets/operater/5.png';
      default:
        return 'assets/operater/1.png'; // 默认返回近卫图标
    }
  }
} 