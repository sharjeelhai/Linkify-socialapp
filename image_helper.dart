import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      debugPrint('ImageHelper: Picking from gallery...');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        debugPrint('ImageHelper: Success - ${file.path}');
        return file;
      } else {
        debugPrint('ImageHelper: No image selected');
        return null;
      }
    } on PlatformException catch (e) {
      debugPrint('ImageHelper: Platform error - $e');
      throw Exception('Permission denied or platform error');
    } catch (e) {
      debugPrint('ImageHelper: General error - $e');
      throw Exception('Could not pick image: $e');
    }
  }

  static Future<File?> pickImage({
    required ImageSource source,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    if (source == ImageSource.gallery) {
      return pickImageFromGallery(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } else {
      // Camera
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: maxWidth?.toDouble(),
          maxHeight: maxHeight?.toDouble(),
          imageQuality: imageQuality,
        );

        if (pickedFile != null) {
          return File(pickedFile.path);
        }
        return null;
      } catch (e) {
        debugPrint('ImageHelper camera error: $e');
        throw Exception('Could not take photo: $e');
      }
    }
  }
}
