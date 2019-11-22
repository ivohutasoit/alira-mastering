import 'package:alira_mobile/message/domain/chat.dart';

class ChatOutgoingController {
  ChatOutgoing chat;

  void Function(ChatOutgoingStatus oldStatus, ChatOutgoingStatus newStatus) onStatusChanged;

  ChatOutgoingController({this.chat});

  void setStatus(ChatOutgoingStatus newStatus) {
    var oldStatus = chat.status;
    if(oldStatus != newStatus) {
      chat.status = newStatus;
      if(onStatusChanged != null) {
        onStatusChanged(oldStatus, newStatus);
      }
    }
  }
}