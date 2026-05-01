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
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30)
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
  String _status = "Ready to locate your location";
  Position? _currentPosition;
  bool _isLoading = false;
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
                      if (_isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      _buildActionOverlay(),
                    ],
                  ),
                ),

          ),



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
      initialZoom: 12,
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
          MarkerLayer(
              markers: [
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
              // if(_currentPosition != null)
              ..._friendLocations.map((location) =>
                  Marker(
                      point: location,
                      child: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ))),

          ])
        ]

    );
}

  //buildActionOverlay widget
  Widget _buildActionOverlay(){
    return Positioned(
      bottom: 20,
        left: 20,
        right: 20,
        child: ElevatedButton.icon(
            onPressed: _isLoading?null:_getLocation,
            label: _isLoading?Text("LOCATING YOU"):Text("GET MY CURRENT LOCATION",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            icon: _isLoading?SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),):Icon(Icons.location_on)));
  }

  //function to fetch current location
Future<void> _getLocation() async{
    setState(() {
      _status = "Locating you....";
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      setState(() {
        _status = "Location service is not enabled, please enable it";
      });
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied){
          setState(() {
            _status = "Location permission is denied";
          });
        }
    }

    if(permission == LocationPermission.deniedForever){
      setState(() {
        _status = "Location permission is denied forever, please enable it from settings.";
      });
    }

    try{
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _status = "Your current location found";
        _isLoading = false;
        _currentPosition = position;
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 19);
    }
    catch(e){
      setState(() {
        _status = "Error: $e";
        _isLoading = false;
      });
    }

  }
}


