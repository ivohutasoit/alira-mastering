import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {

  ChatPage() : super(key: ObjectKey("Chat Page"));

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _textController = TextEditingController();

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit == false) {
      _isInit = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alira"),
        elevation: 0.0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
          ],
        ),
      ),
    );
  }

}