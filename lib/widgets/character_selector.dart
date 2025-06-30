import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class CharacterSelector extends StatefulWidget {
  final Function(Character) onCharacterSelected;
  final VoidCallback onClose;

  const CharacterSelector({
    super.key,
    required this.onCharacterSelected,
    required this.onClose,
  });

  @override
  State<CharacterSelector> createState() => _CharacterSelectorState();
}

class _CharacterSelectorState extends State<CharacterSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  String _selectedProfession = '全部';

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
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
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
                  // 头部
                  _buildHeader(),
                  
                  // 职业筛选
                  _buildProfessionFilter(),
                  
                  // 角色网格
                  Expanded(
                    child: _buildCharacterGrid(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '选择角色',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _animationController.reverse().then((_) {
                widget.onClose();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionFilter() {
    return Consumer<QuoteProvider>(
      builder: (context, provider, child) {
        final professions = ['全部', ...provider.getProfessions()];
        
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: professions.length,
            itemBuilder: (context, index) {
              final profession = professions[index];
              final isSelected = _selectedProfession == profession;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfession = profession;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                          ? Colors.transparent 
                          : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      profession,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCharacterGrid() {
    return Consumer<QuoteProvider>(
      builder: (context, provider, child) {
        final characters = provider.characters.where((character) {
          return _selectedProfession == '全部' || character.profession == _selectedProfession;
        }).toList();
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return _buildCharacterCard(character);
            },
          ),
        );
      },
    );
  }

  Widget _buildCharacterCard(Character character) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCharacterSelected(character);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getRarityColor(character.rarity).withOpacity(0.3),
              _getRarityColor(character.rarity).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getRarityColor(character.rarity).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 头像
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getRarityColor(character.rarity),
                    _getRarityColor(character.rarity).withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getProfessionIcon(character.profession),
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 代号
            Text(
              character.codename,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // 星级
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                int.parse(character.rarity),
                (index) => Icon(
                  Icons.star,
                  color: _getRarityColor(character.rarity),
                  size: 12,
                ),
              ),
            ),
          ],
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