import 'package:flutter/material.dart';
import '../models/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final Quote? quote;

  const QuoteDisplay({
    super.key,
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return _buildPlaceholder();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    
    final double fixedWidth = (screenWidth * 0.42).clamp(280.0, 420.0);
    return Container(
      constraints: BoxConstraints(
        minWidth: fixedWidth,
        maxWidth: fixedWidth,
        minHeight: 230,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7), // 半透明黑色背景
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRarityColor(quote!.character?.rarity ?? '1'),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _getRarityColor(quote!.character?.rarity ?? '1').withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: quote!.text.length < 80 ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 金句内容
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                quote!.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 分割线
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              color: _getRarityColor(quote!.character?.rarity ?? '1'),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 作者信息
          Text(
            '— ${quote!.author}',
            style: TextStyle(
              color: _getRarityColor(quote!.character?.rarity ?? '1').withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            softWrap: true, // 确保作者名字也能换行
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 500, // 固定大小
        maxHeight: 350,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote,
              size: 48,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              '加载金句中...',
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
        return Colors.white;
    }
  }
} 