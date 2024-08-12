import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:green_quest/services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;
  String _totalPoints = "0";

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    final leaderboardData = await _leaderboardService.fetchLeaderboard();
    final totalPoints = await _leaderboardService.getTotalPoints();

    setState(() {
      _leaderboard = leaderboardData;
      _totalPoints = totalPoints;
      _isLoading = false;
    });

    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue
            ],
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTotalPoints(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTopThree(),
                          const SizedBox(height: 20),
                          AnimationLimiter(
                            child: Column(
                              children: _leaderboard.skip(3).map((user) {
                                return AnimationConfiguration.staggeredList(
                                  position: _leaderboard.indexOf(user),
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildLeaderboardTile(user),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTotalPoints() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Points',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _totalPoints,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    final topThree = _leaderboard.take(3).toList();

    return Column(
      children: [
        for (int i = 0; i < topThree.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              title: Text(
                topThree[i]['userId'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Text(
                '${topThree[i]['points']} pts',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.green),
        title: Text(user['userId']),
        trailing: Text('${user['points']} pts'),
      ),
    );
  }
}
