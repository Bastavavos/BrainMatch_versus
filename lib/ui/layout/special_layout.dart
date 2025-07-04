import 'package:flutter/material.dart';

class SpeLayout extends StatelessWidget {
  final Widget child;
  const SpeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          },
        ),
        title: Image.asset(
          'assets/images/title.png',
          height: 70,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F5FD),
      body: child,
    );
  }
}
