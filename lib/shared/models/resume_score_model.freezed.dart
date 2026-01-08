// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resume_score_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ResumeScoreModel _$ResumeScoreModelFromJson(Map<String, dynamic> json) {
  return _ResumeScoreModel.fromJson(json);
}

/// @nodoc
mixin _$ResumeScoreModel {
  String get id => throw _privateConstructorUsedError;
  String get resumeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get overallScore => throw _privateConstructorUsedError;
  int get atsCompatibility => throw _privateConstructorUsedError;
  int get keywordMatch => throw _privateConstructorUsedError;
  int get contentQuality => throw _privateConstructorUsedError;
  int get formatting => throw _privateConstructorUsedError;
  int get grammar => throw _privateConstructorUsedError;
  int get impact => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get weaknesses => throw _privateConstructorUsedError;
  List<ImprovementSuggestion> get suggestions =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get analyzedAt => throw _privateConstructorUsedError;
  String? get jobDescription => throw _privateConstructorUsedError;

  /// Serializes this ResumeScoreModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResumeScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResumeScoreModelCopyWith<ResumeScoreModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResumeScoreModelCopyWith<$Res> {
  factory $ResumeScoreModelCopyWith(
    ResumeScoreModel value,
    $Res Function(ResumeScoreModel) then,
  ) = _$ResumeScoreModelCopyWithImpl<$Res, ResumeScoreModel>;
  @useResult
  $Res call({
    String id,
    String resumeId,
    String userId,
    int overallScore,
    int atsCompatibility,
    int keywordMatch,
    int contentQuality,
    int formatting,
    int grammar,
    int impact,
    List<String> strengths,
    List<String> weaknesses,
    List<ImprovementSuggestion> suggestions,
    @TimestampConverter() DateTime? analyzedAt,
    String? jobDescription,
  });
}

/// @nodoc
class _$ResumeScoreModelCopyWithImpl<$Res, $Val extends ResumeScoreModel>
    implements $ResumeScoreModelCopyWith<$Res> {
  _$ResumeScoreModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResumeScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? resumeId = null,
    Object? userId = null,
    Object? overallScore = null,
    Object? atsCompatibility = null,
    Object? keywordMatch = null,
    Object? contentQuality = null,
    Object? formatting = null,
    Object? grammar = null,
    Object? impact = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? suggestions = null,
    Object? analyzedAt = freezed,
    Object? jobDescription = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            resumeId: null == resumeId
                ? _value.resumeId
                : resumeId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int,
            atsCompatibility: null == atsCompatibility
                ? _value.atsCompatibility
                : atsCompatibility // ignore: cast_nullable_to_non_nullable
                      as int,
            keywordMatch: null == keywordMatch
                ? _value.keywordMatch
                : keywordMatch // ignore: cast_nullable_to_non_nullable
                      as int,
            contentQuality: null == contentQuality
                ? _value.contentQuality
                : contentQuality // ignore: cast_nullable_to_non_nullable
                      as int,
            formatting: null == formatting
                ? _value.formatting
                : formatting // ignore: cast_nullable_to_non_nullable
                      as int,
            grammar: null == grammar
                ? _value.grammar
                : grammar // ignore: cast_nullable_to_non_nullable
                      as int,
            impact: null == impact
                ? _value.impact
                : impact // ignore: cast_nullable_to_non_nullable
                      as int,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            weaknesses: null == weaknesses
                ? _value.weaknesses
                : weaknesses // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<ImprovementSuggestion>,
            analyzedAt: freezed == analyzedAt
                ? _value.analyzedAt
                : analyzedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            jobDescription: freezed == jobDescription
                ? _value.jobDescription
                : jobDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResumeScoreModelImplCopyWith<$Res>
    implements $ResumeScoreModelCopyWith<$Res> {
  factory _$$ResumeScoreModelImplCopyWith(
    _$ResumeScoreModelImpl value,
    $Res Function(_$ResumeScoreModelImpl) then,
  ) = __$$ResumeScoreModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String resumeId,
    String userId,
    int overallScore,
    int atsCompatibility,
    int keywordMatch,
    int contentQuality,
    int formatting,
    int grammar,
    int impact,
    List<String> strengths,
    List<String> weaknesses,
    List<ImprovementSuggestion> suggestions,
    @TimestampConverter() DateTime? analyzedAt,
    String? jobDescription,
  });
}

/// @nodoc
class __$$ResumeScoreModelImplCopyWithImpl<$Res>
    extends _$ResumeScoreModelCopyWithImpl<$Res, _$ResumeScoreModelImpl>
    implements _$$ResumeScoreModelImplCopyWith<$Res> {
  __$$ResumeScoreModelImplCopyWithImpl(
    _$ResumeScoreModelImpl _value,
    $Res Function(_$ResumeScoreModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResumeScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? resumeId = null,
    Object? userId = null,
    Object? overallScore = null,
    Object? atsCompatibility = null,
    Object? keywordMatch = null,
    Object? contentQuality = null,
    Object? formatting = null,
    Object? grammar = null,
    Object? impact = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? suggestions = null,
    Object? analyzedAt = freezed,
    Object? jobDescription = freezed,
  }) {
    return _then(
      _$ResumeScoreModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        resumeId: null == resumeId
            ? _value.resumeId
            : resumeId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int,
        atsCompatibility: null == atsCompatibility
            ? _value.atsCompatibility
            : atsCompatibility // ignore: cast_nullable_to_non_nullable
                  as int,
        keywordMatch: null == keywordMatch
            ? _value.keywordMatch
            : keywordMatch // ignore: cast_nullable_to_non_nullable
                  as int,
        contentQuality: null == contentQuality
            ? _value.contentQuality
            : contentQuality // ignore: cast_nullable_to_non_nullable
                  as int,
        formatting: null == formatting
            ? _value.formatting
            : formatting // ignore: cast_nullable_to_non_nullable
                  as int,
        grammar: null == grammar
            ? _value.grammar
            : grammar // ignore: cast_nullable_to_non_nullable
                  as int,
        impact: null == impact
            ? _value.impact
            : impact // ignore: cast_nullable_to_non_nullable
                  as int,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        weaknesses: null == weaknesses
            ? _value._weaknesses
            : weaknesses // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<ImprovementSuggestion>,
        analyzedAt: freezed == analyzedAt
            ? _value.analyzedAt
            : analyzedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        jobDescription: freezed == jobDescription
            ? _value.jobDescription
            : jobDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResumeScoreModelImpl implements _ResumeScoreModel {
  const _$ResumeScoreModelImpl({
    required this.id,
    required this.resumeId,
    required this.userId,
    required this.overallScore,
    this.atsCompatibility = 0,
    this.keywordMatch = 0,
    this.contentQuality = 0,
    this.formatting = 0,
    this.grammar = 0,
    this.impact = 0,
    final List<String> strengths = const [],
    final List<String> weaknesses = const [],
    final List<ImprovementSuggestion> suggestions = const [],
    @TimestampConverter() this.analyzedAt,
    this.jobDescription,
  }) : _strengths = strengths,
       _weaknesses = weaknesses,
       _suggestions = suggestions;

  factory _$ResumeScoreModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResumeScoreModelImplFromJson(json);

  @override
  final String id;
  @override
  final String resumeId;
  @override
  final String userId;
  @override
  final int overallScore;
  @override
  @JsonKey()
  final int atsCompatibility;
  @override
  @JsonKey()
  final int keywordMatch;
  @override
  @JsonKey()
  final int contentQuality;
  @override
  @JsonKey()
  final int formatting;
  @override
  @JsonKey()
  final int grammar;
  @override
  @JsonKey()
  final int impact;
  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _weaknesses;
  @override
  @JsonKey()
  List<String> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  final List<ImprovementSuggestion> _suggestions;
  @override
  @JsonKey()
  List<ImprovementSuggestion> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  @TimestampConverter()
  final DateTime? analyzedAt;
  @override
  final String? jobDescription;

  @override
  String toString() {
    return 'ResumeScoreModel(id: $id, resumeId: $resumeId, userId: $userId, overallScore: $overallScore, atsCompatibility: $atsCompatibility, keywordMatch: $keywordMatch, contentQuality: $contentQuality, formatting: $formatting, grammar: $grammar, impact: $impact, strengths: $strengths, weaknesses: $weaknesses, suggestions: $suggestions, analyzedAt: $analyzedAt, jobDescription: $jobDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResumeScoreModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.resumeId, resumeId) ||
                other.resumeId == resumeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.atsCompatibility, atsCompatibility) ||
                other.atsCompatibility == atsCompatibility) &&
            (identical(other.keywordMatch, keywordMatch) ||
                other.keywordMatch == keywordMatch) &&
            (identical(other.contentQuality, contentQuality) ||
                other.contentQuality == contentQuality) &&
            (identical(other.formatting, formatting) ||
                other.formatting == formatting) &&
            (identical(other.grammar, grammar) || other.grammar == grammar) &&
            (identical(other.impact, impact) || other.impact == impact) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._weaknesses,
              _weaknesses,
            ) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            (identical(other.jobDescription, jobDescription) ||
                other.jobDescription == jobDescription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    resumeId,
    userId,
    overallScore,
    atsCompatibility,
    keywordMatch,
    contentQuality,
    formatting,
    grammar,
    impact,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_weaknesses),
    const DeepCollectionEquality().hash(_suggestions),
    analyzedAt,
    jobDescription,
  );

  /// Create a copy of ResumeScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResumeScoreModelImplCopyWith<_$ResumeScoreModelImpl> get copyWith =>
      __$$ResumeScoreModelImplCopyWithImpl<_$ResumeScoreModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResumeScoreModelImplToJson(this);
  }
}

abstract class _ResumeScoreModel implements ResumeScoreModel {
  const factory _ResumeScoreModel({
    required final String id,
    required final String resumeId,
    required final String userId,
    required final int overallScore,
    final int atsCompatibility,
    final int keywordMatch,
    final int contentQuality,
    final int formatting,
    final int grammar,
    final int impact,
    final List<String> strengths,
    final List<String> weaknesses,
    final List<ImprovementSuggestion> suggestions,
    @TimestampConverter() final DateTime? analyzedAt,
    final String? jobDescription,
  }) = _$ResumeScoreModelImpl;

  factory _ResumeScoreModel.fromJson(Map<String, dynamic> json) =
      _$ResumeScoreModelImpl.fromJson;

  @override
  String get id;
  @override
  String get resumeId;
  @override
  String get userId;
  @override
  int get overallScore;
  @override
  int get atsCompatibility;
  @override
  int get keywordMatch;
  @override
  int get contentQuality;
  @override
  int get formatting;
  @override
  int get grammar;
  @override
  int get impact;
  @override
  List<String> get strengths;
  @override
  List<String> get weaknesses;
  @override
  List<ImprovementSuggestion> get suggestions;
  @override
  @TimestampConverter()
  DateTime? get analyzedAt;
  @override
  String? get jobDescription;

  /// Create a copy of ResumeScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResumeScoreModelImplCopyWith<_$ResumeScoreModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImprovementSuggestion _$ImprovementSuggestionFromJson(
  Map<String, dynamic> json,
) {
  return _ImprovementSuggestion.fromJson(json);
}

/// @nodoc
mixin _$ImprovementSuggestion {
  String get category => throw _privateConstructorUsedError;
  String get suggestion => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;

  /// Serializes this ImprovementSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImprovementSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImprovementSuggestionCopyWith<ImprovementSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImprovementSuggestionCopyWith<$Res> {
  factory $ImprovementSuggestionCopyWith(
    ImprovementSuggestion value,
    $Res Function(ImprovementSuggestion) then,
  ) = _$ImprovementSuggestionCopyWithImpl<$Res, ImprovementSuggestion>;
  @useResult
  $Res call({String category, String suggestion, String priority});
}

/// @nodoc
class _$ImprovementSuggestionCopyWithImpl<
  $Res,
  $Val extends ImprovementSuggestion
>
    implements $ImprovementSuggestionCopyWith<$Res> {
  _$ImprovementSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImprovementSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? suggestion = null,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestion: null == suggestion
                ? _value.suggestion
                : suggestion // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImprovementSuggestionImplCopyWith<$Res>
    implements $ImprovementSuggestionCopyWith<$Res> {
  factory _$$ImprovementSuggestionImplCopyWith(
    _$ImprovementSuggestionImpl value,
    $Res Function(_$ImprovementSuggestionImpl) then,
  ) = __$$ImprovementSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String suggestion, String priority});
}

/// @nodoc
class __$$ImprovementSuggestionImplCopyWithImpl<$Res>
    extends
        _$ImprovementSuggestionCopyWithImpl<$Res, _$ImprovementSuggestionImpl>
    implements _$$ImprovementSuggestionImplCopyWith<$Res> {
  __$$ImprovementSuggestionImplCopyWithImpl(
    _$ImprovementSuggestionImpl _value,
    $Res Function(_$ImprovementSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImprovementSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? suggestion = null,
    Object? priority = null,
  }) {
    return _then(
      _$ImprovementSuggestionImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestion: null == suggestion
            ? _value.suggestion
            : suggestion // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImprovementSuggestionImpl implements _ImprovementSuggestion {
  const _$ImprovementSuggestionImpl({
    required this.category,
    required this.suggestion,
    required this.priority,
  });

  factory _$ImprovementSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImprovementSuggestionImplFromJson(json);

  @override
  final String category;
  @override
  final String suggestion;
  @override
  final String priority;

  @override
  String toString() {
    return 'ImprovementSuggestion(category: $category, suggestion: $suggestion, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImprovementSuggestionImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, suggestion, priority);

  /// Create a copy of ImprovementSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImprovementSuggestionImplCopyWith<_$ImprovementSuggestionImpl>
  get copyWith =>
      __$$ImprovementSuggestionImplCopyWithImpl<_$ImprovementSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ImprovementSuggestionImplToJson(this);
  }
}

abstract class _ImprovementSuggestion implements ImprovementSuggestion {
  const factory _ImprovementSuggestion({
    required final String category,
    required final String suggestion,
    required final String priority,
  }) = _$ImprovementSuggestionImpl;

  factory _ImprovementSuggestion.fromJson(Map<String, dynamic> json) =
      _$ImprovementSuggestionImpl.fromJson;

  @override
  String get category;
  @override
  String get suggestion;
  @override
  String get priority;

  /// Create a copy of ImprovementSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImprovementSuggestionImplCopyWith<_$ImprovementSuggestionImpl>
  get copyWith => throw _privateConstructorUsedError;
}
