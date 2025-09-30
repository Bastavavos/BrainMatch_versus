import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../provider/user_provider.dart';
import '../../../service/api_service.dart';
import '../../../repositories/user_repository.dart';
import '../../theme.dart';

class PodiumUserWidget extends ConsumerWidget {
  final User user;
  final User currentUser;
  final int rank; // 0-based (0 => 1er au centre, 1 => 2ème à gauche, 2 => 3ème à droite)
  final double height; // hauteur totale fournie par le parent (incluant avatar)
  final Color color;
  final IconData? trophyIcon;
  final Color? trophyColor;

  const PodiumUserWidget({
    super.key,
    required this.user,
    required this.currentUser,
    required this.rank,
    required this.height,
    required this.color,
    this.trophyIcon,
    this.trophyColor,
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

    final double avatarRadius = 35.0;
    final double blockHeight = (height - avatarRadius).clamp(60.0, double.infinity);
    final double width = MediaQuery.of(context).size.width / 3.0;

    const double horizontalMargin = 3.0;
    final BorderRadiusGeometry borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    );

    Color blockColor;
    switch (rank) {
      case 0:
        blockColor = AppColors.primary;
        break;
      case 1:
        blockColor = AppColors.primary.withOpacity(0.9);
        break;
      case 2:
        blockColor = AppColors.primary.withOpacity(0.8);
        break;
      default:
        blockColor = AppColors.primary.withOpacity(0.5);
    }

    // Icône d'état d'amitié
    Widget? actionWidget;
    if (currentUser.id != user.id) {
      final isFriend = currentUser.friendIds.contains(user.id);
      final isRequestSent = currentUser.sentFriendRequestsId.contains(user.id);
      final isRequestReceived = currentUser.friendRequestId.contains(user.id);

      if (isFriend) {
        // déjà ami
      } else if (isRequestSent) {
        actionWidget = const Icon(Icons.hourglass_top, color: Colors.white70, size: 18);
      } else if (isRequestReceived) {
        actionWidget = const Icon(Icons.mail, color: Colors.white70, size: 18);
      } else {
        // Utilisation de GestureDetector pour avoir la même taille que les autres icônes
        actionWidget = GestureDetector(
          onTap: _handleAddFriend,
          child: const Icon(Icons.person_add, color: Colors.white, size: 18),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: SizedBox(
        width: width - (horizontalMargin * 2),
        height: avatarRadius + blockHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Bloc principal
            Positioned.fill(
              top: avatarRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: borderRadius,
                ),
                padding: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          '${user.score ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Avatar centré
            Positioned(
              top: 0,
              child: Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 4)],
                ),
                child: ClipOval(
                  child: user.picture != null && user.picture!.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: user.imageWithCacheBuster ?? user.picture!,
                    fit: BoxFit.cover,
                    errorWidget: (c, s, e) => Container(
                      color: Colors.white12,
                      child: Center(
                        child: Text(
                          user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                  )
                      : Container(
                    color: Colors.white12,
                    child: Center(
                      child: Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Icône trophée
            if (trophyIcon != null)
              Positioned(
                left: 8,
                top: avatarRadius + 6,
                child: Icon(
                  trophyIcon,
                  color: trophyColor ?? Colors.white.withOpacity(0.9),
                  size: 18,
                ),
              ),

            // Icône action alignée à droite
            if (actionWidget != null)
              Positioned(
                right: 8, // symétrique du trophée
                top: avatarRadius + 6, // même hauteur
                child: SizedBox(
                  height: 18,
                  child: Center(child: actionWidget),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
