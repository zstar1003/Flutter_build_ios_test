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
import '../widgets/quote_display.dart';
import '../widgets/character_display.dart';

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

  final List<Particle> _particles = [];
  static const int _particleCount = 20;

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
    
    // 初始化粒子
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles.clear();
    
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.1,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
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
          // 只在真正的初始加载时显示加载状态
          if (provider.isLoading && provider.currentQuote == null && provider.characters.isEmpty) {
            return _buildLoadingState();
          }

          // 只在真正的错误且没有任何数据时显示错误状态
          if (provider.error != null && provider.currentQuote == null && provider.characters.isEmpty) {
            return _buildErrorState(provider);
          }

          // 确定要显示的角色 - 优先使用当前角色
          final displayCharacter = provider.currentCharacter ?? 
                                   provider.currentQuote?.character ?? 
                                   (provider.characters.isNotEmpty ? provider.characters.first : null);

          // 确定要显示的金句 - 始终确保有金句显示
          final displayQuote = provider.currentQuote ?? 
                               (displayCharacter != null ? Quote(
                                 text: displayCharacter.quotes.isNotEmpty ? displayCharacter.quotes.first : "欢迎来到明日方舟世界",
                                 author: displayCharacter.name,
                                 character: displayCharacter,
                                 tags: ['默认'],
                                 date: DateTime.now(),
                               ) : null);

          return Stack(
            children: [
              // 总是显示背景 - 避免白屏
              _buildDefaultBackground(),
              
              // 角色立绘背景（如果有角色数据）
              if (displayCharacter != null)
                _buildCharacterBackground(displayCharacter, MediaQuery.of(context).size),
              
              // 渐变遮罩
              _buildGradientOverlay(),
              
              // 粒子效果
              _buildParticleSystem(),
              
              // 金句内容 - 始终显示
              if (displayQuote != null)
                _buildMainContent(context, displayQuote, displayCharacter, MediaQuery.of(context).size),
              
              // 角色信息（左上角）
              if (displayCharacter != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 0,
                  child: _buildCharacterInfo(displayCharacter),
                ),
              
              // 控制按钮
              _buildControlButtons(context),
              
              // 角色选择器
              if (_showCharacterSelector)
                _buildCharacterSelectorOverlay(),
            ],
          );
        },
      ),
    );
  }

  // 添加默认背景，确保不会白屏
  Widget _buildDefaultBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterBackground(Character character, Size size) {
    return Stack(
      children: [
        // 背景图片
        Positioned.fill(
          child: Image.asset(
            character.backgroundUrl ?? character.illustrationUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      const Color(0xFF0f3460),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 角色立绘（左边部分）
        Positioned(
          left: -50,
          top: 0,
          bottom: 0,
          width: size.width * 0.6,
          child: ClipRect(
            child: Image.asset(
              character.illustrationUrl,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) {
                print('角色立绘加载失败: ${character.illustrationUrl}');
                print('错误: $error');
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getProfessionIcon(character.profession),
                          size: 80,
                          color: _getRarityColor(character.rarity).withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          character.codename,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticleSystem() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_particles, _particleController.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Quote? currentQuote, Character? character, Size size) {
    if (currentQuote == null) return Container();
    
    return SafeArea(
      child: AnimatedBuilder(
        animation: _characterAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _characterAnimation.value.clamp(0.0, 1.0),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.4, // 更靠右一些
                  right: 24.0,
                  top: 24.0,
                  bottom: 120.0, // 为底部按钮留出空间
                ),
                child: Transform.scale(
                  scale: 1.3, // 放大到1.3倍
                  child: QuoteDisplay(quote: currentQuote),
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

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRarityColor(character.rarity),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getProfessionIcon(character.profession),
            color: _getRarityColor(character.rarity),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            character.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getRarityColor(character.rarity),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${character.rarity}★',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
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
              // 使用microtask确保状态更新的正确顺序
              Future.microtask(() {
                final provider = Provider.of<QuoteProvider>(context, listen: false);
                
                // 先关闭选择器
                if (mounted) {
                  setState(() {
                    _showCharacterSelector = false;
                  });
                }
                
                // 设置新角色
                provider.setCharacter(character);
                
                // 重置并启动动画
                _characterController.reset();
                _characterController.forward();
                
                HapticFeedback.lightImpact();
              });
            },
            onClose: () {
              // 关闭选择器的回调
              if (mounted) {
                setState(() {
                  _showCharacterSelector = false;
                });
              }
            },
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

// 粒子类
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update() {
    y -= speed * 0.01;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

// 粒子绘制器
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      particle.update();
      
      final opacity = (particle.opacity * 
          (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + particle.x * 10)))
          .clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 