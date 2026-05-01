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
  String _locationMessage = "Press the button to get location"; // to remove
  String _status = "Ready to locate your location";
  Position? _currentPosition;
  final MapController _mapController = MapController();

  //dummy friend locations
  final List<LatLng> _friendLocations = [
    const LatLng(27.6940, 85.2870),
    const LatLng(27.7000, 85.3333),
    const LatLng(27.7100, 85.3100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appbar
      appBar: AppBar(title:
      Text("Flutter geolocation",
      style: TextStyle(
        color: Colors.white,
        letterSpacing: 3,
        fontWeight: FontWeight.bold
      )),

        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 2,
          )
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Icon(Icons.gps_fixed),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(8),
            child: Container(),
            ),

      ),

      //body
      body: Padding(padding: EdgeInsets.all(20),
        child: Column(
        children: [
          _buildStatusCard(),
          SizedBox(height: 20,),

          Expanded(
              child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                  Stack(
                    children: [
                      _buildMap(),
                      // _buildActionOverlay(),
                    ],
                  ),
                ),

          ),


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
            )
          ],

        ],
      ),

      )

    );
  }

  //buildStatusCard widget
  Widget _buildStatusCard(){
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey),
      ),
      child:
      Row(
        children: [
          Icon(Icons.my_location, color: Colors.white,),
          SizedBox(width: 20,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CURRENT STATUS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2,),
              Text(_status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          )),


        ],
      ),
    );
  }


  //buildMap widget
Widget _buildMap(){
    return FlutterMap(
      mapController: _mapController,
        options: MapOptions(
      initialCenter: LatLng(27.7172, 85.3240),
      initialZoom: 13,
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
            if(_currentPosition != null)
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

    );
}

  //buildActionOverlay widget

  //function to fetch current location
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


