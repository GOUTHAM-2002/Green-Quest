import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> createUserDocument(String userId) async {
    // Create a new document with the user ID as the document ID
    final userDocRef = _firestore.collection('users').doc(userId);

    // Set initial data for the document
    await userDocRef.set({
      'userId': userId,
      'points': 0, // Start with 0 points
    });
  }

  Future<int> getPointsOfUser() async {
    User? user = _firebaseAuth.currentUser;
    final String userId = user!.uid;
    // Get the document reference for the user
    final userDocRef = _firestore.collection('users').doc(userId);

    // Get the document snapshot
    final docSnapshot = await userDocRef.get();

    // Check if the document exists
    if (docSnapshot.exists) {
      // Extract the points value from the document
      return docSnapshot.data()!['points'] as int;
    } else {
      // If the document doesn't exist, create it with default values
      await createUserDocument(userId);
      return 0; // Return 0 points if the document is newly created
    }
  }

  Future<void> updatePointsToUser(int newPoints) async {
    print("meowwwww");
    User? user = _firebaseAuth.currentUser;
    final String userId = user!.uid;
    // Get the document reference for the user
    final userDocRef = _firestore.collection('users').doc(userId);

    // Retrieve current points (optional, can be done in `getPointsOfUser` if needed)
    final docSnapshot = await userDocRef.get();
    int currentPoints =
        docSnapshot.exists ? docSnapshot.data()!['points'] as int : 0;

    // Calculate the new points by adding the new points to the current points
    int updatedPoints = currentPoints + newPoints;

    // Update the 'points' field with the calculated new value
    await userDocRef.update({
      'points': updatedPoints,
    });
  }
}
