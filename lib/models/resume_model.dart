import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'resume_model.freezed.dart';
part 'resume_model.g.dart';

@freezed
class ResumeModel with _$ResumeModel {
  const factory ResumeModel({
    required String id,
    required String userId,
    required String title,
    PersonalInfo? personalInfo,
    String? summary,
    @Default([]) List<Education> education,
    @Default([]) List<Experience> experience,
    @Default([]) List<String> skills,
    @Default([]) List<Project> projects,
    @Default([]) List<Certification> certifications,
    @Default('modern') String theme,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    int? score,
    String? fileUrl,
  }) = _ResumeModel;

  factory ResumeModel.fromJson(Map<String, dynamic> json) =>
      _$ResumeModelFromJson(json);

  factory ResumeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResumeModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }
}

extension ResumeModelFirestoreExtension on ResumeModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    
    // Always serialize personalInfo if it exists
    if (personalInfo != null) {
      json['personalInfo'] = personalInfo!.toJson();
    } else {
      json['personalInfo'] = null;
    }
    
    // Always serialize lists (even if empty) to ensure they're saved to Firestore
    // This is critical for updates - Firestore .update() only updates provided fields
    json['education'] = education.map((e) => e.toJson()).toList();
    json['experience'] = experience.map((e) => e.toJson()).toList();
    json['skills'] = skills;
    json['projects'] = projects.map((p) => p.toJson()).toList();
    json['certifications'] = certifications.map((c) => c.toJson()).toList();
    
    return json;
  }
}

@freezed
class PersonalInfo with _$PersonalInfo {
  const factory PersonalInfo({
    required String fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
  }) = _PersonalInfo;

  factory PersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$PersonalInfoFromJson(json);
}

@freezed
class Education with _$Education {
  const factory Education({
    required String institution,
    required String degree,
    String? fieldOfStudy,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    String? description,
    double? gpa,
  }) = _Education;

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
}

@freezed
class Experience with _$Experience {
  const factory Experience({
    required String company,
    required String position,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    @Default([]) List<String> responsibilities,
    String? location,
    bool? isCurrentRole,
  }) = _Experience;

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
}

@freezed
class Project with _$Project {
  const factory Project({
    required String name,
    String? description,
    String? technologies,
    String? url,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

@freezed
class Certification with _$Certification {
  const factory Certification({
    required String name,
    String? issuer,
    @TimestampConverter() DateTime? issueDate,
    @TimestampConverter() DateTime? expiryDate,
    String? credentialId,
    String? url,
  }) = _Certification;

  factory Certification.fromJson(Map<String, dynamic> json) =>
      _$CertificationFromJson(json);
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

