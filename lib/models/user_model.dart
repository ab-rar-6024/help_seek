import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String name;
  final String bio;
  final String? profileImageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime lastSeen;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.bio = '',
    this.profileImageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? profileImageUrl,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}