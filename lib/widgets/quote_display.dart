import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4B3832).withOpacity(0.85), // Coffee Brown
            const Color(0xFF854442).withOpacity(0.88), // Russet
            const Color(0xFFBE9B7B).withOpacity(0.85), // Tan
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
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
                style: TextStyle(
                  fontFamily: 'Noto Serif SC',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.8,
                  letterSpacing: 1.2,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (quote!.author.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF854442), // Russet color to mimic a seal
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${quote!.author}  ${quote!.source}',
                  style: TextStyle(
                    fontFamily: 'Noto Sans SC',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
} 