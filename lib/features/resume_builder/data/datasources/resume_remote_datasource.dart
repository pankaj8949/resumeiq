import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../shared/models/resume_model.dart' as model;

/// Remote data source for resumes
abstract class ResumeRemoteDataSource {
  Future<model.ResumeModel> createResume(model.ResumeModel resume);
  Future<model.ResumeModel> updateResume(model.ResumeModel resume);
  Future<model.ResumeModel> getResume(String resumeId);
  Future<List<model.ResumeModel>> getUserResumes(String userId);
  Future<void> deleteResume(String resumeId);
}

class ResumeRemoteDataSourceImpl implements ResumeRemoteDataSource {
  ResumeRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  @override
  Future<model.ResumeModel> createResume(model.ResumeModel resume) async {
    try {
      final resumeWithId = resume.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.resumes)
          .doc(resumeWithId.id)
          .set(resumeWithId.toFirestore());

      return resumeWithId;
    } catch (e) {
      throw ServerException(message: 'Failed to create resume: ${e.toString()}', code: 'CREATE_FAILED');
    }
  }

  @override
  Future<model.ResumeModel> updateResume(model.ResumeModel resume) async {
    try {
      final updatedResume = resume.copyWith(updatedAt: DateTime.now());

      // Use set with merge to ensure all fields are updated, including lists
      // This is safer than .update() which only updates provided fields
      await _firestore
          .collection(FirebaseConstants.resumes)
          .doc(resume.id)
          .set(updatedResume.toFirestore(), SetOptions(merge: true));

      return updatedResume;
    } catch (e) {
      throw ServerException(message: 'Failed to update resume: ${e.toString()}', code: 'UPDATE_FAILED');
    }
  }

  @override
  Future<model.ResumeModel> getResume(String resumeId) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.resumes).doc(resumeId).get();

      if (!doc.exists) {
        throw ServerException(message: 'Resume not found', code: 'NOT_FOUND');
      }

      return model.ResumeModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get resume: ${e.toString()}', code: 'GET_FAILED');
    }
  }

  @override
  Future<List<model.ResumeModel>> getUserResumes(String userId) async {
    try {
      // Query without orderBy to avoid requiring a composite index
      // We'll sort in memory instead
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.resumes)
          .where('userId', isEqualTo: userId)
          .get();

      final resumes = querySnapshot.docs
          .map((doc) => model.ResumeModel.fromFirestore(doc))
          .toList();

      // Sort by updatedAt descending in memory
      resumes.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate); // Descending order
      });

      return resumes;
    } catch (e) {
      throw ServerException(message: 'Failed to get resumes: ${e.toString()}', code: 'GET_LIST_FAILED');
    }
  }

  @override
  Future<void> deleteResume(String resumeId) async {
    try {
      await _firestore.collection(FirebaseConstants.resumes).doc(resumeId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete resume: ${e.toString()}', code: 'DELETE_FAILED');
    }
  }
}


