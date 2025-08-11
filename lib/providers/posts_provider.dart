import 'package:flutter/material.dart';

class PostsProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  bool _isLoading = false;

  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPosts(List<dynamic> posts) {
    _posts = posts;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addPost(dynamic post) {
    _posts.insert(0, post);
    notifyListeners();
  }
}