import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResumeStats {
  const ResumeStats({this.totalResumes = 0, this.scoredResumes = 0});

  final int totalResumes;
  final int scoredResumes;

  ResumeStats copyWith({int? totalResumes, int? scoredResumes}) {
    return ResumeStats(
      totalResumes: totalResumes ?? this.totalResumes,
      scoredResumes: scoredResumes ?? this.scoredResumes,
    );
  }
}

class ResumeStatsNotifier extends StateNotifier<ResumeStats> {
  ResumeStatsNotifier() : super(const ResumeStats()) {
    _load();
  }

  static const _kTotalKey = 'resume_stats_total';
  static const _kScoredKey = 'resume_stats_scored';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ResumeStats(
      totalResumes: prefs.getInt(_kTotalKey) ?? 0,
      scoredResumes: prefs.getInt(_kScoredKey) ?? 0,
    );
  }

  Future<void> incrementTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state.totalResumes + 1;
    await prefs.setInt(_kTotalKey, next);
    state = state.copyWith(totalResumes: next);
  }

  Future<void> incrementScored() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state.scoredResumes + 1;
    await prefs.setInt(_kScoredKey, next);
    state = state.copyWith(scoredResumes: next);
  }
}

final resumeStatsProvider =
    StateNotifierProvider<ResumeStatsNotifier, ResumeStats>((ref) {
  return ResumeStatsNotifier();
});

