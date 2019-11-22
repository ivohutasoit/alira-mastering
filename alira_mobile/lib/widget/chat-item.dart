import 'package:alira_mobile/controller/chat-controller.dart';
import 'package:alira_mobile/message/domain/chat.dart';
import 'package:flutter/material.dart';

abstract class ChatItem extends Widget {
  Chat get chat;

  AnimationController get controller;
}

class ChatIncomingItem extends StatelessWidget implements ChatItem {
  final Chat chat;

  final AnimationController controller;

  ChatIncomingItem({this.chat, this.controller}) : super(key: ObjectKey(chat.id));

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('Server', style: Theme.of(context).textTheme.subhead,),
                  Container(
                    margin: EdgeInsets.only(top: 4.0),
                    child: Text(chat.message),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.pink.shade600,
                child: Text("S"),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class ChatOutgoingItem extends StatefulWidget implements ChatItem {
  final ChatOutgoing chat;

  final ChatOutgoingController chatOutgoingController;

  final AnimationController controller;

  ChatOutgoingItem({this.chat, this.controller}) 
    : chatOutgoingController = ChatOutgoingController(chat: chat,),
      super(key: ObjectKey(chat.id));

  @override
  State<StatefulWidget> createState() => 
    _ChatOutgoingItemState(chatOutgoingController: chatOutgoingController, controller: controller);
}

class _ChatOutgoingItemState extends State<ChatOutgoingItem> {

  final ChatOutgoingController chatOutgoingController;

  final AnimationController controller;

  _ChatOutgoingItemState({this.chatOutgoingController, this.controller}) {
    chatOutgoingController.onStatusChanged = onStatusChanged;
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text("M"),),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Me", style: Theme.of(context).textTheme.subhead,),
                  Container(
                    margin: EdgeInsets.only(top: 4.0),
                    child: Text(chatOutgoingController.chat.message),
                  )
                ],
              ),
            ),
            Container(
              child: Icon(
                chatOutgoingController.chat.status == ChatOutgoingStatus.SENT
                ? Icons.done : Icons.access_time
              ),
            )
          ],
        ),
      ),
    );
  }

  void onStatusChanged(ChatOutgoingStatus oldStatus, ChatOutgoingStatus newStatus) {
    setState(() {
      
    });
  }

}