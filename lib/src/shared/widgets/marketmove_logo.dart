import 'package:flutter/material.dart';

class MarketMoveLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showShadow;

  const MarketMoveLogo({
    super.key,
    this.size = 110,
    this.borderRadius = 28,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius * 0.7),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
