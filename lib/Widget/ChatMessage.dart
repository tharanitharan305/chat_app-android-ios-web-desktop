import 'package:chat_app/Widget/Message_buuble.dart';
import 'package:chat_app/Widget/regersel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  ChatMessage({super.key});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  void getToken() async {
    final fcm = await FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Widget build(context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatsnapshots) {
          if (chatsnapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!chatsnapshots.hasData || chatsnapshots.data!.docs.isEmpty) {
            return Text('No Messages Found');
          }
          if (chatsnapshots.hasError) {
            return Text(
                'Something Went Wrong contact Admin:Tharanitharan kumarasamy....');
          }
          final chatsnapshots_list = chatsnapshots.data!.docs;
          return ListView.builder(
              reverse: true,
              itemCount: chatsnapshots.data!.docs.length,
              itemBuilder: (ctx, index) {
                return Text(chatsnapshots_list[index].data()['text']);
              });
        });
  }
}
