import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Create user
  Future<void> createUser({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final user = UserModel(
        id: userId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(user.toFirestore());
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Failed to create user profile');
    }
  }

  // Get user
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Update user
  Future<void> updateUser({
    required String userId,
    String? name,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Failed to update profile');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      // Delete user's posts
      final posts = await _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in posts.docs) {
        await doc.reference.delete();
      }

      // Delete user's comments
      final comments = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Failed to delete user');
    }
  }

  // ==================== POST OPERATIONS ====================

  // Create post
  Future<String> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    // ignore: always_put_required_named_parameters_first
    required String content,
    String? imageUrl,
  }) async {
    try {
      final post = PostModel(
        id: '',
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .add(post.toFirestore());

      return doc.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post');
    }
  }

  // Get posts stream with pagination
  Stream<List<PostModel>> getPostsStream({
    int limit = AppConstants.postsPerPage,
    DocumentSnapshot? startAfter,
  }) {
    var query = _firestore
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
    );
  }

  // Get user posts stream
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();

      // Delete associated comments
      final comments = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      throw Exception('Failed to delete post');
    }
  }

  // ==================== LIKE OPERATIONS ====================

  // Toggle like
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId);

      await _firestore.runTransaction((transaction) async {
        final post = await transaction.get(postRef);
        if (!post.exists) throw Exception('Post not found');

        final data = post.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final likesCount = data['likesCount'] ?? 0;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount - 1,
          });
        } else {
          // Like
          likedBy.add(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount + 1,
          });
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      throw Exception('Failed to update like');
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  // Add comment
  Future<String> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    // ignore: always_put_required_named_parameters_first
    required String content,
  }) async {
    try {
      final comment = CommentModel(
        id: '',
        postId: postId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        createdAt: DateTime.now(),
      );

      final doc = await _firestore
          .collection(AppConstants.commentsCollection)
          .add(comment.toFirestore());

      // Increment comment count
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({'commentsCount': FieldValue.increment(1)});

      return doc.id;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      throw Exception('Failed to add comment');
    }
  }

  // Get comments stream
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection(AppConstants.commentsCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Delete comment
  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .delete();

      // Decrement comment count
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({'commentsCount': FieldValue.increment(-1)});
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      throw Exception('Failed to delete comment');
    }
  }
}
