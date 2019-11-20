
import 'dart:isolate';

import 'package:alira_mobile/bloc/chat-event.dart';

class ChatService {
  Isolate _isolateSending;
  SendPort _sendPort;
  Isolate _isolateReceiving;
  ReceivePort _receivePort;

  final void Function(ChatSentEvent event) onChatSent;
}