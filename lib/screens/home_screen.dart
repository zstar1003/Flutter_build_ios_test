import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../providers/quote_provider.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';
import '../widgets/character_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _quoteController;
  late AnimationController _characterController;
  late Animation<double> _particleAnimation;
  late Animation<double> _quoteAnimation;
  late Animation<double> _characterAnimation;
  bool _showCharacterSelector = false;

  @override
  void initState() {
    super.initState();
    
    // 粒子效果动画
    _particleController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // 金句动画
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 角色动画
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    _quoteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeOutBack,
    ));
    
    _characterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _characterController,
      curve: Curves.easeOutCubic,
    ));
    
    _quoteController.forward();
    _characterController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _quoteController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentQuote == null) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.currentQuote == null) {
            return _buildErrorState(provider);
          }

          return Stack(
            children: [
              // 角色立绘背景
              _buildCharacterBackground(provider.currentCharacter),
              
              // 渐变遮罩
              _buildGradientOverlay(),
              
              // 粒子效果
              _buildParticleEffect(),
              
              // 金句内容
              _buildQuoteContent(provider.currentQuote),
              
              // 角色信息
              _buildCharacterInfo(provider.currentCharacter),
              
              // 控制按钮
              _buildControlButtons(),
              
              // 角色选择器
              if (_showCharacterSelector)
                _buildCharacterSelectorOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCharacterBackground(Character? character) {
    if (character == null) return Container();

    return AnimatedBuilder(
      animation: _characterAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_characterAnimation.value * 0.1),
          child: Opacity(
            opacity: _characterAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: CachedNetworkImage(
                imageUrl: character.illustrationUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getRarityColor(character.rarity).withOpacity(0.3),
                        _getRarityColor(character.rarity).withOpacity(0.1),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _getRarityColor(character.rarity),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getRarityColor(character.rarity).withOpacity(0.4),
                        _getRarityColor(character.rarity).withOpacity(0.2),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getProfessionIcon(character.profession),
                          size: 120,
                          color: _getRarityColor(character.rarity).withOpacity(0.8),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          character.codename,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleEffectPainter(
            progress: _particleAnimation.value,
            screenSize: MediaQuery.of(context).size,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildQuoteContent(Quote? quote) {
    if (quote == null) return Container();

    return SafeArea(
      child: AnimatedBuilder(
        animation: _quoteAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _quoteAnimation.value)),
            child: Opacity(
              opacity: _quoteAnimation.value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getRarityColor(quote.character?.rarity ?? '1').withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: _getRarityColor(quote.character?.rarity ?? '1').withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 引用符号
                      Icon(
                        Icons.format_quote,
                        size: 48,
                        color: _getRarityColor(quote.character?.rarity ?? '1').withOpacity(0.8),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 金句内容
                      Text(
                        quote.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 作者分割线
                      Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRarityColor(quote.character?.rarity ?? '1'),
                              _getRarityColor(quote.character?.rarity ?? '1').withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 作者信息
                      Text(
                        '— ${quote.author}',
                        style: TextStyle(
                          color: _getRarityColor(quote.character?.rarity ?? '1').withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharacterInfo(Character? character) {
    if (character == null) return Container();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      child: AnimatedBuilder(
        animation: _characterAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-50 * (1 - _characterAnimation.value), 0),
            child: Opacity(
              opacity: _characterAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getRarityColor(character.rarity).withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 职业图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRarityColor(character.rarity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getProfessionIcon(character.profession),
                        color: _getRarityColor(character.rarity),
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 代号
                        Text(
                          character.codename,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // 星级
                        Row(
                          children: List.generate(
                            int.parse(character.rarity),
                            (index) => Icon(
                              Icons.star,
                              color: _getRarityColor(character.rarity),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 40,
      right: 32,
      child: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 角色切换按钮
              _buildControlButton(
                icon: Icons.people_outline,
                onTap: _toggleCharacterSelector,
                color: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 16),
              
              // 换句按钮（简化）
              _buildControlButton(
                icon: Icons.refresh_outlined,
                onTap: () => _refreshQuote(provider),
                loading: provider.isLoading,
                color: AppTheme.secondaryColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: color.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Icon(
                icon,
                color: color,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildCharacterSelectorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: CharacterSelector(
            onCharacterSelected: (character) {
              _selectCharacter(character.name);
              _toggleCharacterSelector();
            },
            onClose: _toggleCharacterSelector,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '正在加载...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(QuoteProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.loadDailyQuote,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  // 控制方法
  void _refreshQuote(QuoteProvider provider) {
    provider.getRandomCharacterQuote();
    _quoteController.reset();
    _characterController.reset();
    _quoteController.forward();
    _characterController.forward();
    HapticFeedback.lightImpact();
  }

  void _selectCharacter(String characterName) {
    final provider = Provider.of<QuoteProvider>(context, listen: false);
    provider.getCharacterQuote(characterName);
    _quoteController.reset();
    _characterController.reset();
    _quoteController.forward();
    _characterController.forward();
  }

  void _toggleCharacterSelector() {
    setState(() {
      _showCharacterSelector = !_showCharacterSelector;
    });
    HapticFeedback.lightImpact();
  }

  // 辅助方法
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

// 粒子效果绘制器
class ParticleEffectPainter extends CustomPainter {
  final double progress;
  final Size screenSize;

  ParticleEffectPainter({
    required this.progress,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 绘制浮动粒子
    for (int i = 0; i < 20; i++) {
      final seed = i * 1337;
      final random = math.Random(seed);
      
      final baseX = random.nextDouble() * screenSize.width;
      final baseY = random.nextDouble() * screenSize.height;
      
      final offsetX = math.sin((progress * 2 * math.pi) + (i * 0.5)) * 30;
      final offsetY = math.cos((progress * 2 * math.pi) + (i * 0.3)) * 20;
      
      final x = baseX + offsetX;
      final y = baseY + offsetY;
      
      final opacity = (math.sin(progress * 2 * math.pi + i) + 1) / 2 * 0.1;
      final radius = 2.0 + random.nextDouble() * 3.0;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 