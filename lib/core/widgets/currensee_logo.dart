// lib/core/widgets/currensee_logo.dart
import 'package:flutter/material.dart';

/// CurrenSee logo widget using the actual logo image
class CurrenSeeLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const CurrenSeeLogo({
    super.key,
    this.size = 60.0,
    this.showText = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image
        Image.asset(
          'assets/images/CurrenSee2.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        
        // Text (optional)
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'CurrenSee',
            style: TextStyle(
              color: textColor ?? const Color(0xFF424242), // Dark gray
              fontSize: size * 0.3,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
