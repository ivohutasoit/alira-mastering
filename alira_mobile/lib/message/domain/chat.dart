import 'package:flutter/material.dart';

class Chat {
  final String id;

  final String message;

  Chat({String id, @required String message}) : this.id=id ?? UniqueKey().toString(), this.message=message;
}

/// Outgoing message statuses
/// NEW - message just created and is not sent yet
/// SENT - message is sent to the server successfully
/// FAILED - error has happened while sending message
enum MessageOutgoingStatus { NEW, SENT, FAILED }

class ChatOutgoing extends Chat {
  MessageOutgoingStatus status;

  ChatOutgoing({
    String id, 
    @required String message,
    MessageOutgoingStatus status = MessageOutgoingStatus.NEW
  }) : this.status = status, super(id: id, message: message);

  ChatOutgoing.copy(ChatOutgoing source)
    : this.status = source.status, super(id: source.id, message: source.message);
}

class ChatIncoming extends Chat {
  ChatIncoming({
    String id, 
    @required String message
  }) : super(id: id, message: message);

  ChatIncoming.copy(ChatIncoming source)
    : super(id: source.id, message: source.message);
}