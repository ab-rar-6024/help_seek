import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/chat_model.dart';
import '../utils/constants.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<ChatModel> _chats = [];
  List<MessageModel> _currentChatMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentChatId;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentChatMessages => _currentChatMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentChatId => _currentChatId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void loadUserChats(String userId) {
    _databaseService.getUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  Future<String?> createChat(String postId, List<String> participants) async {
    setLoading(true);
    setError(null);

    try {
      final chat = ChatModel(
        id: '',
        participants: participants,
        postId: postId,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: AppConstants.chatExpiryHours)),
        isActive: true,
      );

      final chatId = await _databaseService.createChat(chat);
      setLoading(false);
      return chatId;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }

  void loadChatMessages(String chatId) {
    _currentChatId = chatId;
    _databaseService.getChatMessages(chatId).listen((messages) {
      _currentChatMessages = messages;
      notifyListeners();
    });
  }

  Future<bool> sendMessage(String chatId, String content, String senderId) async {
    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
      );

      await _databaseService.sendMessage(message);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  void clearCurrentChat() {
    _currentChatId = null;
    _currentChatMessages = [];
    notifyListeners();
  }

  List<ChatModel> getHelpChats() {
    return _chats.where((chat) => chat.postId.isNotEmpty).toList();
  }

  List<ChatModel> getFriendChats() {
    return _chats.where((chat) => chat.postId.isEmpty).toList();
  }
}