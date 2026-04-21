import 'package:flutter/material.dart';
import '../data/session_store.dart';
import '../models/reward_badge.dart';
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
                    'Rewards',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete focus milestones to unlock each reward.',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  ...rewardService.rewards.map(
                    (RewardBadge reward) {
                      final bool unlocked =
                          rewardService.isUnlocked(reward, totalMinutes);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RewardTile(
                          reward: reward,
                          unlocked: unlocked,
                        ),
                      );
                    },
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

class _RewardTile extends StatelessWidget {
  static const Color _unlockedGreen = Color(0xFF30D158);

  final RewardBadge reward;
  final bool unlocked;

  const _RewardTile({
    required this.reward,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        unlocked ? _unlockedGreen : Colors.white.withValues(alpha: 0.28);
    final Color titleColor =
        unlocked ? _unlockedGreen : Colors.white.withValues(alpha: 0.45);
    final Color subtitleColor =
        unlocked ? Colors.white60 : Colors.white.withValues(alpha: 0.32);
    final String subtitle = unlocked
        ? 'Completed · ${reward.requiredMinutes} min milestone'
        : 'Reach ${reward.requiredMinutes} total minutes to unlock';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: unlocked
            ? Border.all(color: _unlockedGreen.withValues(alpha: 0.45))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
          color: iconColor,
        ),
        title: Text(
          reward.title,
          style: TextStyle(
            color: titleColor,
            fontWeight: unlocked ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: subtitleColor)),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: _unlockedGreen, size: 26)
            : Icon(Icons.lock_outline, color: iconColor, size: 22),
      ),
    );
  }
}