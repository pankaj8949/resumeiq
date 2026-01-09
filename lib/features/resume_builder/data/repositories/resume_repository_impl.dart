import 'package:dartz/dartz.dart';
import '../../domain/entities/resume_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/resume_model.dart' as model;
import '../../../../shared/services/firebase_ai_service.dart';
import '../datasources/resume_remote_datasource.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  ResumeRepositoryImpl({
    required ResumeRemoteDataSource remoteDataSource,
    FirebaseAIService? firebaseAIService,
  })  : _remoteDataSource = remoteDataSource,
        _firebaseAIService = firebaseAIService;

  final ResumeRemoteDataSource _remoteDataSource;
  final FirebaseAIService? _firebaseAIService;

  @override
  Future<Either<Failure, ResumeEntity>> createResume(ResumeEntity resume) async {
    try {
      final resumeModel = _entityToModel(resume);
      final created = await _remoteDataSource.createResume(resumeModel);
      return Right(_modelToEntity(created));
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ResumeEntity>> updateResume(ResumeEntity resume) async {
    try {
      final resumeModel = _entityToModel(resume);
      final updated = await _remoteDataSource.updateResume(resumeModel);
      return Right(_modelToEntity(updated));
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, ResumeEntity>> getResume(String resumeId) async {
    try {
      final resume = await _remoteDataSource.getResume(resumeId);
      return Right(_modelToEntity(resume));
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ResumeEntity>>> getUserResumes(String userId) async {
    try {
      final resumes = await _remoteDataSource.getUserResumes(userId);
      return Right(resumes.map(_modelToEntity).toList());
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String resumeId) async {
    try {
      await _remoteDataSource.deleteResume(resumeId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> generateResumeSummary({
    required PersonalInfoEntity personalInfo,
    required List<ExperienceEntity> experience,
    required List<EducationEntity> education,
    required List<String> skills,
  }) async {
    try {
      final prompt = '''
Generate a professional, ATS-optimized resume summary (2-3 sentences) for:

Name: ${personalInfo.fullName}
Education: ${education.map((e) => '${e.degree} from ${e.institution}').join(', ')}
Experience: ${experience.map((e) => '${e.position} at ${e.company}').join(', ')}
Skills: ${skills.join(', ')}

Requirements:
- Maximum 2-3 sentences
- Professional tone
- ATS-friendly keywords
- Highlight key achievements and experience
- No personal pronouns
''';

      if (_firebaseAIService == null) {
        return const Left(ApiFailure(
          message: 'Firebase AI is not configured. Please ensure Firebase is properly set up to use AI features.',
          code: 'MISSING_AI_SERVICE',
        ));
      }
      
      final summary = await _firebaseAIService.generateText(prompt: prompt);
      return Right(summary.trim());
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> generatePDF(ResumeEntity resume) async {
    // PDF generation is now handled directly in the UI using flutter_to_pdf
    // This method is kept for interface compatibility but is not used
    return const Left(ApiFailure(
      message: 'PDF generation should be handled in the UI layer using flutter_to_pdf',
      code: 'USE_UI_EXPORT',
    ));
  }

  model.ResumeModel _entityToModel(ResumeEntity entity) {
    return model.ResumeModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      personalInfo: entity.personalInfo != null
          ? model.PersonalInfo(
              fullName: entity.personalInfo!.fullName,
              email: entity.personalInfo!.email,
              phone: entity.personalInfo!.phone,
              location: entity.personalInfo!.location,
              linkedInUrl: entity.personalInfo!.linkedInUrl,
              portfolioUrl: entity.personalInfo!.portfolioUrl,
              githubUrl: entity.personalInfo!.githubUrl,
            )
          : null,
      summary: entity.summary,
      education: entity.education
          .map((e) => model.Education(
                institution: e.institution,
                degree: e.degree,
                fieldOfStudy: e.fieldOfStudy,
                startDate: e.startDate,
                endDate: e.endDate,
                description: e.description,
                gpa: e.gpa,
              ))
          .toList(),
      experience: entity.experience
          .map((e) => model.Experience(
                company: e.company,
                position: e.position,
                startDate: e.startDate,
                endDate: e.endDate,
                responsibilities: e.responsibilities,
                location: e.location,
                isCurrentRole: e.isCurrentRole,
              ))
          .toList(),
      skills: entity.skills,
      projects: entity.projects
          .map((p) => model.Project(
                name: p.name,
                description: p.description,
                technologies: p.technologies,
                url: p.url,
                startDate: p.startDate,
                endDate: p.endDate,
              ))
          .toList(),
      certifications: entity.certifications
          .map((c) => model.Certification(
                name: c.name,
                issuer: c.issuer,
                issueDate: c.issueDate,
                expiryDate: c.expiryDate,
                credentialId: c.credentialId,
                url: c.url,
              ))
          .toList(),
      theme: entity.theme,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      score: entity.score,
      fileUrl: entity.fileUrl,
    );
  }

  ResumeEntity _modelToEntity(model.ResumeModel model) {
    return ResumeEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      personalInfo: model.personalInfo != null
          ? PersonalInfoEntity(
              fullName: model.personalInfo!.fullName,
              email: model.personalInfo!.email,
              phone: model.personalInfo!.phone,
              location: model.personalInfo!.location,
              linkedInUrl: model.personalInfo!.linkedInUrl,
              portfolioUrl: model.personalInfo!.portfolioUrl,
              githubUrl: model.personalInfo!.githubUrl,
            )
          : null,
      summary: model.summary,
      education: model.education
          .map((e) => EducationEntity(
                institution: e.institution,
                degree: e.degree,
                fieldOfStudy: e.fieldOfStudy,
                startDate: e.startDate,
                endDate: e.endDate,
                description: e.description,
                gpa: e.gpa,
              ))
          .toList(),
      experience: model.experience
          .map((e) => ExperienceEntity(
                company: e.company,
                position: e.position,
                startDate: e.startDate,
                endDate: e.endDate,
                responsibilities: e.responsibilities,
                location: e.location,
                isCurrentRole: e.isCurrentRole,
              ))
          .toList(),
      skills: model.skills,
      projects: model.projects
          .map((p) => ProjectEntity(
                name: p.name,
                description: p.description,
                technologies: p.technologies,
                url: p.url,
                startDate: p.startDate,
                endDate: p.endDate,
              ))
          .toList(),
      certifications: model.certifications
          .map((c) => CertificationEntity(
                name: c.name,
                issuer: c.issuer,
                issueDate: c.issueDate,
                expiryDate: c.expiryDate,
                credentialId: c.credentialId,
                url: c.url,
              ))
          .toList(),
      theme: model.theme,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      score: model.score,
      fileUrl: model.fileUrl,
    );
  }
}

