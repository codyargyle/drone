This repository includes all of the scripts necessary for our mobile Drone App. 
This includes: video streaming, servo controls, as well as integration with our gps module to track our drone in real time on a second maps screen. 

The app was created using FlutterFlutter which is an open source framework by Google for building multi-platform applications from a single codebase. In this case, we created the app to mainly be used on IOS devices.

Each feature of the app utilizes a separate port to communicate. Video streaming uses 8080, servo control uses 8001, gps uses 8081. The app is paired with our python server scripts which are run upon Pi startup.

On the first screen, we have our "connect" and "disconnect" buttons for managing the live video stream. At the bottom of that screen, we have controllers for the cargo hold: "load" and "drop". We also have one more button that will help us navigate to our gps tracking map. A custom current location image is used in order to show the live coordinates of our drone. 

