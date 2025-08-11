import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(source: source);
    } catch (e) {
      throw e;
    }
  }

  // Pick video from gallery or camera
  Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickVideo(source: source);
    } catch (e) {
      throw e;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw e;
    }
  }

  // Upload post media
  Future<String> uploadPostMedia(String postId, XFile mediaFile, {bool isVideo = false}) async {
    try {
      final extension = isVideo ? 'mp4' : 'jpg';
      final folder = isVideo ? 'post_videos' : 'post_images';
      final ref = _storage.ref().child(folder).child('$postId.$extension');
      final uploadTask = ref.putFile(File(mediaFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw e;
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw e;
    }
  }
}