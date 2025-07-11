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
      width: screenWidth * 0.85,
      constraints: const BoxConstraints(
        maxWidth: 550,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC06C84).withOpacity(0.75), // A warm, deep pink
            const Color(0xFF6C5B7B).withOpacity(0.75), // A warm, deep purple
            const Color(0xFF355C7D).withOpacity(0.85), // A deep blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
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
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.7,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (quote!.author.isNotEmpty) ...[
            const SizedBox(height: 30),
            Container(
              width: 50,
              height: 1.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '— ${quote!.author}  ${quote!.source}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ]
        ],
      ),
    );
  }
} 