import 'package:flutter/material.dart';
import 'package:green_quest/geminni_services/post_points.dart';
import 'package:green_quest/services/challenges_service.dart';
import 'package:green_quest/utils/apis.dart';
import 'package:green_quest/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({Key? key}) : super(key: key);

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  List<String> _challenges = ["Fetching..."];
  bool _isButtonDisabled = false;
  XFile? _selectedImage;
  bool challengeDone = false;

  @override
  void initState() {
    super.initState();
    _checkChallengeStatus();
  }

  Future<void> _checkChallengeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedChallenge = prefs.getString('savedChallenge');
    final lastFetchTime = prefs.getInt('lastFetchTime') ?? 0;
    final challengeDoneTime = prefs.getInt('challengeDoneTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (savedChallenge != null &&
        currentTime - lastFetchTime < 24 * 60 * 60 * 1000) {
      setState(() {
        _challenges = [savedChallenge];
        _isButtonDisabled = true;
        challengeDone = currentTime - challengeDoneTime < 24 * 60 * 60 * 1000;
      });
    } else {
      _fetchChallenges();
    }
  }

  Future<void> _fetchChallenges() async {
    setState(() {
      _challenges = ["Fetching..."];
    });

    final challengeService = ChallengesService();
    final challenges = await challengeService.getChallenges();

    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    try {
      PostPointsService postPointsService = PostPointsService(apiKey: API_KEY);

      final challengeString = await postPointsService.getChallenge(challenges);

      await prefs.setString('savedChallenge', challengeString);
      await prefs.setInt('lastFetchTime', currentTime);
      await prefs.remove('challengeDoneTime');

      setState(() {
        _challenges = [challengeString];
        _isButtonDisabled = true;
        challengeDone = false;
      });
    } catch (e) {
      setState(() {
        _challenges = ["Error fetching challenges."];
      });
    }
  }

  void _onImagePicked(XFile? image) async {
    setState(() {
      _selectedImage = image;
    });

    PostPointsService postPointsServiceForChallenge =
        PostPointsService(apiKey: API_KEY);

    bool result = await postPointsServiceForChallenge.getPointsForChallenge(
        _challenges.toString(), image!);

    setState(() {
      challengeDone = result;
      if (challengeDone) {
        _saveChallengeCompletionStatus();
      }
    });
  }

  Future<void> _saveChallengeCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('challengeDoneTime', currentTime);

    setState(() {
      challengeDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: challengeDone
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Your challenge for the day is done.',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isButtonDisabled ? null : _fetchChallenges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Fetch Challenges'),
                    ),
                    const SizedBox(height: 20.0),
                    ..._challenges
                        .map((challenge) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  challenge,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.green.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 20.0),
                    ImagePickerWidget(onImagePicked: _onImagePicked),
                    if (_selectedImage != null)
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Upload'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
