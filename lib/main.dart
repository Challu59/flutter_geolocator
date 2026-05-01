import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //theme for the application
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFF151414),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30)
          )
        )
      ),
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Press the button to get location";
  Position? _currentPosition;

  //dummy friend locations
  List<LatLng> _friendLocations = [
    LatLng(27.6940, 85.2870),
    LatLng(27.7000, 85.3333),
    LatLng(27.7100, 85.3100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      Text("Flutter geolocation",
      style: TextStyle(
        color: Colors.white,
        letterSpacing: 3,
        // fontSize: 20
        fontWeight: FontWeight.bold
      )),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Icon(Icons.gps_fixed),

        // actions: [
        //   IconButton(onPressed: (){
        //     ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("This is an alert!")));
        //   },
        //       icon: Icon(Icons.add_alert))
        // ],

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                _locationMessage,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                _getLocation();
            },
                child: Text("Get current GPS location")
            ),

            //show the widgets only after current position is fetched
            if (_currentPosition != null) ...[
              SizedBox(height: 10,),
              Text("Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}"),
              Text("Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}"),

              SizedBox(height: 20,),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: FlutterMap(options:
                MapOptions(
                  initialCenter: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.aayush.flutter_geolocator',
                      ),
                      MarkerLayer(markers: [
                        Marker(point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            )),
                        ..._friendLocations.map((location) => Marker(
                            point: location,
                            child: Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 40,
                            )))
                      ])
                    ]

                ),
              )
            ],

          ],
        ),
      ),
    );
  }
Future<void> _getLocation() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      setState(() {
        _locationMessage = "Location service is not enabled, please enable it";
      });
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied){
          setState(() {
            _locationMessage = "Location permission is denied";
          });
        }
    }

    if(permission == LocationPermission.deniedForever){
      setState(() {
        _locationMessage = "Location permission is denied forever, please enable it from settings.";
      });
    }

    try{
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _locationMessage = "Location found";
        _currentPosition = position;
      });
    }
    catch(e){
      setState(() {
        _locationMessage = "Error: $e";
      });
    }

  }
}


