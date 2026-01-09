import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';
import '../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithGoogle();

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
    String? summary,
    List<EducationEntity>? education,
    List<ExperienceEntity>? experience,
    List<String>? skills,
    List<ProjectEntity>? projects,
    List<CertificationEntity>? certifications,
  });

  Stream<UserEntity?> authStateChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Sign out from Google Sign-In first to force account picker to show
      // This doesn't sign out from Firebase Auth, just clears Google Sign-In cache
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow - this will now show account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw AuthException(
          message: 'Sign in was canceled',
          code: 'SIGN_IN_CANCELED',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException(message: 'Sign in failed', code: 'SIGN_IN_FAILED');
      }

      // Get or create user in Firestore
      return await _getUserFromFirestore(userCredential.user!.uid);
    } on PlatformException catch (e) {
      // Google Sign-In specific errors
      throw AuthException(
        message: e.message ?? 'Google Sign-In failed',
        code: e.code,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed', code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'UNKNOWN');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(message: 'Sign out failed', code: 'SIGN_OUT_FAILED');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserFromFirestore(user.uid);
    } catch (e) {
      throw AuthException(message: 'Failed to get current user', code: 'GET_USER_FAILED');
    }
  }


  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
    String? summary,
    List<EducationEntity>? education,
    List<ExperienceEntity>? experience,
    List<String>? skills,
    List<ProjectEntity>? projects,
    List<CertificationEntity>? certifications,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user signed in', code: 'NO_USER');
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();

      // Update Firestore
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }
      if (phone != null) {
        updateData['phone'] = phone;
      }
      if (location != null) {
        updateData['location'] = location;
      }
      if (linkedInUrl != null) {
        updateData['linkedInUrl'] = linkedInUrl;
      }
      if (portfolioUrl != null) {
        updateData['portfolioUrl'] = portfolioUrl;
      }
      if (githubUrl != null) {
        updateData['githubUrl'] = githubUrl;
      }
      if (summary != null) {
        updateData['summary'] = summary;
      }
      if (education != null) {
        updateData['education'] = education.map((e) => UserModel.educationToMap(e)).toList();
      }
      if (experience != null) {
        updateData['experience'] = experience.map((e) => UserModel.experienceToMap(e)).toList();
      }
      if (skills != null) {
        updateData['skills'] = skills;
      }
      if (projects != null) {
        updateData['projects'] = projects.map((p) => UserModel.projectToMap(p)).toList();
      }
      if (certifications != null) {
        updateData['certifications'] = certifications.map((c) => UserModel.certificationToMap(c)).toList();
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      return await _getUserFromFirestore(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to update profile', code: e.code);
    } catch (e) {
      throw AuthException(message: 'Failed to update profile', code: 'UNKNOWN');
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _getUserFromFirestore(user.uid);
      } catch (e) {
        return null;
      }
    });
  }

  Future<UserEntity> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (!doc.exists && firebaseUser != null) {
        // Create user document if it doesn't exist (first time Google sign-in)
        final userModel = UserModel(
          id: uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(uid).set(userModel.toFirestore());
        return userModel;
      }
      
      if (doc.exists) {
        // Update user data if Firebase user has newer info
        if (firebaseUser != null) {
          final existingModel = UserModel.fromFirestore(doc);
          final shouldUpdate = existingModel.displayName != firebaseUser.displayName ||
              existingModel.photoUrl != firebaseUser.photoURL;
          
          if (shouldUpdate) {
            final updatedModel = UserModel(
              id: uid,
              email: firebaseUser.email ?? existingModel.email,
              displayName: firebaseUser.displayName ?? existingModel.displayName,
              photoUrl: firebaseUser.photoURL ?? existingModel.photoUrl,
              createdAt: existingModel.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await _firestore.collection('users').doc(uid).update(updatedModel.toFirestore());
            return updatedModel;
          }
        }
        return UserModel.fromFirestore(doc);
      }
      
      throw AuthException(message: 'User not found', code: 'USER_NOT_FOUND');
    } catch (e) {
      throw AuthException(message: 'Failed to get user data', code: 'GET_USER_DATA_FAILED');
    }
  }
}

