import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/glassy_button.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  const LandingPage({super.key, required this.onSignUp, required this.onLogin});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isScanning = false;

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
        decoration: BoxDecoration(
          color: Colors.grey[50],
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
                        const SizedBox(height: 36),
                        const Spacer(),
                        _buildTextStack(),
                        const SizedBox(height: 32),
                        _buildSignUpButton(),
                        const SizedBox(height: 16),
                        _buildLoginButton(),
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
            color: Colors.black,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Get started with a modern, glassy experience.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GlassyButton(
      onPressed: widget.onSignUp,
      borderRadius: BorderRadius.circular(16),
      child: const Text(
        'Sign Up',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _handleLogin,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black26, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() => _isScanning = true);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFaceScanDialog(),
    );

    setState(() => _isScanning = false);
  }

  Widget _buildFaceScanDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.face,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Face Recognition',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scanning your face...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 2000)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Future.microtask(() {
                    Navigator.of(context).pop();
                    widget.onLogin();
                  });
                  return const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
