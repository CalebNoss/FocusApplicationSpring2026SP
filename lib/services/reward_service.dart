import '../models/reward_badge.dart';

class RewardService {

  final List<RewardBadge> rewards = [
    RewardBadge(title: "Bronze Focus", requiredMinutes: 60),
    RewardBadge(title: "Silver Focus", requiredMinutes: 180),
    RewardBadge(title: "Gold Focus", requiredMinutes: 300),
    RewardBadge(title: "Platinum Focus", requiredMinutes: 600),
  ];

  bool isUnlocked(RewardBadge reward, int totalMinutes) {
    return totalMinutes >= reward.requiredMinutes;
  }
}