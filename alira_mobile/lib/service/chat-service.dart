
import 'dart:io';
import 'dart:isolate';

import 'package:alira_mobile/bloc/chat-event.dart';
import 'package:alira_mobile/google/protobuf/empty.pb.dart';
import 'package:alira_mobile/google/protobuf/wrappers.pb.dart';
import 'package:alira_mobile/message/domain/chat.dart';
import 'package:alira_mobile/service/chat-service.pbgrpc.dart' as service;
import 'package:grpc/grpc.dart';

class ChatService {
  Isolate _isolateSending;
  SendPort _portSending;
  ReceivePort _portSendStatus;
  Isolate _isolateReceiving;
  ReceivePort _portReceiving;

  final void Function(ChatSentEvent event) onChatSent;

  final void Function(ChatSentFailedEvent event) onChatSentFailed;

  final void Function(ChatReceivedEvent event) onChatReceived;

  final void Function(ChatReceivedFailedEvent event) onChatReceivedFailed;

  ChatService({
    this.onChatSent,
    this.onChatSentFailed,
    this.onChatReceived,
    this.onChatReceivedFailed
  }) : this._portSendStatus = ReceivePort(), this._portReceiving = ReceivePort();

  void start() {
    this._startSending();
    this._startReceiving();
  }

  void send(ChatOutgoing chat) {
    assert(this._portSending != null, 'Port to send chat can\'t be null');
    this._portSending.send(chat);
  }

  void stop() {
    this._isolateSending?.kill(priority: Isolate.immediate);
    this._isolateSending = null;
    this._portSendStatus?.close();
    this._portSendStatus = null;

    this._isolateReceiving?.kill(priority: Isolate.immediate);
    this._isolateReceiving = null;
    this._portReceiving?.close();
    this._portReceiving = null;
  }

  void _startSending() async {
    this._isolateSending = await Isolate.spawn(this._sendingIsolate, this._portSendStatus.sendPort);

    await for (var event in _portSendStatus) {
      if (event is SendPort) {
        this._portSending = event;
      } else if (event is ChatSentEvent) {
        if (onChatSent != null) {
          onChatSent(event);
        }
      } else if(event is ChatSentFailedEvent) {
        if (onChatSentFailed != null) {
          onChatSentFailed(event);
        }
      } else {
        assert(false, 'Unknown event type ${event.runtimeType}');
      }
    }
  }

  void _startReceiving() async {
    _isolateReceiving = await Isolate.spawn(_receivingIsolate, _portReceiving.sendPort);

    await for (var event in _portReceiving) {
      if (event is ChatReceivedEvent) {
        if (onChatReceived != null) {
          onChatReceived(event);
        }
      } else if (event is ChatReceivedFailedEvent) {
        if (onChatReceivedFailed != null) {
          onChatReceivedFailed(event);
        }
      }
    }
  }

  void _sendingIsolate(SendPort portSendStatus) async {
    ReceivePort portSendMessages = ReceivePort();

    portSendStatus.send(portSendMessages.sendPort);

    ClientChannel client;
    
    await for (ChatOutgoing chat in portSendMessages) {
      var sent = false;

      do {
        client ??= ClientChannel("localhost", port: 9000, options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 1)
        ));
        try {
          var request = StringValue.create();
          request.value = chat.message;
          await service.ChatServiceClient(client).send(request);
          portSendStatus.send(ChatSentEvent(id: chat.id));
          sent = true;
        } catch (e) {
          portSendStatus.send(ChatSentFailedEvent(id: chat.id, error: e.toString()));
          client.shutdown();
          client = null;
        }

        if(!sent) {
          sleep(Duration(seconds: 3));
        }
      } while(!sent);
    }
  }

  void _receivingIsolate(SendPort portReceive) async {
    ClientChannel client;

    do {
      client ??= ClientChannel("localhost", port: 9000, options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        idleTimeout: Duration(seconds: 1)
      ));
      var stream = service.ChatServiceClient(client).subscribe(Empty.create());

      try {
        await for (var chat in stream) {
          portReceive.send(ChatReceivedEvent(text: chat.message));
        }
      } catch (e) {
        portReceive.send(ChatReceivedFailedEvent(error: e.toString()));
        client.shutdown();
        client = null;
      }
      sleep(Duration(seconds: 5));
    } while(true);
  }
}