// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resume_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ResumeModel _$ResumeModelFromJson(Map<String, dynamic> json) {
  return _ResumeModel.fromJson(json);
}

/// @nodoc
mixin _$ResumeModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  PersonalInfo? get personalInfo => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  List<Education> get education => throw _privateConstructorUsedError;
  List<Experience> get experience => throw _privateConstructorUsedError;
  List<String> get skills => throw _privateConstructorUsedError;
  List<Project> get projects => throw _privateConstructorUsedError;
  List<Certification> get certifications => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  String? get fileUrl => throw _privateConstructorUsedError;

  /// Serializes this ResumeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResumeModelCopyWith<ResumeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResumeModelCopyWith<$Res> {
  factory $ResumeModelCopyWith(
    ResumeModel value,
    $Res Function(ResumeModel) then,
  ) = _$ResumeModelCopyWithImpl<$Res, ResumeModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    PersonalInfo? personalInfo,
    String? summary,
    List<Education> education,
    List<Experience> experience,
    List<String> skills,
    List<Project> projects,
    List<Certification> certifications,
    String theme,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    int? score,
    String? fileUrl,
  });

  $PersonalInfoCopyWith<$Res>? get personalInfo;
}

/// @nodoc
class _$ResumeModelCopyWithImpl<$Res, $Val extends ResumeModel>
    implements $ResumeModelCopyWith<$Res> {
  _$ResumeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? personalInfo = freezed,
    Object? summary = freezed,
    Object? education = null,
    Object? experience = null,
    Object? skills = null,
    Object? projects = null,
    Object? certifications = null,
    Object? theme = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? score = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            personalInfo: freezed == personalInfo
                ? _value.personalInfo
                : personalInfo // ignore: cast_nullable_to_non_nullable
                      as PersonalInfo?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            education: null == education
                ? _value.education
                : education // ignore: cast_nullable_to_non_nullable
                      as List<Education>,
            experience: null == experience
                ? _value.experience
                : experience // ignore: cast_nullable_to_non_nullable
                      as List<Experience>,
            skills: null == skills
                ? _value.skills
                : skills // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            projects: null == projects
                ? _value.projects
                : projects // ignore: cast_nullable_to_non_nullable
                      as List<Project>,
            certifications: null == certifications
                ? _value.certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                      as List<Certification>,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            fileUrl: freezed == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonalInfoCopyWith<$Res>? get personalInfo {
    if (_value.personalInfo == null) {
      return null;
    }

    return $PersonalInfoCopyWith<$Res>(_value.personalInfo!, (value) {
      return _then(_value.copyWith(personalInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResumeModelImplCopyWith<$Res>
    implements $ResumeModelCopyWith<$Res> {
  factory _$$ResumeModelImplCopyWith(
    _$ResumeModelImpl value,
    $Res Function(_$ResumeModelImpl) then,
  ) = __$$ResumeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    PersonalInfo? personalInfo,
    String? summary,
    List<Education> education,
    List<Experience> experience,
    List<String> skills,
    List<Project> projects,
    List<Certification> certifications,
    String theme,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    int? score,
    String? fileUrl,
  });

  @override
  $PersonalInfoCopyWith<$Res>? get personalInfo;
}

/// @nodoc
class __$$ResumeModelImplCopyWithImpl<$Res>
    extends _$ResumeModelCopyWithImpl<$Res, _$ResumeModelImpl>
    implements _$$ResumeModelImplCopyWith<$Res> {
  __$$ResumeModelImplCopyWithImpl(
    _$ResumeModelImpl _value,
    $Res Function(_$ResumeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? personalInfo = freezed,
    Object? summary = freezed,
    Object? education = null,
    Object? experience = null,
    Object? skills = null,
    Object? projects = null,
    Object? certifications = null,
    Object? theme = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? score = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(
      _$ResumeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        personalInfo: freezed == personalInfo
            ? _value.personalInfo
            : personalInfo // ignore: cast_nullable_to_non_nullable
                  as PersonalInfo?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        education: null == education
            ? _value._education
            : education // ignore: cast_nullable_to_non_nullable
                  as List<Education>,
        experience: null == experience
            ? _value._experience
            : experience // ignore: cast_nullable_to_non_nullable
                  as List<Experience>,
        skills: null == skills
            ? _value._skills
            : skills // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        projects: null == projects
            ? _value._projects
            : projects // ignore: cast_nullable_to_non_nullable
                  as List<Project>,
        certifications: null == certifications
            ? _value._certifications
            : certifications // ignore: cast_nullable_to_non_nullable
                  as List<Certification>,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        fileUrl: freezed == fileUrl
            ? _value.fileUrl
            : fileUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResumeModelImpl implements _ResumeModel {
  const _$ResumeModelImpl({
    required this.id,
    required this.userId,
    required this.title,
    this.personalInfo,
    this.summary,
    final List<Education> education = const [],
    final List<Experience> experience = const [],
    final List<String> skills = const [],
    final List<Project> projects = const [],
    final List<Certification> certifications = const [],
    this.theme = 'modern',
    @TimestampConverter() this.createdAt,
    @TimestampConverter() this.updatedAt,
    this.score,
    this.fileUrl,
  }) : _education = education,
       _experience = experience,
       _skills = skills,
       _projects = projects,
       _certifications = certifications;

  factory _$ResumeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResumeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final PersonalInfo? personalInfo;
  @override
  final String? summary;
  final List<Education> _education;
  @override
  @JsonKey()
  List<Education> get education {
    if (_education is EqualUnmodifiableListView) return _education;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_education);
  }

  final List<Experience> _experience;
  @override
  @JsonKey()
  List<Experience> get experience {
    if (_experience is EqualUnmodifiableListView) return _experience;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_experience);
  }

  final List<String> _skills;
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  final List<Project> _projects;
  @override
  @JsonKey()
  List<Project> get projects {
    if (_projects is EqualUnmodifiableListView) return _projects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projects);
  }

  final List<Certification> _certifications;
  @override
  @JsonKey()
  List<Certification> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  @override
  @JsonKey()
  final String theme;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  final int? score;
  @override
  final String? fileUrl;

  @override
  String toString() {
    return 'ResumeModel(id: $id, userId: $userId, title: $title, personalInfo: $personalInfo, summary: $summary, education: $education, experience: $experience, skills: $skills, projects: $projects, certifications: $certifications, theme: $theme, createdAt: $createdAt, updatedAt: $updatedAt, score: $score, fileUrl: $fileUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResumeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.personalInfo, personalInfo) ||
                other.personalInfo == personalInfo) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._education,
              _education,
            ) &&
            const DeepCollectionEquality().equals(
              other._experience,
              _experience,
            ) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            const DeepCollectionEquality().equals(other._projects, _projects) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    personalInfo,
    summary,
    const DeepCollectionEquality().hash(_education),
    const DeepCollectionEquality().hash(_experience),
    const DeepCollectionEquality().hash(_skills),
    const DeepCollectionEquality().hash(_projects),
    const DeepCollectionEquality().hash(_certifications),
    theme,
    createdAt,
    updatedAt,
    score,
    fileUrl,
  );

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResumeModelImplCopyWith<_$ResumeModelImpl> get copyWith =>
      __$$ResumeModelImplCopyWithImpl<_$ResumeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResumeModelImplToJson(this);
  }
}

abstract class _ResumeModel implements ResumeModel {
  const factory _ResumeModel({
    required final String id,
    required final String userId,
    required final String title,
    final PersonalInfo? personalInfo,
    final String? summary,
    final List<Education> education,
    final List<Experience> experience,
    final List<String> skills,
    final List<Project> projects,
    final List<Certification> certifications,
    final String theme,
    @TimestampConverter() final DateTime? createdAt,
    @TimestampConverter() final DateTime? updatedAt,
    final int? score,
    final String? fileUrl,
  }) = _$ResumeModelImpl;

  factory _ResumeModel.fromJson(Map<String, dynamic> json) =
      _$ResumeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  PersonalInfo? get personalInfo;
  @override
  String? get summary;
  @override
  List<Education> get education;
  @override
  List<Experience> get experience;
  @override
  List<String> get skills;
  @override
  List<Project> get projects;
  @override
  List<Certification> get certifications;
  @override
  String get theme;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  int? get score;
  @override
  String? get fileUrl;

  /// Create a copy of ResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResumeModelImplCopyWith<_$ResumeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonalInfo _$PersonalInfoFromJson(Map<String, dynamic> json) {
  return _PersonalInfo.fromJson(json);
}

/// @nodoc
mixin _$PersonalInfo {
  String get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get linkedInUrl => throw _privateConstructorUsedError;
  String? get portfolioUrl => throw _privateConstructorUsedError;
  String? get githubUrl => throw _privateConstructorUsedError;

  /// Serializes this PersonalInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonalInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalInfoCopyWith<PersonalInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalInfoCopyWith<$Res> {
  factory $PersonalInfoCopyWith(
    PersonalInfo value,
    $Res Function(PersonalInfo) then,
  ) = _$PersonalInfoCopyWithImpl<$Res, PersonalInfo>;
  @useResult
  $Res call({
    String fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
  });
}

/// @nodoc
class _$PersonalInfoCopyWithImpl<$Res, $Val extends PersonalInfo>
    implements $PersonalInfoCopyWith<$Res> {
  _$PersonalInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? location = freezed,
    Object? linkedInUrl = freezed,
    Object? portfolioUrl = freezed,
    Object? githubUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            linkedInUrl: freezed == linkedInUrl
                ? _value.linkedInUrl
                : linkedInUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            portfolioUrl: freezed == portfolioUrl
                ? _value.portfolioUrl
                : portfolioUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            githubUrl: freezed == githubUrl
                ? _value.githubUrl
                : githubUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PersonalInfoImplCopyWith<$Res>
    implements $PersonalInfoCopyWith<$Res> {
  factory _$$PersonalInfoImplCopyWith(
    _$PersonalInfoImpl value,
    $Res Function(_$PersonalInfoImpl) then,
  ) = __$$PersonalInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
  });
}

/// @nodoc
class __$$PersonalInfoImplCopyWithImpl<$Res>
    extends _$PersonalInfoCopyWithImpl<$Res, _$PersonalInfoImpl>
    implements _$$PersonalInfoImplCopyWith<$Res> {
  __$$PersonalInfoImplCopyWithImpl(
    _$PersonalInfoImpl _value,
    $Res Function(_$PersonalInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PersonalInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? location = freezed,
    Object? linkedInUrl = freezed,
    Object? portfolioUrl = freezed,
    Object? githubUrl = freezed,
  }) {
    return _then(
      _$PersonalInfoImpl(
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        linkedInUrl: freezed == linkedInUrl
            ? _value.linkedInUrl
            : linkedInUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        portfolioUrl: freezed == portfolioUrl
            ? _value.portfolioUrl
            : portfolioUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        githubUrl: freezed == githubUrl
            ? _value.githubUrl
            : githubUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalInfoImpl implements _PersonalInfo {
  const _$PersonalInfoImpl({
    required this.fullName,
    this.email,
    this.phone,
    this.location,
    this.linkedInUrl,
    this.portfolioUrl,
    this.githubUrl,
  });

  factory _$PersonalInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalInfoImplFromJson(json);

  @override
  final String fullName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? location;
  @override
  final String? linkedInUrl;
  @override
  final String? portfolioUrl;
  @override
  final String? githubUrl;

  @override
  String toString() {
    return 'PersonalInfo(fullName: $fullName, email: $email, phone: $phone, location: $location, linkedInUrl: $linkedInUrl, portfolioUrl: $portfolioUrl, githubUrl: $githubUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalInfoImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.linkedInUrl, linkedInUrl) ||
                other.linkedInUrl == linkedInUrl) &&
            (identical(other.portfolioUrl, portfolioUrl) ||
                other.portfolioUrl == portfolioUrl) &&
            (identical(other.githubUrl, githubUrl) ||
                other.githubUrl == githubUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    email,
    phone,
    location,
    linkedInUrl,
    portfolioUrl,
    githubUrl,
  );

  /// Create a copy of PersonalInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalInfoImplCopyWith<_$PersonalInfoImpl> get copyWith =>
      __$$PersonalInfoImplCopyWithImpl<_$PersonalInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalInfoImplToJson(this);
  }
}

abstract class _PersonalInfo implements PersonalInfo {
  const factory _PersonalInfo({
    required final String fullName,
    final String? email,
    final String? phone,
    final String? location,
    final String? linkedInUrl,
    final String? portfolioUrl,
    final String? githubUrl,
  }) = _$PersonalInfoImpl;

  factory _PersonalInfo.fromJson(Map<String, dynamic> json) =
      _$PersonalInfoImpl.fromJson;

  @override
  String get fullName;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get location;
  @override
  String? get linkedInUrl;
  @override
  String? get portfolioUrl;
  @override
  String? get githubUrl;

  /// Create a copy of PersonalInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalInfoImplCopyWith<_$PersonalInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Education _$EducationFromJson(Map<String, dynamic> json) {
  return _Education.fromJson(json);
}

/// @nodoc
mixin _$Education {
  String get institution => throw _privateConstructorUsedError;
  String get degree => throw _privateConstructorUsedError;
  String? get fieldOfStudy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get gpa => throw _privateConstructorUsedError;

  /// Serializes this Education to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducationCopyWith<Education> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducationCopyWith<$Res> {
  factory $EducationCopyWith(Education value, $Res Function(Education) then) =
      _$EducationCopyWithImpl<$Res, Education>;
  @useResult
  $Res call({
    String institution,
    String degree,
    String? fieldOfStudy,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    String? description,
    double? gpa,
  });
}

/// @nodoc
class _$EducationCopyWithImpl<$Res, $Val extends Education>
    implements $EducationCopyWith<$Res> {
  _$EducationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? institution = null,
    Object? degree = null,
    Object? fieldOfStudy = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? description = freezed,
    Object? gpa = freezed,
  }) {
    return _then(
      _value.copyWith(
            institution: null == institution
                ? _value.institution
                : institution // ignore: cast_nullable_to_non_nullable
                      as String,
            degree: null == degree
                ? _value.degree
                : degree // ignore: cast_nullable_to_non_nullable
                      as String,
            fieldOfStudy: freezed == fieldOfStudy
                ? _value.fieldOfStudy
                : fieldOfStudy // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            gpa: freezed == gpa
                ? _value.gpa
                : gpa // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EducationImplCopyWith<$Res>
    implements $EducationCopyWith<$Res> {
  factory _$$EducationImplCopyWith(
    _$EducationImpl value,
    $Res Function(_$EducationImpl) then,
  ) = __$$EducationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String institution,
    String degree,
    String? fieldOfStudy,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    String? description,
    double? gpa,
  });
}

/// @nodoc
class __$$EducationImplCopyWithImpl<$Res>
    extends _$EducationCopyWithImpl<$Res, _$EducationImpl>
    implements _$$EducationImplCopyWith<$Res> {
  __$$EducationImplCopyWithImpl(
    _$EducationImpl _value,
    $Res Function(_$EducationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? institution = null,
    Object? degree = null,
    Object? fieldOfStudy = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? description = freezed,
    Object? gpa = freezed,
  }) {
    return _then(
      _$EducationImpl(
        institution: null == institution
            ? _value.institution
            : institution // ignore: cast_nullable_to_non_nullable
                  as String,
        degree: null == degree
            ? _value.degree
            : degree // ignore: cast_nullable_to_non_nullable
                  as String,
        fieldOfStudy: freezed == fieldOfStudy
            ? _value.fieldOfStudy
            : fieldOfStudy // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        gpa: freezed == gpa
            ? _value.gpa
            : gpa // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EducationImpl implements _Education {
  const _$EducationImpl({
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    @TimestampConverter() this.startDate,
    @TimestampConverter() this.endDate,
    this.description,
    this.gpa,
  });

  factory _$EducationImpl.fromJson(Map<String, dynamic> json) =>
      _$$EducationImplFromJson(json);

  @override
  final String institution;
  @override
  final String degree;
  @override
  final String? fieldOfStudy;
  @override
  @TimestampConverter()
  final DateTime? startDate;
  @override
  @TimestampConverter()
  final DateTime? endDate;
  @override
  final String? description;
  @override
  final double? gpa;

  @override
  String toString() {
    return 'Education(institution: $institution, degree: $degree, fieldOfStudy: $fieldOfStudy, startDate: $startDate, endDate: $endDate, description: $description, gpa: $gpa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducationImpl &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.fieldOfStudy, fieldOfStudy) ||
                other.fieldOfStudy == fieldOfStudy) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.gpa, gpa) || other.gpa == gpa));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    institution,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    description,
    gpa,
  );

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducationImplCopyWith<_$EducationImpl> get copyWith =>
      __$$EducationImplCopyWithImpl<_$EducationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EducationImplToJson(this);
  }
}

abstract class _Education implements Education {
  const factory _Education({
    required final String institution,
    required final String degree,
    final String? fieldOfStudy,
    @TimestampConverter() final DateTime? startDate,
    @TimestampConverter() final DateTime? endDate,
    final String? description,
    final double? gpa,
  }) = _$EducationImpl;

  factory _Education.fromJson(Map<String, dynamic> json) =
      _$EducationImpl.fromJson;

  @override
  String get institution;
  @override
  String get degree;
  @override
  String? get fieldOfStudy;
  @override
  @TimestampConverter()
  DateTime? get startDate;
  @override
  @TimestampConverter()
  DateTime? get endDate;
  @override
  String? get description;
  @override
  double? get gpa;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducationImplCopyWith<_$EducationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Experience _$ExperienceFromJson(Map<String, dynamic> json) {
  return _Experience.fromJson(json);
}

/// @nodoc
mixin _$Experience {
  String get company => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<String> get responsibilities => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool? get isCurrentRole => throw _privateConstructorUsedError;

  /// Serializes this Experience to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceCopyWith<Experience> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceCopyWith<$Res> {
  factory $ExperienceCopyWith(
    Experience value,
    $Res Function(Experience) then,
  ) = _$ExperienceCopyWithImpl<$Res, Experience>;
  @useResult
  $Res call({
    String company,
    String position,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    List<String> responsibilities,
    String? location,
    bool? isCurrentRole,
  });
}

/// @nodoc
class _$ExperienceCopyWithImpl<$Res, $Val extends Experience>
    implements $ExperienceCopyWith<$Res> {
  _$ExperienceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? position = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? responsibilities = null,
    Object? location = freezed,
    Object? isCurrentRole = freezed,
  }) {
    return _then(
      _value.copyWith(
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            responsibilities: null == responsibilities
                ? _value.responsibilities
                : responsibilities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCurrentRole: freezed == isCurrentRole
                ? _value.isCurrentRole
                : isCurrentRole // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExperienceImplCopyWith<$Res>
    implements $ExperienceCopyWith<$Res> {
  factory _$$ExperienceImplCopyWith(
    _$ExperienceImpl value,
    $Res Function(_$ExperienceImpl) then,
  ) = __$$ExperienceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String company,
    String position,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    List<String> responsibilities,
    String? location,
    bool? isCurrentRole,
  });
}

/// @nodoc
class __$$ExperienceImplCopyWithImpl<$Res>
    extends _$ExperienceCopyWithImpl<$Res, _$ExperienceImpl>
    implements _$$ExperienceImplCopyWith<$Res> {
  __$$ExperienceImplCopyWithImpl(
    _$ExperienceImpl _value,
    $Res Function(_$ExperienceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? position = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? responsibilities = null,
    Object? location = freezed,
    Object? isCurrentRole = freezed,
  }) {
    return _then(
      _$ExperienceImpl(
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        responsibilities: null == responsibilities
            ? _value._responsibilities
            : responsibilities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCurrentRole: freezed == isCurrentRole
            ? _value.isCurrentRole
            : isCurrentRole // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExperienceImpl implements _Experience {
  const _$ExperienceImpl({
    required this.company,
    required this.position,
    @TimestampConverter() this.startDate,
    @TimestampConverter() this.endDate,
    final List<String> responsibilities = const [],
    this.location,
    this.isCurrentRole,
  }) : _responsibilities = responsibilities;

  factory _$ExperienceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperienceImplFromJson(json);

  @override
  final String company;
  @override
  final String position;
  @override
  @TimestampConverter()
  final DateTime? startDate;
  @override
  @TimestampConverter()
  final DateTime? endDate;
  final List<String> _responsibilities;
  @override
  @JsonKey()
  List<String> get responsibilities {
    if (_responsibilities is EqualUnmodifiableListView)
      return _responsibilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responsibilities);
  }

  @override
  final String? location;
  @override
  final bool? isCurrentRole;

  @override
  String toString() {
    return 'Experience(company: $company, position: $position, startDate: $startDate, endDate: $endDate, responsibilities: $responsibilities, location: $location, isCurrentRole: $isCurrentRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceImpl &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._responsibilities,
              _responsibilities,
            ) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isCurrentRole, isCurrentRole) ||
                other.isCurrentRole == isCurrentRole));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    company,
    position,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_responsibilities),
    location,
    isCurrentRole,
  );

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceImplCopyWith<_$ExperienceImpl> get copyWith =>
      __$$ExperienceImplCopyWithImpl<_$ExperienceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperienceImplToJson(this);
  }
}

abstract class _Experience implements Experience {
  const factory _Experience({
    required final String company,
    required final String position,
    @TimestampConverter() final DateTime? startDate,
    @TimestampConverter() final DateTime? endDate,
    final List<String> responsibilities,
    final String? location,
    final bool? isCurrentRole,
  }) = _$ExperienceImpl;

  factory _Experience.fromJson(Map<String, dynamic> json) =
      _$ExperienceImpl.fromJson;

  @override
  String get company;
  @override
  String get position;
  @override
  @TimestampConverter()
  DateTime? get startDate;
  @override
  @TimestampConverter()
  DateTime? get endDate;
  @override
  List<String> get responsibilities;
  @override
  String? get location;
  @override
  bool? get isCurrentRole;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceImplCopyWith<_$ExperienceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get technologies => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    String name,
    String? description,
    String? technologies,
    String? url,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
  });
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? technologies = freezed,
    Object? url = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            technologies: freezed == technologies
                ? _value.technologies
                : technologies // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? description,
    String? technologies,
    String? url,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
  });
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? technologies = freezed,
    Object? url = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _$ProjectImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        technologies: freezed == technologies
            ? _value.technologies
            : technologies // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl implements _Project {
  const _$ProjectImpl({
    required this.name,
    this.description,
    this.technologies,
    this.url,
    @TimestampConverter() this.startDate,
    @TimestampConverter() this.endDate,
  });

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final String? technologies;
  @override
  final String? url;
  @override
  @TimestampConverter()
  final DateTime? startDate;
  @override
  @TimestampConverter()
  final DateTime? endDate;

  @override
  String toString() {
    return 'Project(name: $name, description: $description, technologies: $technologies, url: $url, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.technologies, technologies) ||
                other.technologies == technologies) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    technologies,
    url,
    startDate,
    endDate,
  );

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project implements Project {
  const factory _Project({
    required final String name,
    final String? description,
    final String? technologies,
    final String? url,
    @TimestampConverter() final DateTime? startDate,
    @TimestampConverter() final DateTime? endDate,
  }) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  String? get technologies;
  @override
  String? get url;
  @override
  @TimestampConverter()
  DateTime? get startDate;
  @override
  @TimestampConverter()
  DateTime? get endDate;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Certification _$CertificationFromJson(Map<String, dynamic> json) {
  return _Certification.fromJson(json);
}

/// @nodoc
mixin _$Certification {
  String get name => throw _privateConstructorUsedError;
  String? get issuer => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get issueDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  String? get credentialId => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  /// Serializes this Certification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificationCopyWith<Certification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificationCopyWith<$Res> {
  factory $CertificationCopyWith(
    Certification value,
    $Res Function(Certification) then,
  ) = _$CertificationCopyWithImpl<$Res, Certification>;
  @useResult
  $Res call({
    String name,
    String? issuer,
    @TimestampConverter() DateTime? issueDate,
    @TimestampConverter() DateTime? expiryDate,
    String? credentialId,
    String? url,
  });
}

/// @nodoc
class _$CertificationCopyWithImpl<$Res, $Val extends Certification>
    implements $CertificationCopyWith<$Res> {
  _$CertificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? issuer = freezed,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? credentialId = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            issuer: freezed == issuer
                ? _value.issuer
                : issuer // ignore: cast_nullable_to_non_nullable
                      as String?,
            issueDate: freezed == issueDate
                ? _value.issueDate
                : issueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            credentialId: freezed == credentialId
                ? _value.credentialId
                : credentialId // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificationImplCopyWith<$Res>
    implements $CertificationCopyWith<$Res> {
  factory _$$CertificationImplCopyWith(
    _$CertificationImpl value,
    $Res Function(_$CertificationImpl) then,
  ) = __$$CertificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? issuer,
    @TimestampConverter() DateTime? issueDate,
    @TimestampConverter() DateTime? expiryDate,
    String? credentialId,
    String? url,
  });
}

/// @nodoc
class __$$CertificationImplCopyWithImpl<$Res>
    extends _$CertificationCopyWithImpl<$Res, _$CertificationImpl>
    implements _$$CertificationImplCopyWith<$Res> {
  __$$CertificationImplCopyWithImpl(
    _$CertificationImpl _value,
    $Res Function(_$CertificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? issuer = freezed,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? credentialId = freezed,
    Object? url = freezed,
  }) {
    return _then(
      _$CertificationImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        issuer: freezed == issuer
            ? _value.issuer
            : issuer // ignore: cast_nullable_to_non_nullable
                  as String?,
        issueDate: freezed == issueDate
            ? _value.issueDate
            : issueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        credentialId: freezed == credentialId
            ? _value.credentialId
            : credentialId // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificationImpl implements _Certification {
  const _$CertificationImpl({
    required this.name,
    this.issuer,
    @TimestampConverter() this.issueDate,
    @TimestampConverter() this.expiryDate,
    this.credentialId,
    this.url,
  });

  factory _$CertificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificationImplFromJson(json);

  @override
  final String name;
  @override
  final String? issuer;
  @override
  @TimestampConverter()
  final DateTime? issueDate;
  @override
  @TimestampConverter()
  final DateTime? expiryDate;
  @override
  final String? credentialId;
  @override
  final String? url;

  @override
  String toString() {
    return 'Certification(name: $name, issuer: $issuer, issueDate: $issueDate, expiryDate: $expiryDate, credentialId: $credentialId, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.credentialId, credentialId) ||
                other.credentialId == credentialId) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    issuer,
    issueDate,
    expiryDate,
    credentialId,
    url,
  );

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      __$$CertificationImplCopyWithImpl<_$CertificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificationImplToJson(this);
  }
}

abstract class _Certification implements Certification {
  const factory _Certification({
    required final String name,
    final String? issuer,
    @TimestampConverter() final DateTime? issueDate,
    @TimestampConverter() final DateTime? expiryDate,
    final String? credentialId,
    final String? url,
  }) = _$CertificationImpl;

  factory _Certification.fromJson(Map<String, dynamic> json) =
      _$CertificationImpl.fromJson;

  @override
  String get name;
  @override
  String? get issuer;
  @override
  @TimestampConverter()
  DateTime? get issueDate;
  @override
  @TimestampConverter()
  DateTime? get expiryDate;
  @override
  String? get credentialId;
  @override
  String? get url;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
