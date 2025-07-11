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
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth * 0.8,
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                quote!.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (quote!.author.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: 40,
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '— ${quote!.author}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
              softWrap: true,
            ),
          ]
        ],
      ),
    );
  }
} 