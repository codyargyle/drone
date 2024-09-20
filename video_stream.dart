// Thanks to Mitrajeet Golsangi whose article helped
// us write the video streaming
// (https://medium.com/dscvitpune/creating-a-live-video-streaming-application-in-flutter-43e261e3a5cc)

import 'dart:convert';
import 'dart:typed_data';

import 'package:drone_vid_player/main.dart';
import 'package:flutter/material.dart';
import 'package:drone_vid_player/web_socket.dart';

class VideoStream extends StatefulWidget {
  const VideoStream({Key? key}) : super(key: key);

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

//websocket for video stream using port 8080
class _VideoStreamState extends State<VideoStream> {
  final WebSocket _socket = WebSocket("ws://$ip:8080");
  bool _isConnected = false;

  void connect(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => connect(context),
              child: const Text("Connect"),
            ),
            ElevatedButton(
              onPressed: disconnect,
              child: const Text("Disconnect"),
            ),
          ],
        ),
        const SizedBox(
          height: 25.0,
        ),
        _isConnected
            ? StreamBuilder(
                stream: _socket.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Center(
                      child: Text("Connection Closed!"),
                    );
                  }
                  // Working for single frames
                  return Image.memory(
                    Uint8List.fromList(
                      base64Decode(
                        (snapshot.data.toString()),
                      ),
                    ),
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  );
                },
              )
            : const Text("Not connected to video stream"),
        Image.asset('assets/large_drone_image.png')
      ],
    );
  }
}
