

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/user_widget.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = ref.read(userViewModelProvider);
      final user = ref.read(userProvider);

      if (user != null && user['id'] != null) {
        await userViewModel.fetchCurrentUser(user['id']);
      }

      await userViewModel.fetchUsers();
    });
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Or
      case 1:
        return const Color(0xFFC0C0C0); // Argent
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(userViewModelProvider);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null) {
      return Center(child: Text('Erreur : ${viewModel.errorMessage!}'));
    } else if (viewModel.users.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé.'));
    }

    final podiumUsers = viewModel.users.take(3).toList();
    final otherUsers = viewModel.users.skip(3).toList();

    final userMap = ref.watch(userProvider);
    if (userMap == null) {
      return const Center(child: Text("Utilisateur non trouvé"));
    }
    final currentUser = User.fromJson(userMap);

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Text(
              'Leader board',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildPodium(context, podiumUsers)),
        if (otherUsers.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            sliver: SliverToBoxAdapter(
              child: Divider(color: Colors.grey[400], thickness: 2),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: UserWidget(
                  user: otherUsers[index],
                  currentUser: currentUser,
                ),
              );
            },
            childCount: otherUsers.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(BuildContext context, List<dynamic> podiumUsers) {
    if (podiumUsers.isEmpty) return const SizedBox.shrink();

    double getHeightForRank(int rank) {
      switch (rank) {
        case 0:
          return 180.0;
        case 1:
          return 150.0;
        case 2:
          return 120.0;
        default:
          return 100.0;
      }
    }

    List<dynamic> orderedPodiumUsers = [];
    if (podiumUsers.length > 1) orderedPodiumUsers.add(podiumUsers[1]);
    if (podiumUsers.isNotEmpty) orderedPodiumUsers.add(podiumUsers[0]);
    if (podiumUsers.length > 2) orderedPodiumUsers.add(podiumUsers[2]);
    if (podiumUsers.length == 1) orderedPodiumUsers = [podiumUsers[0]];
    if (podiumUsers.length == 2) orderedPodiumUsers = [podiumUsers[1], podiumUsers[0]];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(orderedPodiumUsers.length, (indexInRow) {
          final user = orderedPodiumUsers[indexInRow];
          final originalRank = podiumUsers.indexOf(user);

          return _buildPodiumItem(
            context,
            user,
            originalRank,
            getHeightForRank(originalRank),
          );
        }),
      ),
    );
  }

  Widget _buildPodiumItem(BuildContext context, dynamic user, int rank, double height) {
    final color = _getRankColor(rank);
    final trophyIcon = _getTrophyIcon(rank);

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
                backgroundImage: CachedNetworkImageProvider(user.picture!),
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
            ],
          ),
        ),
      ],
    );
  }

  IconData? _getTrophyIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.star_border;
      default:
        return null;
    }
  }
}
