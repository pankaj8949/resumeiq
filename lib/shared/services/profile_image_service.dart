import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageResult {
  const ProfileImageResult({required this.downloadUrl, required this.previewBytes});

  final String downloadUrl;
  final Uint8List previewBytes;
}

/// Service responsible for picking, cropping (1:1), resizing, compressing, and uploading
/// a profile image. This service contains ALL image-upload business logic.
class ProfileImageService {
  static const int _targetSizePx = 512;
  static const int _jpegQuality = 82;

  final ImagePicker _picker = ImagePicker();

  Future<ProfileImageResult?> pickCropCompressAndUpload({required String uid}) async {
    final _PickedImage? picked = await _pickImage();
    if (picked == null) return null;

    Uint8List processedBytes;

    // Use native crop UI where supported. If not supported (e.g. Windows),
    // do a safe center-crop to 1:1 in pure Dart.
    final bool canUseCropperUi = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (canUseCropperUi) {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path ?? '',
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (cropped == null) return null;

      // Robust pipeline: read bytes, then resize/compress in Dart (avoids device-specific
      // issues with native compressors returning null).
      final Uint8List croppedBytes = await cropped.readAsBytes();
      processedBytes = _squareResizeAndCompress(croppedBytes);
    } else {
      // Pure Dart center-crop + resize + jpeg encode (works on desktop + web).
      processedBytes = _squareResizeAndCompress(picked.bytes);
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(uid)
        .child('avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageRef.putData(
      processedBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await storageRef.getDownloadURL();
    return ProfileImageResult(downloadUrl: downloadUrl, previewBytes: processedBytes);
  }

  Future<_PickedImage?> _pickImage() async {
    // On mobile, ImagePicker provides best UX (Photos UI + scoped access).
    final bool useImagePicker = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (useImagePicker) {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: null,
        maxWidth: null,
        maxHeight: null,
      );
      if (file == null) return null;
      return _PickedImage(path: file.path, bytes: await file.readAsBytes());
    }

    // Desktop fallback: FilePicker supports Windows/macOS/Linux.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.first;
    final bytes = f.bytes;
    if (bytes == null) return null;
    return _PickedImage(path: f.path, bytes: bytes);
  }

  Uint8List _squareResizeAndCompress(Uint8List inputBytes) {
    final img.Image? decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    final int size = decoded.width < decoded.height ? decoded.width : decoded.height;
    final int x = ((decoded.width - size) / 2).round();
    final int y = ((decoded.height - size) / 2).round();

    final img.Image square = img.copyCrop(
      decoded,
      x: x < 0 ? 0 : x,
      y: y < 0 ? 0 : y,
      width: size,
      height: size,
    );
    final img.Image resized = img.copyResize(
      square,
      width: _targetSizePx,
      height: _targetSizePx,
      interpolation: img.Interpolation.average,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
  }
}

class _PickedImage {
  const _PickedImage({required this.bytes, this.path});
  final Uint8List bytes;
  final String? path;
}

