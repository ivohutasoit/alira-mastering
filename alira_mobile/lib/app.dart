import 'package:alira_mobile/pages/chat-page.dart';
import 'package:flutter/material.dart';

class AliraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alira',
      home: ChatPage(),
    );
  }

}