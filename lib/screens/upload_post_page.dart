import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:green_quest/services/upload_post_service.dart';
import 'package:green_quest/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';

class UploadPostPage extends StatefulWidget {
  @override
  _UploadPostPageState createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  XFile? _image;
  Uint8List? _imageBytes;
  final _captionController = TextEditingController();
  final PostService _postService = PostService();

  void _onImagePicked(XFile? image) async {
    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _image = image;
        _imageBytes = imageBytes;
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_image == null || _imageBytes == null) return;

    try {
      final imageUrl = await _postService.uploadImage(_imageBytes!);
      await _postService.uploadPost(imageUrl, _captionController.text);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Post uploaded!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Post'),
        backgroundColor:
            Colors.green.shade800, // Deep green for eco-friendly theme
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green.shade50, // Light green background
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ImagePickerWidget(onImagePicked: _onImagePicked),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: 'Enter a caption',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadPost,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green.shade600, // Lighter green for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 14.0),
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}
