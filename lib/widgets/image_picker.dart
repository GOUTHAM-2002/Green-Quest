import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final void Function(XFile?) onImagePicked;

  ImagePickerWidget({required this.onImagePicked});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _image = pickedFile;
          _imageBytes = imageBytes;
        });
        widget.onImagePicked(_image);
      }
    } catch (e) {
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _image == null
            ? const Text('No image selected.')
            : _imageBytes != null
                ? Image.memory(_imageBytes!, width: 100, height: 100, fit: BoxFit.cover)
                : const Placeholder(
                    child: Text('Image preview not available'),
                  ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Eco-friendly theme
          ),
          child: const Text('Pick Image'),
        ),
      ],
    );
  }
}
