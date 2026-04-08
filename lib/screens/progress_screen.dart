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

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Total Focus Time'),
                    subtitle: Text('$totalMinutes minutes'),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: const Text('Sessions Completed'),
                    subtitle: Text('$totalSessions'),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Longest Session'),
                    subtitle: Text('$longestSession minutes'),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Unlocked Rewards',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (unlockedRewards.isEmpty)
                  const Text('No rewards unlocked yet.')
                else
                  ...unlockedRewards.map(
                    (reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events),
                          title: Text(reward.title),
                          subtitle: Text(
                            'Unlocked at ${reward.requiredMinutes} minutes',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}