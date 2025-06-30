import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isDaily;
  final bool isCompact;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isDaily = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteProvider>(
      builder: (context, provider, child) {
        final isFavorited = provider.isFavorite(quote);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: isDaily ? 12 : 8,
            shadowColor: isDaily ? AppTheme.primaryColor.withOpacity(0.3) : Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isDaily 
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.secondaryColor.withOpacity(0.1),
                      ],
                    )
                  : null,
              ),
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 引用图标
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isDaily ? AppTheme.primaryGradient : AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.format_quote,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        _buildActionButtons(context, provider, isFavorited),
                      ],
                    ),
                    
                    SizedBox(height: isCompact ? 12 : 20),
                    
                    // 金句内容
                    Text(
                      quote.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    
                    SizedBox(height: isCompact ? 12 : 16),
                    
                    // 作者信息
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '— ${quote.author}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isCompact ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // 标签
                    if (quote.tags.isNotEmpty && !isCompact) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: quote.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, QuoteProvider provider, bool isFavorited) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 收藏按钮
        GestureDetector(
          onTap: () {
            provider.toggleFavorite(quote);
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFavorited 
                ? AppTheme.secondaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: isFavorited ? AppTheme.secondaryColor : Colors.grey,
              size: 20,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 分享按钮
        GestureDetector(
          onTap: () => _shareQuote(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 复制按钮
        GestureDetector(
          onTap: () => _copyQuote(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.copy_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _shareQuote() {
    Share.share(
      '${quote.text}\n\n— ${quote.author}',
      subject: '每日金句',
    );
  }

  void _copyQuote(BuildContext context) {
    Clipboard.setData(ClipboardData(
      text: '${quote.text}\n\n— ${quote.author}',
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('金句已复制到剪贴板'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    HapticFeedback.lightImpact();
  }
} 