import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../service/api_service.dart';
import '../../../models/user.dart';
import '../../../provider/user_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../theme.dart';

class UserWidget extends ConsumerWidget {
  final User user;

  const UserWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final token = ref.watch(tokenProvider);

    Future<void> _handleAddFriend() async {
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non authentifié')),
        );
        return;
      }

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur courant non chargé')),
        );
        return;
      }

      try {
        final api = ApiService(token: token);
        final userRepository = UserRepository(api: api);

        await userRepository.sendFriendRequest(currentUser.id, user.id);
        await ref.read(currentUserProvider.notifier).refreshUser(ref);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande envoyée à ${user.username}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget? trailingWidget;
    if (user.id != currentUser.id) {
      final isFriend = currentUser.friendIds.contains(user.id);
      final isRequestSent = currentUser.sentFriendRequestsId.contains(user.id);
      final isRequestReceived = currentUser.friendRequestId.contains(user.id);

      if (isFriend) {
        // trailingWidget = const Icon(Icons.check, color: Colors.green, semanticLabel: 'Déjà ami');
      } else if (isRequestSent) {
        trailingWidget = const Icon(Icons.hourglass_top, color: Colors.orange, semanticLabel: 'Demande envoyée');
      } else if (isRequestReceived) {
        trailingWidget = const Icon(Icons.mail, color: Colors.blue, semanticLabel: 'Demande reçue');
      } else {
        trailingWidget = IconButton(
          icon: const Icon(Icons.person_add, color: Colors.deepPurple),
          tooltip: 'Ajouter comme ami',
          onPressed: _handleAddFriend,
        );
      }
    }

    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: user.picture != null && user.picture!.isNotEmpty
              ? ClipOval(
            child: Image.network(
              user.picture!,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    user.username.length >= 2
                        ? user.username.substring(0, 2).toUpperCase()
                        : user.username.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          )
              : Text(
            user.username.length >= 2
                ? user.username.substring(0, 2).toUpperCase()
                : user.username.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 6),
            Text(
              '${user.score ?? 0}',
              style: const TextStyle(color: AppColors.secondaryAccent),
            ),
          ],
        ),
        trailing: trailingWidget,
        onTap: () {
          // Action au clic sur un utilisateur (ex: afficher profil)
        },
      ),
    );
  }
}
