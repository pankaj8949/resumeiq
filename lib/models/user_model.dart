import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resumeiq/features/auth/domain/entities/user_entity.dart';
import 'package:resumeiq/features/resume_builder/domain/entities/resume_entity.dart';

/// User model for data layer
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phone,
    super.location,
    super.linkedInUrl,
    super.portfolioUrl,
    super.githubUrl,
    super.summary,
    super.education,
    super.experience,
    super.skills,
    super.projects,
    super.certifications,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      location: data['location'] as String?,
      linkedInUrl: data['linkedInUrl'] as String?,
      portfolioUrl: data['portfolioUrl'] as String?,
      githubUrl: data['githubUrl'] as String?,
      summary: data['summary'] as String?,
      education: _parseEducationList(data['education']),
      experience: _parseExperienceList(data['experience']),
      skills: _parseStringList(data['skills']),
      projects: _parseProjectList(data['projects']),
      certifications: _parseCertificationList(data['certifications']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      location: entity.location,
      linkedInUrl: entity.linkedInUrl,
      portfolioUrl: entity.portfolioUrl,
      githubUrl: entity.githubUrl,
      summary: entity.summary,
      education: entity.education,
      experience: entity.experience,
      skills: entity.skills,
      projects: entity.projects,
      certifications: entity.certifications,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'location': location,
      'linkedInUrl': linkedInUrl,
      'portfolioUrl': portfolioUrl,
      'githubUrl': githubUrl,
      'summary': summary,
      'education': education.map((e) => educationToMap(e)).toList(),
      'experience': experience.map((e) => experienceToMap(e)).toList(),
      'skills': skills,
      'projects': projects.map((p) => projectToMap(p)).toList(),
      'certifications': certifications.map((c) => certificationToMap(c)).toList(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Helper methods to parse from Firestore
  static List<EducationEntity> _parseEducationList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) {
      if (e is! Map<String, dynamic>) return null;
      return EducationEntity(
        institution: e['institution'] as String? ?? '',
        degree: e['degree'] as String? ?? '',
        fieldOfStudy: e['fieldOfStudy'] as String?,
        startDate: (e['startDate'] as Timestamp?)?.toDate(),
        endDate: (e['endDate'] as Timestamp?)?.toDate(),
        description: e['description'] as String?,
        gpa: (e['gpa'] as num?)?.toDouble(),
      );
    }).whereType<EducationEntity>().toList();
  }

  static List<ExperienceEntity> _parseExperienceList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) {
      if (e is! Map<String, dynamic>) return null;
      return ExperienceEntity(
        company: e['company'] as String? ?? '',
        position: e['position'] as String? ?? '',
        startDate: (e['startDate'] as Timestamp?)?.toDate(),
        endDate: (e['endDate'] as Timestamp?)?.toDate(),
        responsibilities: (e['responsibilities'] as List?)?.map((r) => r.toString()).toList() ?? [],
        location: e['location'] as String?,
        isCurrentRole: e['isCurrentRole'] as bool?,
        description: e['description'] as String?,
      );
    }).whereType<ExperienceEntity>().toList();
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  static List<ProjectEntity> _parseProjectList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) {
      if (e is! Map<String, dynamic>) return null;
      return ProjectEntity(
        name: e['name'] as String? ?? '',
        description: e['description'] as String?,
        technologies: e['technologies'] as String?,
        url: e['url'] as String?,
        startDate: (e['startDate'] as Timestamp?)?.toDate(),
        endDate: (e['endDate'] as Timestamp?)?.toDate(),
      );
    }).whereType<ProjectEntity>().toList();
  }

  static List<CertificationEntity> _parseCertificationList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) {
      if (e is! Map<String, dynamic>) return null;
      return CertificationEntity(
        name: e['name'] as String? ?? '',
        issuer: e['issuer'] as String?,
        issueDate: (e['issueDate'] as Timestamp?)?.toDate(),
        expiryDate: (e['expiryDate'] as Timestamp?)?.toDate(),
        credentialId: e['credentialId'] as String?,
        url: e['url'] as String?,
      );
    }).whereType<CertificationEntity>().toList();
  }

  // Helper methods to convert to Firestore format
  static Map<String, dynamic> educationToMap(EducationEntity e) {
    return {
      'institution': e.institution,
      'degree': e.degree,
      'fieldOfStudy': e.fieldOfStudy,
      'startDate': e.startDate != null ? Timestamp.fromDate(e.startDate!) : null,
      'endDate': e.endDate != null ? Timestamp.fromDate(e.endDate!) : null,
      'description': e.description,
      'gpa': e.gpa,
    };
  }

  static Map<String, dynamic> experienceToMap(ExperienceEntity e) {
    return {
      'company': e.company,
      'position': e.position,
      'startDate': e.startDate != null ? Timestamp.fromDate(e.startDate!) : null,
      'endDate': e.endDate != null ? Timestamp.fromDate(e.endDate!) : null,
      'responsibilities': e.responsibilities,
      'location': e.location,
      'isCurrentRole': e.isCurrentRole,
      'description': e.description,
    };
  }

  static Map<String, dynamic> projectToMap(ProjectEntity p) {
    return {
      'name': p.name,
      'description': p.description,
      'technologies': p.technologies,
      'url': p.url,
      'startDate': p.startDate != null ? Timestamp.fromDate(p.startDate!) : null,
      'endDate': p.endDate != null ? Timestamp.fromDate(p.endDate!) : null,
    };
  }

  static Map<String, dynamic> certificationToMap(CertificationEntity c) {
    return {
      'name': c.name,
      'issuer': c.issuer,
      'issueDate': c.issueDate != null ? Timestamp.fromDate(c.issueDate!) : null,
      'expiryDate': c.expiryDate != null ? Timestamp.fromDate(c.expiryDate!) : null,
      'credentialId': c.credentialId,
      'url': c.url,
    };
  }
}

