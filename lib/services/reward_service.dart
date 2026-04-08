import '../models/reward_badge.dart';

class RewardService {

  final List<RewardBadge> rewards = [
    RewardBadge(title: "Bronze Focus", requiredMinutes: 60),
    RewardBadge(title: "Silver Focus", requiredMinutes: 180),
    RewardBadge(title: "Gold Focus", requiredMinutes: 300),
    RewardBadge(title: "Platinum Focus", requiredMinutes: 600),
  ];

  List<RewardBadge> getUnlockedRewards(int totalMinutes) {

    List<RewardBadge> unlocked = [];

    for (final reward in rewards) {
      if (totalMinutes >= reward.requiredMinutes) {
        unlocked.add(reward);
      }
    }

    return unlocked;
  }
}