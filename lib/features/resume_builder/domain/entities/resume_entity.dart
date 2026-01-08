import 'package:equatable/equatable.dart';

/// Resume entity for domain layer
class ResumeEntity extends Equatable {
  const ResumeEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.personalInfo,
    this.summary,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.projects = const [],
    this.certifications = const [],
    this.theme = 'modern',
    this.createdAt,
    this.updatedAt,
    this.score,
    this.fileUrl,
  });

  final String id;
  final String userId;
  final String title;
  final PersonalInfoEntity? personalInfo;
  final String? summary;
  final List<EducationEntity> education;
  final List<ExperienceEntity> experience;
  final List<String> skills;
  final List<ProjectEntity> projects;
  final List<CertificationEntity> certifications;
  final String theme;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? score;
  final String? fileUrl;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        personalInfo,
        summary,
        education,
        experience,
        skills,
        projects,
        certifications,
        theme,
        createdAt,
        updatedAt,
        score,
        fileUrl,
      ];
}

class PersonalInfoEntity extends Equatable {
  const PersonalInfoEntity({
    required this.fullName,
    this.email,
    this.phone,
    this.location,
    this.linkedInUrl,
    this.portfolioUrl,
    this.githubUrl,
  });

  final String fullName;
  final String? email;
  final String? phone;
  final String? location;
  final String? linkedInUrl;
  final String? portfolioUrl;
  final String? githubUrl;

  @override
  List<Object?> get props => [fullName, email, phone, location, linkedInUrl, portfolioUrl, githubUrl];
}

class EducationEntity extends Equatable {
  const EducationEntity({
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.description,
    this.gpa,
  });

  final String institution;
  final String degree;
  final String? fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final double? gpa;

  @override
  List<Object?> get props => [institution, degree, fieldOfStudy, startDate, endDate, description, gpa];
}

class ExperienceEntity extends Equatable {
  const ExperienceEntity({
    required this.company,
    required this.position,
    this.startDate,
    this.endDate,
    this.responsibilities = const [],
    this.location,
    this.isCurrentRole,
  });

  final String company;
  final String position;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> responsibilities;
  final String? location;
  final bool? isCurrentRole;

  @override
  List<Object?> get props => [company, position, startDate, endDate, responsibilities, location, isCurrentRole];
}

class ProjectEntity extends Equatable {
  const ProjectEntity({
    required this.name,
    this.description,
    this.technologies,
    this.url,
    this.startDate,
    this.endDate,
  });

  final String name;
  final String? description;
  final String? technologies;
  final String? url;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [name, description, technologies, url, startDate, endDate];
}

class CertificationEntity extends Equatable {
  const CertificationEntity({
    required this.name,
    this.issuer,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.url,
  });

  final String name;
  final String? issuer;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? url;

  @override
  List<Object?> get props => [name, issuer, issueDate, expiryDate, credentialId, url];
}


