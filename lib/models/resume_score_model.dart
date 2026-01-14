import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'resume_score_model.freezed.dart';
part 'resume_score_model.g.dart';

@freezed
class ResumeScoreModel with _$ResumeScoreModel {
  const factory ResumeScoreModel({
    required String id,
    required String resumeId,
    required String userId,
    required int overallScore,
    @Default(0) int atsCompatibility,
    @Default(0) int keywordMatch,
    @Default(0) int contentQuality,
    @Default(0) int formatting,
    @Default(0) int grammar,
    @Default(0) int impact,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
    @Default([]) List<ImprovementSuggestion> suggestions,
    @TimestampConverter() DateTime? analyzedAt,
    String? jobDescription,
  }) = _ResumeScoreModel;

  factory ResumeScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeScoreModelFromJson(json);

  factory ResumeScoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResumeScoreModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }
}

extension ResumeScoreModelFirestoreExtension on ResumeScoreModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

@freezed
class ImprovementSuggestion with _$ImprovementSuggestion {
  const factory ImprovementSuggestion({
    required String category,
    required String suggestion,
    required String priority,
  }) = _ImprovementSuggestion;

  factory ImprovementSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ImprovementSuggestionFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}