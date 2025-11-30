import 'dart:io';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Simple local image storage per user.
/// Saves files under: <app-docs>/users/<userId>/profile/  (profile images)
///                  <app-docs>/users/<userId>/posts/    (post images)
/// Returns file:// URLs that can be used with Image.file or UniversalImage.
class LocalImageService {
  final Uuid _uuid = const Uuid();

  Future<Directory> _userDir(String userId, String subfolder) async {
    final docs = await getApplicationDocumentsDirectory();
    final dirPath = p.join(docs.path, 'users', userId, subfolder);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save profile image and return file:// URL
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final dir = await _userDir(userId, 'profile');
      final fileName = 'profile_${_uuid.v4()}.jpg';
      final destPath = p.join(dir.path, fileName);
      final saved = await imageFile.copy(destPath);
      debugPrint('LocalImageService: saved profile image -> ${saved.path}');
      return 'file://${saved.path}';
    } catch (e) {
      debugPrint('LocalImageService.uploadProfileImage error: $e');
      rethrow;
    }
  }

  /// Save post image and return file:// URL
  Future<String> uploadPostImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final dir = await _userDir(userId, 'posts');
      final fileName = 'post_${_uuid.v4()}.jpg';
      final destPath = p.join(dir.path, fileName);
      final saved = await imageFile.copy(destPath);
      debugPrint('LocalImageService: saved post image -> ${saved.path}');
      return 'file://${saved.path}';
    } catch (e) {
      debugPrint('LocalImageService.uploadPostImage error: $e');
      rethrow;
    }
  }

  /// Delete local image if it exists. Accepts file:// or absolute path.
  Future<void> deleteImage(String imageUrl) async {
    try {
      String path = imageUrl;
      if (imageUrl.startsWith('file://')) {
        path = imageUrl.replaceFirst('file://', '');
      }
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('LocalImageService: deleted $path');
      } else {
        debugPrint('LocalImageService.deleteImage: file not found $path');
      }
    } catch (e) {
      debugPrint('LocalImageService.deleteImage error: $e');
      // don't rethrow - deletion should be best-effort
    }
  }

  /// (Optional) List files for a user (profile or posts)
  Future<List<String>> listUserImages(
    String userId, {
    String subfolder = 'posts',
  }) async {
    final dir = await _userDir(userId, subfolder);
    final List<String> urls = [];
    await for (var entity in dir.list()) {
      if (entity is File) {
        urls.add('file://${entity.path}');
      }
    }
    return urls;
  }
}
