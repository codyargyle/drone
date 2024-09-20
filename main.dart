import 'package:flutter/material.dart';

import 'dart:io';
import 'package:drone_vid_player/web_socket.dart';
import 'package:drone_vid_player/video_stream.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:developer';

void main() => runApp(const MaterialApp(
      home: DroneApp(),
    ));

const videoPort = 8080;
const cargoHoldPort = 8001;
const gpsPort = 8081;

/// Stateful widget to fetch and then display video content.
class DroneApp extends StatefulWidget {
  const DroneApp({Key? key}) : super(key: key);

  @override
  _DroneAppState createState() => _DroneAppState();
}

var ip = '169.254.221.209'; // Pifi ip address

class _DroneAppState extends State<DroneApp> {
  final WebSocket _socket =
      WebSocket("ws://$ip:8080"); // TODO - change to use variables instead

  bool _isConnected = false;

//servo connection
  void sendMessage(message, port) {
    Socket.connect(ip, port).then((socket) {
      socket.write(message);
      socket.destroy();
    });
  }

//Front page set up, including video stream as well as controllers
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Casper the Drone'),
              backgroundColor: Colors.blue[200],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                    const VideoStream(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                sendMessage("Load\n", cargoHoldPort),
                            child: const Text("Load"),
                          ),
                          const Text("Cargo Hold"),
                          ElevatedButton(
                            onPressed: () =>
                                sendMessage("Drop\n", cargoHoldPort),
                            child: const Text("Drop"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MapRoute())),
                            child: const Text("Go to Map"),
                          ),
                        ])
                  ])),
            )));
  }
}

//set up for second screen, Map
class MapRoute extends StatefulWidget {
  const MapRoute({super.key});

  @override
  State<MapRoute> createState() => _MyAppState();
}

class _MyAppState extends State<MapRoute> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(40.7623768, -111.8466309);

  LatLng pinPosition = LatLng(40.7658920,
      -111.8437061); //these coordinates will start at the hardcoded ones above and then change as recieveDroneCoordinates is called
  //varying coordinates
  void recieveDroneCoordinates(port) {

    Socket.connect(ip, port).then((socket) {
      socket.listen((data) {

        var pinPosition_array =
         String.fromCharCodes(data).split(',');
         pinPosition = LatLng(double.parse(pinPosition_array[0]),
            double.parse(pinPosition_array[1]));

      }, onDone: (() {
        socket.destroy();
      }));
    });
  }

  //custom image
  late BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = Set();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  
// Custom icon set up
  void setCustomMarker() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 0.5),
            'assets/small_drone_image.png')
        .then((icon) => pinLocationIcon = icon);
  }

  @override
  void initState() {
    setCustomMarker();
    //set timer and call upate every second
    final periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("requesting coordinates");
      recieveDroneCoordinates(gpsPort);

      setState(() {
      print(pinPosition);//HERE is wrong this is the orignal one but not the new ones
      _markers.add(Marker(
          //custom marker
          markerId: MarkerId('<MARKER_ID>'),
          position: pinPosition,//pinPosition
          icon: pinLocationIcon));
    });
    });
  }

//display interactive map on new screen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          backgroundColor: Colors.blue[200],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center, //could change to pin position
            zoom: 11.0,
          ),
          markers: _markers,
       ),
      ),
    );
  }
}

