import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:green_quest/widgets/image_picker.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  XFile? _selectedImage;
  String _title = '';
  String _time = '';
  String _description = '';

  Future<void> _addEvent() async {
    if (_title.isNotEmpty &&
        _time.isNotEmpty &&
        _description.isNotEmpty &&
        _selectedImage != null) {
      try {
        final imageBytes = await _selectedImage!.readAsBytes();
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        await imageRef.putData(imageBytes);
        final imageUrl = await imageRef.getDownloadURL();

        await _firestore.collection('events').add({
          'title': _title,
          'time': _time,
          'description': _description,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(), // Add createdAt field
        });

        setState(() {
          _title = '';
          _time = '';
          _description = '';
          _selectedImage = null;
        });
      } catch (e) {
        print("Error adding event: $e");
      }
    }
  }

  void _onImagePicked(XFile? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Add Event"),
                  content: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            onChanged: (value) => _title = value,
                          ),
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Time'),
                            onChanged: (value) => _time = value,
                          ),
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            onChanged: (value) => _description = value,
                          ),
                          const SizedBox(height: 10),
                          ImagePickerWidget(onImagePicked: _onImagePicked),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        _addEvent();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('events')
              .orderBy('createdAt',
                  descending: true) // Order by createdAt in descending order
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No events available.'));
            }

            final events = snapshot.data!.docs;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index].data() as Map<String, dynamic>;
                final imageUrl = event['imageUrl'] as String?;
                final title = event['title'] as String?;
                final time = event['time'] as String?;
                final description = event['description'] as String?;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            title ?? 'No Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            time ?? 'No Time',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description ?? 'No Description',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
