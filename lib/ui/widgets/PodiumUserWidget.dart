import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/api_service.dart';
import '../../models/user.dart';
import '../../provider/user_provider.dart';
import '../../repositories/user_repository.dart';

class PodiumUserWidget extends ConsumerWidget {
  final User user;
  final User currentUser;
  final int rank;
  final double height;
  final Color color;
  final IconData? trophyIcon;

  const PodiumUserWidget({
    super.key,
    required this.user,
    required this.currentUser,
    required this.rank,
    required this.height,
    required this.color,
    required this.trophyIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(tokenProvider);

    Future<void> _handleAddFriend() async {
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non authentifié')),
        );
        return;
      }
      try {
        final api = ApiService(token: token);
        final userRepository = UserRepository(api: api);
        await userRepository.sendFriendRequest(currentUser.id, user.id);
        await ref.read(currentUserProvider.notifier).refreshUser(ref); // 👈 MAJ LOCAL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande envoyée à ${user.username}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }

    Widget? actionWidget;
    if (user.id != currentUser.id) {
      final isFriend = currentUser.friendIds.contains(user.id);
      final isRequestSent = currentUser.sentFriendRequestsId.contains(user.id);
      final isRequestReceived = currentUser.friendRequestId.contains(user.id);

      if (isFriend) {
        actionWidget = const Icon(Icons.check, color: Colors.green);
      } else if (isRequestSent) {
        actionWidget = const Icon(Icons.hourglass_top, color: Colors.orange);
      } else if (isRequestReceived) {
        actionWidget = const Icon(Icons.mail, color: Colors.blue);
      } else {
        actionWidget = IconButton(
          icon: const Icon(Icons.person_add, color: Colors.deepPurple),
          onPressed: _handleAddFriend,
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trophyIcon != null)
          Icon(trophyIcon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          '#${rank + 1}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: MediaQuery.of(context).size.width / 3.5,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              user.picture != null && user.picture!.isNotEmpty
                  ? CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(user.imageWithCacheBuster!),
              )
                  : CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.3),
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.username,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Score: ${user.score}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (actionWidget != null) ...[
                const SizedBox(height: 4),
                actionWidget,
              ]
            ],
          ),
        ),
      ],
    );
  }
}
