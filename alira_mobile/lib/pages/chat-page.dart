import 'dart:async';

import 'package:alira_mobile/message/domain/chat.dart';
import 'package:alira_mobile/service/chat-service.dart';
import 'package:alira_mobile/util/bandwidth-buffer.dart';
import 'package:alira_mobile/widget/chat-item.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {

  ChatPage() : super(key: ObjectKey("Alira Chat"));

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {

  ChatService _service;

  BandwidthBuffer _bandwidthBuffer;

  final StreamController _streamController = StreamController<List<Chat>>();

  final List<ChatItem> _chatItems = <ChatItem>[];

  final TextEditingController _textController = TextEditingController();

  bool _composing = false;

  @override
  void initState() {
    super.initState();
    _bandwidthBuffer = BandwidthBuffer<Chat>(
      duration: Duration(milliseconds: 500),
      onReceive: _onReceivedFromBuffer,
    );
    _bandwidthBuffer.start();

    _service = ChatService(
      onSentSuccess: _onSentSuccess,
      onSentFailed: _onSentFailed,
      onReceivedSuccess: _onReceiveSuccess,
      onReceivedFailed: _onReceiveFailed
    );
    _service.startListening();
  }

  @override
  void dispose() {
    _service.shutdown();
    _bandwidthBuffer.stop();

    for(ChatItem chatItem in _chatItems) {
      chatItem.controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alira Chat"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: StreamBuilder<List<Chat>>(
              stream: _streamController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    _addChats(snapshot.data);
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    return _chatItems[index];
                  },
                  itemCount: _chatItems.length,
                );
              },
            ),
          ),
          Divider(height: 1.0,),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }

  void _onReceivedFromBuffer(List<Chat> chats) {
    _streamController.add(chats);
  }

  void _onSentSuccess(ChatOutgoing chat) {
    debugPrint("chat \"${chat.message}\" sent to server");
    _bandwidthBuffer.send(chat);
  }

  void _onSentFailed(ChatOutgoing chat, String error) {
    debugPrint("FAILED to send chat \"${chat.message}\" to server: $error");
  }

  void _onReceiveSuccess(Chat chat) {
    debugPrint("received chat from server: \"${chat.message}\"");
    _bandwidthBuffer.send(chat);
  }

  void _onReceiveFailed(String error) {
    debugPrint("FAILED to receive chat from server: $error");
  }

  void _addChats(List<Chat> chats) {
    chats.forEach((chat) {
      var i = _chatItems.indexWhere((chatItem) => chatItem.chat.id == chat.id);
      if (i != -1) {
        var chatItem = _chatItems[i];
        if (chatItem is ChatOutgoingItem) {
          assert(chat is ChatOutgoing, "message must be outgouing type");
          chatItem.chatOutgoingController.setStatus((chat as ChatOutgoing).status); 
        }
      } else {
        ChatItem chatItem;
        var controller = AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this
        );
        switch(chat.runtimeType) {
          case ChatOutgoing:
            chatItem = ChatOutgoingItem(
              chat: chat,
              controller: controller,
            );
            break;
          default:
            chatItem = ChatIncomingItem(
              chat: chat,
              controller: controller,
            );
            break;
        }
        _chatItems.insert(0, chatItem);
        chatItem.controller.forward();
      }
    });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).accentColor,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                maxLines: null,
                textInputAction: TextInputAction.send,
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _composing = text.length > 0;
                  });
                },
                onSubmitted: _composing ? _handleSubmit : null,
                decoration: InputDecoration.collapsed(
                  hintText: 'Send a message'
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _composing ? () => _handleSubmit(_textController.text) : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String message) {
    _textController.clear();
    _composing = false;

    var chat = ChatOutgoing(
      message: message,
    );
    _bandwidthBuffer.send(chat);
    _service.send(chat);
  }

}