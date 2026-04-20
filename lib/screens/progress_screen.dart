import 'package:flutter/material.dart';
import '../data/session_store.dart';
import '../services/progress_service.dart';
import '../services/reward_service.dart';

class ProgressScreen extends StatelessWidget {
  ProgressScreen({super.key});

  final ProgressService progressService = ProgressService();
  final RewardService rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List>(
      valueListenable: focusSessionsNotifier,
      builder: (context, sessions, child) {
        final int totalMinutes = progressService.getTotalMinutes(
          sessions.cast(),
        );
        final int totalSessions = progressService.getTotalSessions(
          sessions.cast(),
        );
        final int longestSession = progressService.getLongestSession(
          sessions.cast(),
        );
        final unlockedRewards =
            rewardService.getUnlockedRewards(totalMinutes);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'Your Progress',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _StatCard(
                    icon: Icons.timer,
                    title: 'Total Focus Time',
                    value: '$totalMinutes minutes',
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    icon: Icons.check_circle,
                    title: 'Sessions Completed',
                    value: '$totalSessions',
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    icon: Icons.star,
                    title: 'Longest Session',
                    value: '$longestSession minutes',
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Unlocked Rewards',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (unlockedRewards.isEmpty)
                    const Text(
                      'No rewards unlocked yet.',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...unlockedRewards.map(
                      (reward) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StatCard(
                          icon: Icons.emoji_events,
                          title: reward.title,
                          value:
                              'Unlocked at ${reward.requiredMinutes} minutes',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}