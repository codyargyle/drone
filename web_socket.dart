// Thanks to Mitrajeet Golsangi whose article helped
// us write the video streaming
// (https://medium.com/dscvitpune/creating-a-live-video-streaming-application-in-flutter-43e261e3a5cc)

import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
//websocket for video stream
class WebSocket {

  late String url;
  WebSocketChannel? _channel;
  StreamController<bool> streamController = StreamController<bool>.broadcast();

  String get getUrl {
    return url;
  }

  set setUrl(String url) {
    this.url = url;
  }

  Stream<dynamic> get stream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      throw WebSocketChannelException("Connection could not be established!");
    }
  }

  WebSocket(this.url);

  void connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
    }
  }

}