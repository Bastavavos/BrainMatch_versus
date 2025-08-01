import 'package:flutter/material.dart';

class SpeLayout extends StatelessWidget {
  final Widget child;
  final Widget? titleWidget;
  const SpeLayout({super.key, required this.child, this.titleWidget});

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
        title: titleWidget ??
            Image.asset(
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
