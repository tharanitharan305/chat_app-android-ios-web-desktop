import 'package:flutter/material.dart';

class Message_Bubble {
  Message_Bubble({required this.text});
  String text;
  Widget build(context) {
    return Text(text);
  }
}
