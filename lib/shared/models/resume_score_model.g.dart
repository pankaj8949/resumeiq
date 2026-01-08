// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResumeScoreModelImpl _$$ResumeScoreModelImplFromJson(
  Map<String, dynamic> json,
) => _$ResumeScoreModelImpl(
  id: json['id'] as String,
  resumeId: json['resumeId'] as String,
  userId: json['userId'] as String,
  overallScore: (json['overallScore'] as num).toInt(),
  atsCompatibility: (json['atsCompatibility'] as num?)?.toInt() ?? 0,
  keywordMatch: (json['keywordMatch'] as num?)?.toInt() ?? 0,
  contentQuality: (json['contentQuality'] as num?)?.toInt() ?? 0,
  formatting: (json['formatting'] as num?)?.toInt() ?? 0,
  grammar: (json['grammar'] as num?)?.toInt() ?? 0,
  impact: (json['impact'] as num?)?.toInt() ?? 0,
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  weaknesses:
      (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map(
            (e) => ImprovementSuggestion.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  analyzedAt: const TimestampConverter().fromJson(json['analyzedAt']),
  jobDescription: json['jobDescription'] as String?,
);

Map<String, dynamic> _$$ResumeScoreModelImplToJson(
  _$ResumeScoreModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'resumeId': instance.resumeId,
  'userId': instance.userId,
  'overallScore': instance.overallScore,
  'atsCompatibility': instance.atsCompatibility,
  'keywordMatch': instance.keywordMatch,
  'contentQuality': instance.contentQuality,
  'formatting': instance.formatting,
  'grammar': instance.grammar,
  'impact': instance.impact,
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'suggestions': instance.suggestions,
  'analyzedAt': const TimestampConverter().toJson(instance.analyzedAt),
  'jobDescription': instance.jobDescription,
};

_$ImprovementSuggestionImpl _$$ImprovementSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$ImprovementSuggestionImpl(
  category: json['category'] as String,
  suggestion: json['suggestion'] as String,
  priority: json['priority'] as String,
);

Map<String, dynamic> _$$ImprovementSuggestionImplToJson(
  _$ImprovementSuggestionImpl instance,
) => <String, dynamic>{
  'category': instance.category,
  'suggestion': instance.suggestion,
  'priority': instance.priority,
};
