import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_quest/services/Points_service.dart';

class CouponsPage extends StatefulWidget {
  @override
  _CouponsPageState createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final UserService _userService = UserService();
  int _userPoints = 0;
  bool _loading = true;

  final List<Map<String, dynamic>> coupons = [
    {
      'title': 'Tree Planting Kit',
      'points': 100,
      'description': 'Get a kit to plant a tree in your local community.',
    },
    {
      'title': 'Reusable Water Bottle',
      'points': 150,
      'description':
          'Receive a stylish and eco-friendly reusable water bottle.',
    },
    {
      'title': 'Organic Grocery Voucher',
      'points': 200,
      'description': 'Redeem this voucher for a discount on organic groceries.',
    },
    {
      'title': 'Eco-Friendly Tote Bag',
      'points': 250,
      'description': 'Get a durable and eco-friendly tote bag for shopping.',
    },
    {
      'title': 'Sustainable Yoga Mat',
      'points': 300,
      'description': 'Receive a yoga mat made from sustainable materials.',
    },
    // Add more coupons as needed
    {
      'title': 'Organic Skincare Set',
      'points': 350,
      'description': 'Pamper yourself with an organic skincare set.',
    },
    {
      'title': 'Eco-Friendly Phone Case',
      'points': 400,
      'description': 'Get a stylish and sustainable phone case.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    try {
      final points = await _userService.getPointsOfUser();
      setState(() {
        _userPoints = points;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching user points: $e");
    }
  }

  Future<void> _redeemCoupon(int pointsRequired, String couponTitle) async {
    if (_userPoints < pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough points to redeem this coupon.')),
      );
      return;
    }

    // Deduct points and update user data
    try {
      await _userService.updatePointsToUser(-pointsRequired);
      setState(() {
        _userPoints -= pointsRequired;
      });

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Coupon Redeemed'),
          content:
              Text('You have successfully redeemed the $couponTitle coupon!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error redeeming coupon: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error redeeming coupon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Coupons'),
          backgroundColor: Colors.green,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          final pointsRequired = coupon['points'] as int;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                coupon['title'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              subtitle: Text(
                coupon['description'] as String,
                style: TextStyle(color: Colors.black54),
              ),
              trailing: _userPoints >= pointsRequired
                  ? ElevatedButton(
                      onPressed: () {
                        _redeemCoupon(
                            pointsRequired, coupon['title'] as String);
                      },
                      child: Text('Redeem'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    )
                  : Text('Requires $pointsRequired points'),
            ),
          );
        },
      ),
    );
  }
}
