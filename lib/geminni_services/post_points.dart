import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:green_quest/services/Points_service.dart';
import 'package:green_quest/utils/apis.dart';
import 'package:green_quest/utils/prompts.dart';
import 'package:image_picker/image_picker.dart';

class PostPointsService {
  GenerativeModel? _model;
  final String apiKey;

  PostPointsService({required this.apiKey}) {
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<int> getPoints(String caption) async {
    if (_model == null) {
      await _initializeModel();
    }

    final content = [Content.text(postPrompt + caption)];
    final response = await _model!.generateContent(content);

    try {
      return int.parse(response.text!);
    } catch (e) {
      print("Error parsing response to int: $e");
      return 0;
    }
  }
  Future<String> getChatReponse(String prevMessages,String advice) async {
    if (_model == null) {
      await _initializeModel();
    }

    final content = [Content.text(chatPrompt + prevMessages + advice )];
    final response = await _model!.generateContent(content);

    try {
      return response.text!;
    } catch (e) {
      print("Error retrieving response text: $e");
      return "Error";
    }
  }

  Future<String> getChallenge(List<String> prev) async {
    if (_model == null) {
      await _initializeModel();
    }

    final content = [
      Content.text(chellengePromptPrev + prev.toString() + challengePrompAFter)
    ];
    final response = await _model!.generateContent(content);

    try {
      return response.text!;
    } catch (e) {
      print("Error retrieving response text: $e");
      return "Error";
    }
  }

  Future<bool> getPointsForChallenge(String caption, XFile img) async {
    if (_model == null) {
      await _initializeModel();
    }
    final prompt = challengeImagePrompt;
    final imageBytes = await img.readAsBytes();

    final content = [
      Content.multi([
        TextPart(prompt + caption),
        DataPart('image/png', imageBytes),
      ])
    ];
    final response = await _model!.generateContent(content);
    if (response.text!.contains("yes")) {
      UserService user = await UserService();
      user.updatePointsToUser(100);
      print(response.text);
      print(response.text);
      print("i returned true");
      return true;
    }

    print(response.text);
    print(response.text);

    return false;
  }

// Example usage
  void main() async {
    const apiKey = API_KEY; // Your API key
    final postPointsService = PostPointsService(apiKey: apiKey);

    final caption = "I attended a recycling volunteer event.";
    final points = await postPointsService.getPoints(caption);

    print(points); // Display the response
  }
}
