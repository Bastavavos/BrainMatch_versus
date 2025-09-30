import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';
import '../../widgets/leaderboard/SearchBarWidget.dart';
import '../../widgets/leaderboard/podium_user_widget.dart';
import '../../widgets/leaderboard/user_widget.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = ref.read(userViewModelProvider);
      final user = ref.read(currentUserProvider);
      await ref.read(currentUserProvider.notifier).refreshUser(ref);
      if (user != null) {
        await userViewModel.fetchCurrentUser(user.id);
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

    // ✅ filtrer les utilisateurs en fonction de la recherche
    final filteredUsers = otherUsers.where((user) {
      final username = user.username.toLowerCase();
      return username.contains(_searchQuery.toLowerCase());
    }).toList();

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const Center(child: Text("Utilisateur non trouvé"));
    }

    return CustomScrollView(
      slivers: <Widget>[

        SliverToBoxAdapter(child: _buildPodium(context, podiumUsers)),

        // ✅ Barre de recherche
        SliverToBoxAdapter(
          child: SearchBarWidget(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        if (filteredUsers.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0),
            sliver: SliverToBoxAdapter(
              child: Divider(color: Colors.grey[400], thickness: 2),
            ),
          ),

        // ✅ Liste filtrée
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: UserWidget(user: filteredUsers[index]),
              );
            },
            childCount: filteredUsers.length,
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
          return 200.0;
        case 1:
          return 170.0;
        case 2:
          return 150.0;
        default:
          return 100.0;
      }
    }

    // organisation podium (2-1-3)
    List<dynamic> orderedPodiumUsers = [];
    if (podiumUsers.length > 1) orderedPodiumUsers.add(podiumUsers[1]);
    if (podiumUsers.isNotEmpty) orderedPodiumUsers.add(podiumUsers[0]);
    if (podiumUsers.length > 2) orderedPodiumUsers.add(podiumUsers[2]);
    if (podiumUsers.length == 1) orderedPodiumUsers = [podiumUsers[0]];
    if (podiumUsers.length == 2) {
      orderedPodiumUsers = [podiumUsers[1], podiumUsers[0]];
    }

    const double horizontalPadding = 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: horizontalPadding),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 240,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2ème place (gauche)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PodiumUserWidget(
                  user: podiumUsers.length > 1 ? podiumUsers[1] : podiumUsers[0],
                  currentUser: ref.watch(currentUserProvider)!,
                  rank: podiumUsers.length > 1 ? 1 : 0,
                  height: getHeightForRank(podiumUsers.length > 1 ? 1 : 0),
                  color: _getRankColor(podiumUsers.length > 1 ? 1 : 0),
                  trophyIcon: _getTrophyIcon(podiumUsers.length > 1 ? 1 : 0),
                  trophyColor: _getRankColor(podiumUsers.length > 1 ? 1 : 0),
                ),
              ),
            ),

            // 1ère place (centre)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PodiumUserWidget(
                  user: podiumUsers[0],
                  currentUser: ref.watch(currentUserProvider)!,
                  rank: 0,
                  height: getHeightForRank(0),
                  color: _getRankColor(0),
                  trophyIcon: _getTrophyIcon(0),
                  trophyColor: _getRankColor(0),
                ),
              ),
            ),

            // 3ème place (droite)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PodiumUserWidget(
                  user: podiumUsers.length > 2
                      ? podiumUsers[2]
                      : podiumUsers[0],
                  currentUser: ref.watch(currentUserProvider)!,
                  rank: podiumUsers.length > 2 ? 2 : (podiumUsers.length > 1 ? 1 : 0),
                  height: getHeightForRank(podiumUsers.length > 2 ? 2 : (podiumUsers.length > 1 ? 1 : 0)),
                  color: _getRankColor(podiumUsers.length > 2 ? 2 : (podiumUsers.length > 1 ? 1 : 0)),
                  trophyIcon: _getTrophyIcon(podiumUsers.length > 2 ? 2 : (podiumUsers.length > 1 ? 1 : 0)),
                  trophyColor: _getRankColor(podiumUsers.length > 2 ? 2 : (podiumUsers.length > 1 ? 1 : 0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData? _getTrophyIcon(int rank) {
    return Icons.emoji_events;
  }
}
