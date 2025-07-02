import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'dart:async';
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

  // 添加时间相关变量
  late Timer _timeTimer;
  String _currentTime = '';
  
  // 添加自动刷新Timer
  late Timer _autoRefreshTimer;
  late DateTime _nextRefreshTime;

  @override
  void initState() {
    super.initState();
    
    // 粒子效果动画
    _particleController = AnimationController(
      duration: const Duration(seconds: 60),
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
    
    // 初始化时间显示
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    
    // 初始化自动刷新Timer - 每小时刷新一次
    _nextRefreshTime = DateTime.now().add(const Duration(hours: 1));
    _autoRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) => _autoRefreshQuote());
  }

  void _initializeParticles() {
    _particles.clear();
    final random = math.Random();
    
    // 减少粒子数量到30个，营造更优雅的氛围
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 1, // 减小尺寸：1-5像素
        speed: random.nextDouble() * 0.8 + 0.2, // 大幅降低速度：0.2-1.0
        opacity: random.nextDouble() * 0.6 + 0.2, // 适中透明度：0.2-0.8
        type: ParticleType.values[random.nextInt(ParticleType.values.length)], // 随机类型
        color: _getRandomParticleColor(random), // 随机颜色
        rotationSpeed: random.nextDouble() * 0.5 - 0.25, // 降低旋转速度：-0.25到0.25
        phase: random.nextDouble() * 2 * math.pi, // 随机相位
      ));
    }
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _characterController.dispose();
    _particleController.dispose();
    _timeTimer.cancel(); // 取消时间更新定时器
    _autoRefreshTimer.cancel(); // 取消自动刷新定时器
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
              
              // 金句内容 - 始终显示
              if (displayQuote != null)
                _buildMainContent(context, displayQuote, displayCharacter, MediaQuery.of(context).size),
              
              // === 特效层区域 - 显示在所有内容之上 ===
              // 粒子效果
              _buildParticleSystem(),
              
              // 光晕效果
              _buildGlowEffects(),
              
              // 闪烁星星
              _buildTwinklingStars(),
              
              // 浮动几何图案
              _buildFloatingPatterns(),
              
              // === UI控件层 ===
              // 角色信息（左上角）
              if (displayCharacter != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 0,
                  child: _buildCharacterInfo(displayCharacter),
                ),
              
              // 时间显示（右上角）
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 24,
                child: _buildTimeDisplay(),
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

  Widget _buildGlowEffects() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: GlowEffectPainter(_particleController.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }

  Widget _buildTwinklingStars() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: TwinklingStarsPainter(_particleController.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }

  Widget _buildFloatingPatterns() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: FloatingPatternsPainter(_particleController.value),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getRarityColor(character.rarity),
          width: 3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getProfessionIcon(character.profession),
            color: _getRarityColor(character.rarity),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                character.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.profession,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getRarityColor(character.rarity),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${character.rarity}★',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
    
    // 重置自动刷新计时器
    _nextRefreshTime = DateTime.now().add(const Duration(hours: 1));
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

  // 更新当前时间
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  // 获取随机粒子颜色
  Color _getRandomParticleColor(math.Random random) {
    final colors = [
      Colors.white,
      Colors.blue.withOpacity(0.7),
      Colors.cyan.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.pink.withOpacity(0.7),
      const Color(0xFFFF6B35).withOpacity(0.7), // 橙色
      const Color(0xFFFFD700).withOpacity(0.7), // 金色
    ];
    return colors[random.nextInt(colors.length)];
  }

  Widget _buildTimeDisplay() {
    final now = DateTime.now();
    final dateStr = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // 计算距离下次刷新的时间
    final timeUntilRefresh = _nextRefreshTime.difference(now);
    final minutesUntilRefresh = timeUntilRefresh.inMinutes;
    String refreshText;
    if (minutesUntilRefresh > 0) {
      refreshText = '${minutesUntilRefresh}分钟后刷新';
    } else {
      refreshText = '即将刷新...';
    }
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                refreshText,
                style: TextStyle(
                  color: Colors.cyan.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 自动刷新方法
  void _autoRefreshQuote() {
    if (mounted) {
      final provider = Provider.of<QuoteProvider>(context, listen: false);
      _refreshQuote(provider);
      
      // 显示自动刷新提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('已自动更新金句', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// 粒子类型枚举
enum ParticleType {
  circle,    // 圆形
  star,      // 星形
  diamond,   // 菱形
  square,    // 方形
  triangle,  // 三角形
}

// 增强的粒子类
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final ParticleType type;
  final Color color;
  final double rotationSpeed;
  final double phase;
  double rotation = 0.0;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.type,
    required this.color,
    required this.rotationSpeed,
    required this.phase,
  });

  void update(double animationValue) {
    // 垂直移动 - 大幅降低速度
    y -= speed * 0.003; // 从0.008降低到0.003
    
    // 水平波动 - 降低幅度和频率
    x += math.sin(animationValue * math.pi + phase) * 0.0005; // 降低频率和幅度
    
    // 旋转 - 降低旋转速度
    rotation += rotationSpeed * 0.01; // 从0.02降低到0.01
    
    // 边界检查和重置
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
    if (x < 0) x = 1.0;
    if (x > 1) x = 0.0;
  }
}

// 增强的粒子绘制器
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(animationValue);
      
      // 计算动态透明度 - 降低变化频率
      final opacity = (particle.opacity * 
          (0.7 + 0.3 * math.sin(animationValue * math.pi + particle.phase))) // 降低频率，提高基础透明度
          .clamp(0.3, 0.9); // 设置更温和的透明度范围
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      // 保存canvas状态
      canvas.save();
      
      // 移动到粒子中心并旋转
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);
      
      // 根据粒子类型绘制不同形状
      switch (particle.type) {
        case ParticleType.circle:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, paint, particle.size);
          break;
        case ParticleType.diamond:
          _drawDiamond(canvas, paint, particle.size);
          break;
        case ParticleType.square:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size * 2, height: particle.size * 2),
            paint,
          );
          break;
        case ParticleType.triangle:
          _drawTriangle(canvas, paint, particle.size);
          break;
      }
      
      // 恢复canvas状态
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    const int points = 5;
    final double outerRadius = size;
    final double innerRadius = size * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final double angle = (i * math.pi) / points;
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double x = radius * math.cos(angle - math.pi / 2);
      final double y = radius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size, 0);
    path.lineTo(0, size);
    path.lineTo(-size, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.866, size * 0.5);
    path.lineTo(-size * 0.866, size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// 光晕效果绘制器
class GlowEffectPainter extends CustomPainter {
  final double animationValue;

  GlowEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // 固定种子确保位置一致
    
    // 绘制多个光晕圆圈
    for (int i = 0; i < 6; i++) { // 减少到6个
      final center = Offset(
        size.width * (0.1 + random.nextDouble() * 0.8),
        size.height * (0.1 + random.nextDouble() * 0.8),
      );
      
      final radius = 40 + random.nextDouble() * 80; // 减小半径
      final opacity = (0.05 + 0.1 * math.sin(animationValue * math.pi + i)) * 0.2; // 降低频率和透明度
      
      final gradient = RadialGradient(
        colors: [
          Colors.cyan.withOpacity(opacity),
          Colors.blue.withOpacity(opacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(GlowEffectPainter oldDelegate) => true;
}

// 闪烁星星绘制器
class TwinklingStarsPainter extends CustomPainter {
  final double animationValue;

  TwinklingStarsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123); // 固定种子确保位置一致
    
    // 绘制多个闪烁星星
    for (int i = 0; i < 15; i++) { // 减少到15个
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      
      // 计算闪烁效果 - 降低频率
      final twinkle = math.sin(animationValue * 2 * math.pi + i * 0.8); // 降低频率
      final opacity = (0.2 + 0.5 * twinkle.abs()).clamp(0.0, 1.0) * 0.4; // 降低透明度
      final starSize = 1.5 + twinkle.abs() * 2; // 减小星星尺寸
      
      if (opacity > 0.1) { // 降低显示阈值
        _drawTwinklingStar(canvas, Offset(x, y), starSize, opacity);
      }
    }
  }

  void _drawTwinklingStar(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // 绘制十字星
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
    
    // 绘制对角线
    final diagSize = size * 0.7;
    canvas.drawLine(
      Offset(center.dx - diagSize, center.dy - diagSize),
      Offset(center.dx + diagSize, center.dy + diagSize),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - diagSize, center.dy + diagSize),
      Offset(center.dx + diagSize, center.dy - diagSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(TwinklingStarsPainter oldDelegate) => true;
}

// 浮动几何图案绘制器
class FloatingPatternsPainter extends CustomPainter {
  final double animationValue;

  FloatingPatternsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(456); // 固定种子
    
    // 绘制浮动的六边形
    for (int i = 0; i < 4; i++) { // 减少到4个
      final progress = (animationValue * 0.3 + i * 0.25) % 1.0; // 降低移动速度
      final x = size.width * (0.1 + random.nextDouble() * 0.8);
      final y = size.height * (progress * 1.2 - 0.1); // 从下往上移动
      
      final hexSize = 15 + random.nextDouble() * 20; // 减小尺寸
      final opacity = (0.05 + 0.15 * math.sin(animationValue * math.pi + i)) * 0.3; // 降低频率和透明度
      
      if (y > -50 && y < size.height + 50) {
        _drawHexagon(canvas, Offset(x, y), hexSize, opacity, animationValue * 0.5 + i); // 降低旋转速度
      }
    }
    
    // 绘制能量流线
    for (int i = 0; i < 3; i++) { // 减少到3个
      final progress = (animationValue * 0.2 + i * 0.33) % 1.0; // 降低速度
      final startX = size.width * random.nextDouble();
      final endX = startX + (random.nextDouble() - 0.5) * 150; // 减小长度
      final y = size.height * progress;
      
      final opacity = (0.1 + 0.2 * math.sin(animationValue * math.pi + i)) * 0.2; // 降低透明度
      
      _drawEnergyStream(canvas, Offset(startX, y), Offset(endX, y), opacity);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, double opacity, double rotation) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + rotation;
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

  void _drawEnergyStream(Canvas canvas, Offset start, Offset end, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B35).withOpacity(opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        const Color(0xFFFF6B35).withOpacity(opacity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    paint.shader = gradient.createShader(Rect.fromPoints(start, end));
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(FloatingPatternsPainter oldDelegate) => true;
} 