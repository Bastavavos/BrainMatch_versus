import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/api_service.dart';
import '../../models/user.dart';
import '../../provider/user_provider.dart';
import '../../repositories/user_repository.dart';

class UserWidget extends ConsumerWidget {
  final User user;
  final User currentUser; // utilisateur courant (amis, demandes)

  const UserWidget({
    super.key,
    required this.user,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère le token via Riverpod
    final token = ref.watch(tokenProvider);

    // Fonction asynchrone pour envoyer une demande d'ami
    Future<void> _handleAddFriend() async {
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non authentifié')),
        );
        return;
      }

      try {
        // Crée l'ApiService avec le token
        final api = ApiService(token: token);
        final userRepository = UserRepository(api: api);

        // Envoi de la demande
        await userRepository.sendFriendRequest(currentUser.id, user.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande envoyée à ${user.username}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }

    final isFriend = currentUser.friendIds.contains(user.id);
    final isRequestSent = currentUser.sentFriendRequestsId.contains(user.id);
    final isRequestReceived = currentUser.friendRequestId.contains(user.id);

    Widget trailingWidget;

    if (isFriend) {
      trailingWidget = const Icon(Icons.check, color: Colors.green, semanticLabel: 'Déjà ami');
    } else if (isRequestSent) {
      trailingWidget = const Icon(Icons.hourglass_top, color: Colors.orange, semanticLabel: 'Demande envoyée');
    } else if (isRequestReceived) {
      trailingWidget = const Icon(Icons.mail, color: Colors.blue, semanticLabel: 'Demande reçue');
    } else {
      trailingWidget = IconButton(
        icon: const Icon(Icons.person_add, color: Colors.deepPurple),
        tooltip: 'Ajouter comme ami',
        onPressed: _handleAddFriend, // on appelle la fonction définie plus haut
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: user.picture != null && user.picture!.isNotEmpty
            ? CircleAvatar(
          radius: 26,
          backgroundImage: CachedNetworkImageProvider(user.picture!),
        )
            : CircleAvatar(
          radius: 26,
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(
            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.deepPurple),
          ),
        ),
        title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Score: ${user.score}'),
        trailing: trailingWidget,
        onTap: () {
          // Action lors du clic sur un utilisateur, comme afficher le détail
        },
      ),
    );
  }
}