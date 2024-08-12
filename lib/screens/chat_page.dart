import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_quest/geminni_services/post_points.dart';
import 'package:green_quest/utils/apis.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  late final String _userId;
  String prevMessages = "";
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _userId = _firebaseAuth.currentUser?.uid ?? '';
  }

  void _printAllMessages() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    final messages = querySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['text'] as String)
        .toList();
    final allMessages = messages.join(' ');

    print(allMessages);
    prevMessages = allMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_userId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet"));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessage(message);
                    },
                  );
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(QueryDocumentSnapshot message) {
    final data = message.data() as Map<String, dynamic>;
    final text = data['text'] ?? '';
    final isUserMessage = data['senderId'] == _userId;
    final timestamp = data['timestamp']?.toDate();
    final timeText = timestamp != null
        ? '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (timeText.isNotEmpty)
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (text) => _handleSendPressed(text),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.green),
            onPressed: () => _handleSendPressed(_textController.text),
          ),
        ],
      ),
    );
  }

  void _handleSendPressed(String text) async {
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isTyping = true;
    });

    PostPointsService postPointsService = PostPointsService(apiKey: API_KEY);

    final response = await postPointsService.getChatReponse(prevMessages, text);

    _firestore.collection('users').doc(_userId).collection('messages').add({
      'text': text,
      'senderId': _userId,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      _printAllMessages();
    });

    Future.delayed(Duration(seconds: 1), () {
      _firestore.collection('users').doc(_userId).collection('messages').add({
        'text': response,
        'senderId': 'system',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isTyping = false;
      });
    });
  }
}
