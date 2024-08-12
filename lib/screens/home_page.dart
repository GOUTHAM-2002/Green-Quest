import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:green_quest/screens/challenges_page.dart';
import 'package:green_quest/screens/chat_page.dart';
import 'package:green_quest/screens/coupons_page.dart';
import 'package:green_quest/screens/events_page.dart';
import 'package:green_quest/screens/feed_page.dart';
import 'package:green_quest/screens/leaderboard_page.dart';
import 'package:green_quest/screens/upload_post_page.dart';
import 'package:green_quest/services/Points_service.dart';

class HomePage extends StatefulWidget {
  final String name;
  const HomePage({super.key, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int GlobalPoints = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPointsAndSetState();
  }

  Future<void> _fetchPointsAndSetState() async {
    int currentPoints = await UserService().getPointsOfUser();
    setState(() {
      GlobalPoints = currentPoints;
    });
  }

  final PageController _pageController = PageController();

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      print("You are logged out.");
      Navigator.of(context).pop();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Green Quest',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Roboto', // Customize font if needed
                  color: Colors.green.shade900, // Darker green for better contrast
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16), // Spacing between title and points
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Solid background for better contrast
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  '$GlobalPoints Eco Points',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade900, // Darker green to stand out
                      fontWeight: FontWeight.w500), // Slightly bolder font
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upload, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UploadPostPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          FeedPage(),
          // CouponsPage(),
          const EventsPage(),
          const ChallengesPage(),
          const LeaderboardPage(),
          const ChatPage(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.green,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          });
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.white,
            inactiveColor: Colors.green.shade200,
          ),
          // BottomNavyBarItem(
          //   icon: Icon(Icons.card_giftcard),
          //   title: Text('Coupons'),
          //   activeColor: Colors.white,
          //   inactiveColor: Colors.green.shade200,
          // ),
          BottomNavyBarItem(
            icon: Icon(Icons.calendar_month),
            title: Text('Events'),
            activeColor: Colors.white,
            inactiveColor: Colors.green.shade200,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.event_available_rounded),
            title: Text('Challenges'),
            activeColor: Colors.white,
            inactiveColor: Colors.green.shade200,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.trip_origin),
            title: Text('Leaderboard'),
            activeColor: Colors.white,
            inactiveColor: Colors.green.shade200,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.help_outline),
            title: Text('Help'),
            activeColor: Colors.white,
            inactiveColor: Colors.green.shade200,
          ),
        ],
      ),
    );
  }
}
