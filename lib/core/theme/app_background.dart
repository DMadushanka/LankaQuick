import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  final bool showBottomOrb;
  final Widget? floatingActionButton;

  const AppBackground({
    super.key,
    required this.child,
    this.showBottomOrb = true,
    this.floatingActionButton,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF07050F) : const Color(0xFFF8FAFC);
    final Color topOrbColor = isDark 
        ? const Color(0xFFD946EF).withOpacity(0.07) // Neon Rose / Fuchsia
        : const Color(0xFFD946EF).withOpacity(0.03);
    final Color bottomOrbColor = isDark 
        ? const Color(0xFF8B5CF6).withOpacity(0.07) // Cyber Violet
        : const Color(0xFF8B5CF6).withOpacity(0.03);

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          // Top Left Blurred Orb (pulsing scale animation)
          Positioned(
            top: -120,
            left: -120,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.topLeft,
                  child: child,
                );
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: topOrbColor,
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Right Blurred Orb (pulsing scale animation)
          if (widget.showBottomOrb)
            Positioned(
              bottom: -120,
              right: -120,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.bottomRight,
                    child: child,
                  );
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bottomOrbColor,
                    ),
                  ),
                ),
              ),
            ),

          // Main Content
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}
