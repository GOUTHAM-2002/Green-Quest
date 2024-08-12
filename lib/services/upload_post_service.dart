import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_quest/geminni_services/post_points.dart';
import 'package:green_quest/services/Points_service.dart';
import 'package:green_quest/utils/apis.dart';
import 'package:green_quest/services/auth_service.dart';

class PostService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload an image to Firebase Storage
  Future<String> uploadImage(Uint8List imageBytes) async {
    try {
      // Create a unique reference for the image
      final storageRef = _storage
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}');

      // Upload the image with metadata
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  // Upload a new post to Firestore
  Future<void> uploadPost(String imageUrl, String caption) async {
    try {
      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      final String userId = user.uid;

      // Add post data to Firestore
      await _firestore.collection('posts').add({
        'imageUrl': imageUrl,
        'caption': caption,
        'likes': 0,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(), // Add timestamp
      });

      // Get points for the post caption
      final postPointsService = PostPointsService(apiKey: API_KEY);
      final int points = await postPointsService.getPoints(caption);

      // Update user points
      await UserService().updatePointsToUser(points);
    } catch (e) {
      print("Error uploading post: $e");
      rethrow;
    }
  }

  // Fetch posts from Firestore, sorted by creation time
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt',
              descending: true) // Sort by timestamp in descending order
          .get();

      final List<Map<String, dynamic>> posts = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print("Fetched posts: $posts"); // Debugging
      return posts;
    } catch (e) {
      print("Error fetching posts: $e");
      rethrow;
    }
  }
}
