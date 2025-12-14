import 'package:equatable/equatable.dart';

class CreatorInsights extends Equatable {
  final String userId;
  final FollowerAnalytics followers;
  final EngagementAnalytics engagement;
  final DemographicAnalytics demographics;
  final ContentPerformance content;
  final MonetizationData monetization;
  final DateTime lastUpdated;

  const CreatorInsights({
    required this.userId,
    required this.followers,
    required this.engagement,
    required this.demographics,
    required this.content,
    required this.monetization,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [userId, followers, engagement, lastUpdated];
}

class FollowerAnalytics extends Equatable {
  final int totalFollowers;
  final int followersGained;
  final int followersLost;
  final double growthRate;
  final List<DailyFollowerData> dailyData;

  const FollowerAnalytics({
    required this.totalFollowers,
    required this.followersGained,
    required this.followersLost,
    required this.growthRate,
    required this.dailyData,
  });

  @override
  List<Object> get props => [totalFollowers, followersGained, growthRate];
}

class EngagementAnalytics extends Equatable {
  final double engagementRate;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalSaves;
  final Map<String, int> bestPostingTimes;

  const EngagementAnalytics({
    required this.engagementRate,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalSaves,
    required this.bestPostingTimes,
  });

  @override
  List<Object> get props => [engagementRate, totalLikes, totalComments];
}

class DemographicAnalytics extends Equatable {
  final Map<String, double> ageGroups;
  final Map<String, double> locations;
  final Map<String, double> genders;

  const DemographicAnalytics({
    required this.ageGroups,
    required this.locations,
    required this.genders,
  });

  @override
  List<Object> get props => [ageGroups, locations, genders];
}

class ContentPerformance extends Equatable {
  final List<PostInsight> posts;
  final List<ReelInsight> reels;
  final List<StoryInsight> stories;

  const ContentPerformance({
    required this.posts,
    required this.reels,
    required this.stories,
  });

  @override
  List<Object> get props => [posts, reels, stories];
}

class PostInsight extends Equatable {
  final String postId;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final double engagementRate;
  final DateTime createdAt;

  const PostInsight({
    required this.postId,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.engagementRate,
    required this.createdAt,
  });

  @override
  List<Object> get props => [postId, views, likes, engagementRate];
}

class ReelInsight extends Equatable {
  final String reelId;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final double watchTime;
  final double completionRate;

  const ReelInsight({
    required this.reelId,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.watchTime,
    required this.completionRate,
  });

  @override
  List<Object> get props => [reelId, views, likes, completionRate];
}

class StoryInsight extends Equatable {
  final String storyId;
  final int views;
  final int replies;
  final int exits;
  final double completionRate;

  const StoryInsight({
    required this.storyId,
    required this.views,
    required this.replies,
    required this.exits,
    required this.completionRate,
  });

  @override
  List<Object> get props => [storyId, views, replies, completionRate];
}

class MonetizationData extends Equatable {
  final double totalEarnings;
  final double monthlyEarnings;
  final int subscribers;
  final List<PayoutRecord> payouts;
  final List<CollaborationOffer> collaborations;

  const MonetizationData({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.subscribers,
    required this.payouts,
    required this.collaborations,
  });

  @override
  List<Object> get props => [totalEarnings, monthlyEarnings, subscribers];
}

class PayoutRecord extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String status;

  const PayoutRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  List<Object> get props => [id, amount, date, status];
}

class CollaborationOffer extends Equatable {
  final String id;
  final String brandName;
  final double amount;
  final String description;
  final DateTime deadline;
  final String status;

  const CollaborationOffer({
    required this.id,
    required this.brandName,
    required this.amount,
    required this.description,
    required this.deadline,
    required this.status,
  });

  @override
  List<Object> get props => [id, brandName, amount, status];
}

class DailyFollowerData extends Equatable {
  final DateTime date;
  final int followers;
  final int gained;
  final int lost;

  const DailyFollowerData({
    required this.date,
    required this.followers,
    required this.gained,
    required this.lost,
  });

  @override
  List<Object> get props => [date, followers, gained, lost];
}

class ContentDraft extends Equatable {
  final String id;
  final String type;
  final String content;
  final List<String> mediaUrls;
  final DateTime? scheduledTime;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentDraft({
    required this.id,
    required this.type,
    required this.content,
    required this.mediaUrls,
    this.scheduledTime,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, type, content, scheduledTime, createdAt];
}