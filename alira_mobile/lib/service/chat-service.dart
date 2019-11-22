
import 'package:alira_mobile/google/protobuf/empty.pb.dart';
import 'package:alira_mobile/google/protobuf/wrappers.pb.dart';
import 'package:alira_mobile/message/domain/chat.dart';
import 'package:alira_mobile/service/chat-service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

const server = '127.0.0.1';
const port = 9000;

class ChatService {

  bool _shutdown = false;

  ClientChannel _clientSend;

  ClientChannel _clientReceive;

  final void Function(ChatOutgoing chat) onSentSuccess;

  final void Function(ChatOutgoing chat, String error) onSentFailed;

  final void Function(Chat chat) onReceivedSuccess;

  final void Function(String error) onReceivedFailed;

  ChatService({
    this.onSentSuccess,
    this.onSentFailed,
    this.onReceivedSuccess,
    this.onReceivedFailed
  });

  void send(ChatOutgoing chat) {
    if (_clientSend == null) {
      _clientSend = ClientChannel(
        server,
        port: port,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10)
        )
      );
    }
    var request = StringValue.create();
    request.value = chat.message;

    ChatServiceClient(_clientSend).send(request).then((_) {
      if (onSentSuccess != null) {
        var sentChat = ChatOutgoing(
          message: chat.message,
          id: chat.id,
          status: ChatOutgoingStatus.SENT
        );
        onSentSuccess(sentChat);
      }
    }).catchError((err) {
      if(!_shutdown) {
        _shutdownSend();

        if(onSentFailed != null) {
          onSentFailed(chat, err.toString());
        }
        Future.delayed(Duration(seconds: 30), () {
          send(chat);
        });
      }
    });
  }

  void startListening() {
    if (_clientReceive == null) {
      _clientReceive = ClientChannel(
        server,
        port: port,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10)
        )
      );
      var stream = ChatServiceClient(
        _clientReceive
      ).subscribe(Empty.create());

      stream.forEach((incomingChat) {
        if(onReceivedSuccess != null) {
          var chat = Chat(incomingChat.message);
          onReceivedSuccess(chat);
        }
      }).then((_) {
        throw Exception("stream from server has been created");
      }).catchError((err) {
        if(!_shutdown) {
          _shutdownReceive();

          if(onReceivedFailed != null) {
            onReceivedFailed(err.toString());
          }

          Future.delayed(Duration(seconds: 30), () {
            startListening();
          });
        }
      });
    }
  }

  Future<void> shutdown() async {
    _shutdown = true;
    _shutdownSend();
    _shutdownReceive(); 
  }

  void _shutdownSend() {
    if (_clientSend != null) {
      _clientSend.shutdown();
      _clientSend = null;
    }
  }

  void _shutdownReceive() {
    if (_clientReceive != null) {
      _clientReceive.shutdown();
      _clientReceive = null;
    }
  }
  
  /* 
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
  */
}