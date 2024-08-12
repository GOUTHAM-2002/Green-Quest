import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    try {
      final usersCollection = _firestore.collection('users');
      final querySnapshot = await usersCollection.orderBy('points', descending: true).get();
      
      final userList = querySnapshot.docs.map((doc) {
        return {
          'userId': doc['userId'],
          'points': doc['points'],
        };
      }).toList();

      return userList;
    } catch (e) {
      print("Error fetching leaderboard data: $e");
      return [];
    }
  }
   Future<String> getTotalPoints() async {
    try {
      final usersCollection = _firestore.collection('users');
      final querySnapshot = await usersCollection.get();

      int totalPoints = querySnapshot.docs.fold(0, (sum, doc) {
        return sum + (doc['points'] as int);
      });

      return totalPoints.toString();
    } catch (e) {
      print("Error fetching total points: $e");
      return "0";
    }
  }
}
