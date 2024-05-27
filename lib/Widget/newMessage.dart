import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmitted() async {
    final _enteredMessage = _messageController.text;
    if (_enteredMessage.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'createdAt': Timestamp.now(),
      "text": _enteredMessage,
      "userId": user.uid,
      "userImage": userDetails.data()!['image_url'],
      "username": userDetails.data()!['username']
    });
    _messageController.clear();
  }

  Widget build(context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: 15, top: 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                label: Text('Send Message'),
              ),
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              controller: _messageController,
            ),
          ),
          IconButton(onPressed: _onSubmitted, icon: Icon(Icons.send_rounded))
        ],
      ),
    );
  }
}
