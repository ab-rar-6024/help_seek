import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create post
  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _firestore.collection(AppConstants.postsCollection)
          .add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  // Get local posts (within 10km radius)
  Stream<List<PostModel>> getLocalPosts(double userLat, double userLng) {
    return _firestore.collection(AppConstants.postsCollection)
        .where('isLocal', isEqualTo: true)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
      
      // Filter by distance
      return posts.where((post) {
        final distance = Geolocator.distanceBetween(
          userLat, userLng, post.latitude, post.longitude,
        );
        return distance <= AppConstants.localRadiusKm * 1000; // Convert km to meters
      }).toList();
    });
  }

  // Get global posts (beyond 10km radius)
  Stream<List<PostModel>> getGlobalPosts(double userLat, double userLng) {
    return _firestore.collection(AppConstants.postsCollection)
        .where('isLocal', isEqualTo: false)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    });
  }

  // Get user's posts
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore.collection(AppConstants.postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    });
  }

  // Get user's responses (posts they offered help on)
  Stream<List<PostModel>> getUserResponses(String userId) {
    return _firestore.collection(AppConstants.postsCollection)
        .where('helpers', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    });
  }

  // Offer help on a post
  Future<void> offerHelp(String postId, String helperId) async {
    try {
      await _firestore.collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'helpers': FieldValue.arrayUnion([helperId])
      });
    } catch (e) {
      throw e;
    }
  }

  // Accept help
  Future<void> acceptHelp(String postId, String helperId) async {
    try {
      await _firestore.collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'status': AppConstants.statusHelperFound,
        'acceptedHelperId': helperId,
      });
    } catch (e) {
      throw e;
    }
  }

  // Create chat
  Future<String> createChat(ChatModel chat) async {
    try {
      final docRef = await _firestore.collection(AppConstants.chatsCollection)
          .add(chat.toFirestore());
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  // Get user's chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore.collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    });
  }

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(message.chatId)
          .collection(AppConstants.messagesCollection)
          .add(message.toFirestore());

      // Update chat's last message
      await _firestore.collection(AppConstants.chatsCollection)
          .doc(message.chatId)
          .update({
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
      });
    } catch (e) {
      throw e;
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final result = await _firestore.collection(AppConstants.usersCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();
      
      return result.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw e;
    }
  }
}