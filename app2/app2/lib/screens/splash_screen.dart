import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showLogo = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Exibe o logo por 2 segundos, depois faz fade out e navega
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      setState(() => _showLogo = false);
      await _controller.forward();
      if (!mounted) return;
      
      // Navega para a tela de login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _showLogo ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Image.asset(
            'images/logosemfundo.png',
            width: size.width * 0.6,
            height: size.height * 0.3,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
