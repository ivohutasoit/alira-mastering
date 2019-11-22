import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Chat {
  static var _uuid = Uuid();
  
  String id;

  String message;

  Chat(this.message, [this.id]) {
    if (id == null) {
      id = _uuid.v4().toString();
    }
  }

  //Chat({String id, @required String message}) : this.id=id ?? UniqueKey().toString(), this.message=message;
}

/// Outgoing message statuses
/// UNKNOWN - message is unknown status
/// SENT - message is sent to the server successfully
enum ChatOutgoingStatus { UNKNOWN, SENT }

class ChatOutgoing extends Chat {
  ChatOutgoingStatus status;

  ChatOutgoing({
    String id, 
    @required String message,
    ChatOutgoingStatus status = ChatOutgoingStatus.UNKNOWN
  }) : this.status = status, super(id, message);
}