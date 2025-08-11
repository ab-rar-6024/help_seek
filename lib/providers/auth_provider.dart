import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> sendOTP(String phoneNumber) async {
    setLoading(true);
    setError(null);
    
    await _authService.sendOTP(
      phoneNumber,
      (String verificationId) {
        _verificationId = verificationId;
        setLoading(false);
      },
      (String error) {
        setError(error);
        setLoading(false);
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) return false;
    
    setLoading(true);
    setError(null);
    
    try {
      final credential = await _authService.verifyOTP(_verificationId!, otp);
      if (credential?.user != null) {
        _user = credential!.user;
        await loadUserProfile(_user!.uid);
        setLoading(false);
        return true;
      }
      setLoading(false);
      return false;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      _userProfile = await _authService.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<bool> createProfile(String name, String bio) async {
    if (_user == null) return false;
    
    setLoading(true);
    setError(null);
    
    try {
      final userModel = UserModel(
        id: _user!.uid,
        phoneNumber: _user!.phoneNumber ?? '',
        name: name,
        bio: bio,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );
      
      await _authService.createUserProfile(userModel);
      _userProfile = userModel;
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;
    
    setLoading(true);
    setError(null);
    
    try {
      await _authService.updateUserProfile(_user!.uid, data);
      await loadUserProfile(_user!.uid);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _verificationId = null;
    setLoading(false);
  }
}