import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user_view_model.dart';
import '../../widgets/user_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      userViewModel.fetchUsers();
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
        return Colors.transparent; // Pour les autres, ou une couleur par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.errorMessage != null) {
          return Center(child: Text('Erreur : ${viewModel.errorMessage!}'));
        } else if (viewModel.users.isEmpty) {
          return const Center(child: Text('Aucun utilisateur trouvé.'));
        }

        final podiumUsers = viewModel.users.take(3).toList();
        final otherUsers = viewModel.users.skip(3).toList();

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: Text(
                  'Leader board',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent, // Couleur thématique du jeu
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPodium(context, podiumUsers),
            ),
            if (otherUsers.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                sliver: SliverToBoxAdapter(
                  child: Divider(
                    color: Colors.grey[400],
                    thickness: 2,
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: UserWidget(user: otherUsers[index]), // user widget
                  );
                },
                childCount: otherUsers.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodium(BuildContext context, List<dynamic> podiumUsers) {
    if (podiumUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    double getHeightForRank(int rank) {
      switch (rank) {
        case 0: // 1er
          return 180.0;
        case 1: // 2ème
          return 150.0;
        case 2: // 3ème
          return 120.0;
        default:
          return 100.0;
      }
    }

    List<dynamic> orderedPodiumUsers = [];
    if (podiumUsers.length > 1) orderedPodiumUsers.add(podiumUsers[1]);
    if (podiumUsers.isNotEmpty) orderedPodiumUsers.add(podiumUsers[0]);
    if (podiumUsers.length > 2) orderedPodiumUsers.add(podiumUsers[2]);

    if (podiumUsers.length == 1) {
      orderedPodiumUsers = [podiumUsers[0]];
    } else if (podiumUsers.length == 2) {
      orderedPodiumUsers = [podiumUsers[1], podiumUsers[0]];
    }


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
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.3),
                child: Text(
                  user.username[0].toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Score: ${user.score}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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