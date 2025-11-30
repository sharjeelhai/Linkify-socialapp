import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? bio;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.bio,
    this.photoUrl,
    // ignore: always_put_required_named_parameters_first
    required this.createdAt,
    // ignore: always_put_required_named_parameters_first
    required this.updatedAt,
    this.followers = const [],
    this.following = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'followers': followers,
      'following': following,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? bio,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
