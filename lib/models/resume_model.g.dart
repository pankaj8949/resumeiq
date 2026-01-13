// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResumeModelImpl _$$ResumeModelImplFromJson(Map<String, dynamic> json) =>
    _$ResumeModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      personalInfo: json['personalInfo'] == null
          ? null
          : PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      summary: json['summary'] as String?,
      education:
          (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      experience:
          (json['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => Certification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      theme: json['theme'] as String? ?? 'modern',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      score: (json['score'] as num?)?.toInt(),
      fileUrl: json['fileUrl'] as String?,
    );

Map<String, dynamic> _$$ResumeModelImplToJson(_$ResumeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'personalInfo': instance.personalInfo,
      'summary': instance.summary,
      'education': instance.education,
      'experience': instance.experience,
      'skills': instance.skills,
      'projects': instance.projects,
      'certifications': instance.certifications,
      'theme': instance.theme,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'score': instance.score,
      'fileUrl': instance.fileUrl,
    };

_$PersonalInfoImpl _$$PersonalInfoImplFromJson(Map<String, dynamic> json) =>
    _$PersonalInfoImpl(
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      linkedInUrl: json['linkedInUrl'] as String?,
      portfolioUrl: json['portfolioUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
    );

Map<String, dynamic> _$$PersonalInfoImplToJson(_$PersonalInfoImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'location': instance.location,
      'linkedInUrl': instance.linkedInUrl,
      'portfolioUrl': instance.portfolioUrl,
      'githubUrl': instance.githubUrl,
    };

_$EducationImpl _$$EducationImplFromJson(Map<String, dynamic> json) =>
    _$EducationImpl(
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      fieldOfStudy: json['fieldOfStudy'] as String?,
      startDate: const TimestampConverter().fromJson(json['startDate']),
      endDate: const TimestampConverter().fromJson(json['endDate']),
      description: json['description'] as String?,
      gpa: (json['gpa'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$EducationImplToJson(_$EducationImpl instance) =>
    <String, dynamic>{
      'institution': instance.institution,
      'degree': instance.degree,
      'fieldOfStudy': instance.fieldOfStudy,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'description': instance.description,
      'gpa': instance.gpa,
    };

_$ExperienceImpl _$$ExperienceImplFromJson(Map<String, dynamic> json) =>
    _$ExperienceImpl(
      company: json['company'] as String,
      position: json['position'] as String,
      startDate: const TimestampConverter().fromJson(json['startDate']),
      endDate: const TimestampConverter().fromJson(json['endDate']),
      responsibilities:
          (json['responsibilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      isCurrentRole: json['isCurrentRole'] as bool?,
    );

Map<String, dynamic> _$$ExperienceImplToJson(_$ExperienceImpl instance) =>
    <String, dynamic>{
      'company': instance.company,
      'position': instance.position,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'responsibilities': instance.responsibilities,
      'location': instance.location,
      'isCurrentRole': instance.isCurrentRole,
    };

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      technologies: json['technologies'] as String?,
      url: json['url'] as String?,
      startDate: const TimestampConverter().fromJson(json['startDate']),
      endDate: const TimestampConverter().fromJson(json['endDate']),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'technologies': instance.technologies,
      'url': instance.url,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
    };

_$CertificationImpl _$$CertificationImplFromJson(Map<String, dynamic> json) =>
    _$CertificationImpl(
      name: json['name'] as String,
      issuer: json['issuer'] as String?,
      issueDate: const TimestampConverter().fromJson(json['issueDate']),
      expiryDate: const TimestampConverter().fromJson(json['expiryDate']),
      credentialId: json['credentialId'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$CertificationImplToJson(_$CertificationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'issuer': instance.issuer,
      'issueDate': const TimestampConverter().toJson(instance.issueDate),
      'expiryDate': const TimestampConverter().toJson(instance.expiryDate),
      'credentialId': instance.credentialId,
      'url': instance.url,
    };
