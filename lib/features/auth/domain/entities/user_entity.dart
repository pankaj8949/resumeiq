import 'package:equatable/equatable.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';

/// User entity for domain layer
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.location,
    this.linkedInUrl,
    this.portfolioUrl,
    this.githubUrl,
    this.summary,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.projects = const [],
    this.certifications = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phone;
  final String? location;
  final String? linkedInUrl;
  final String? portfolioUrl;
  final String? githubUrl;
  final String? summary;
  final List<EducationEntity> education;
  final List<ExperienceEntity> experience;
  final List<String> skills;
  final List<ProjectEntity> projects;
  final List<CertificationEntity> certifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        phone,
        location,
        linkedInUrl,
        portfolioUrl,
        githubUrl,
        summary,
        education,
        experience,
        skills,
        projects,
        certifications,
        createdAt,
        updatedAt,
      ];
}

