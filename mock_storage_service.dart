import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class MockStorageService {
  final Uuid _uuid = const Uuid();

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, AppConstants.profileImagesPath));
    if (!await folder.exists()) await folder.create(recursive: true);

    final fileName = '${userId}_${_uuid.v4()}.jpg';
    final localPath = p.join(folder.path, fileName);
    await imageFile.copy(localPath);
    debugPrint('MockStorageService: saved profile image to $localPath');
    return 'file://$localPath';
  }

  Future<String> uploadPostImage({
    required String userId,
    required File imageFile,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, AppConstants.postImagesPath));
    if (!await folder.exists()) await folder.create(recursive: true);

    final fileName = '${userId}_${_uuid.v4()}.jpg';
    final localPath = p.join(folder.path, fileName);
    await imageFile.copy(localPath);
    debugPrint('MockStorageService: saved post image to $localPath');
    return 'file://$localPath';
  }
}
