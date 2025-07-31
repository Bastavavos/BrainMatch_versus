import 'package:flutter/material.dart';
import 'package:brain_match/ui/layout/special_layout.dart';
import 'package:brain_match/ui/widgets/button/custom_button.dart';

class OpponentLeftView extends StatelessWidget {
  final String message;

  const OpponentLeftView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SpeLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            title: 'Relancer une partie',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
