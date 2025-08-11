import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String category;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> helpers;
  final bool isActive;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
    required this.expiresAt,
    required this.helpers,
    required this.isActive,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      helpers: List<String>.from(data['helpers'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'helpers': helpers,
      'isActive': isActive,
    };
  }
}