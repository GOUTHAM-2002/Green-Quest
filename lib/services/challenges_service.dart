import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .limit(10) // Fetch up to 10 documents
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => doc.data()['challenge'] as String)
            .toList();
      } else {
        return ["No challenges available at the moment."];
      }
    } catch (e) {
      print("Error fetching challenges: $e");
      return ["Error fetching challenges."];
    }
  }
}
