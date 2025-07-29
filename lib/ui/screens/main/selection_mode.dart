import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../provider/user_provider.dart';

class SelectionModePage extends ConsumerWidget {
  const SelectionModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final token = ref.watch(tokenProvider) ?? '';
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            _buildModeCard(
              context,
              title: "Solo",
              icon: LucideIcons.user,
              color: colorScheme.primary,
              routeName: 'Solo',
              token: token,
            ),
            const SizedBox(height: 20),
            _buildModeCard(
              context,
              title: "Versus",
              icon: LucideIcons.users,
              color: colorScheme.secondary,
              routeName: 'Versus',
              token: token,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required String routeName,
        required String token,
      }) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (token.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Token manquant, veuillez vous reconnecter')),
            );
            return;
          }
          Navigator.pushNamed(
            context,
            '/confirm',  //categ
            arguments: {
              'selectedMode': routeName,
              'token': token,
            },
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
