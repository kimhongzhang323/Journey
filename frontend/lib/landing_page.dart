import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/glassy_button.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onGetStarted;
  
  const LandingPage({super.key, required this.onGetStarted});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0E4CFF),
              Color(0xFF4C3DEB),
              Color(0xFF0EA6C1),
              Color(0xFF9B59B6),
            ],
            stops: [0.05, 0.35, 0.65, 0.95],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildGlow(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        _buildTopBar(),
                        const Spacer(),
                        _buildTextStack(),
                        const SizedBox(height: 32),
                        _buildGetStartedButton(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlow() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: 360,
            height: 360,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFFFB4D0),
                  Color(0xFF8ED6FF),
                  Color(0xFFE7C8FF),
                  Colors.transparent,
                ],
                stops: [0.1, 0.4, 0.65, 1.0],
                center: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextStack() {
    return Column(
      children: [
        Text(
          'Journey',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.95),
            letterSpacing: 0.4,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Get started with a modern, glassy experience.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.88),
            height: 1.3,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.close, color: Colors.white.withOpacity(0.9), size: 26),
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.9), size: 22),
            const SizedBox(width: 6),
            Text(
              'Journey',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
              ),
              child: Text(
                'beta',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 26),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    return GlassyButton(
      onPressed: widget.onGetStarted,
      borderRadius: BorderRadius.circular(16),
      child: const Text(
        'Get Started',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}

