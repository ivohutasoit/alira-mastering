import 'package:flutter/material.dart';

class ChatNewCreateEvent {
  
}

class ChatSentEvent {
  final String id;
  
  ChatSentEvent({@required this.id});
}

class ChatSentFailedEvent {
  final String id;
  final String error;

  ChatSentFailedEvent({@required this.id, @required this.error});
}

class ChatReceivedEvent {
  final String text;
  
  ChatReceivedEvent({@required this.text});
}

class ChatReceivedFailedEvent {
  final String error;

  ChatReceivedFailedEvent({@required this.error});
}