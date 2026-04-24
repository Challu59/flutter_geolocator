import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      Text("Flutter geolocation",
      style: TextStyle(
        color: Colors.white,
        // fontSize: 20
        fontWeight: FontWeight.bold
      )),
        backgroundColor: Colors.black,
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

            if (_currentPosition != null) ...[
              SizedBox(height: 10,),
              Text("Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}"),
              Text("Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}"),
            ]

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
