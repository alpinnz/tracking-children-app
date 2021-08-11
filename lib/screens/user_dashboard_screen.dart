import 'dart:async';
import 'dart:typed_data';

import 'package:children/services/auth_service.dart';
import 'package:children/widget/c_app_bar.dart';
import 'package:children/widget/c_button.dart';
import 'package:children/widget/c_will_pop_scope.dart';
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location.dart';
import '../models/user.dart';
import '../services/location_service.dart';

class UserDashboardScreen extends StatefulWidget {
  final User user;
  UserDashboardScreen({Key key, @required this.user}) : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  bool isMount;
  bool isLoading;
  bool isAktif;
  bool isSend;
  AuthService authService = AuthService();

  GoogleMapController controller;

  Marker marker;
  Circle circle;
  CameraPosition initialLocation;

  @override
  void initState() {
    isLoading = false;
    isSend = false;
    isAktif = false;

    initialLocation = CameraPosition(target: LatLng(-6.170166, 106.831375), zoom: 18);

    initCheck();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initCheck() async {
    bool _isSend = await authService.getIsSend();
    if (_isSend) {
      setState(() {
        isSend = true;
        isAktif = true;
      });
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/icons/ic_person.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Location location, Uint8List imageData) {
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: LatLng(location.latitude, location.longitude),
          rotation: location.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("person"),
          radius: location.accuracy,
          zIndex: 1,
          strokeColor: Colors.redAccent,
          center: LatLng(location.latitude, location.longitude),
          fillColor: Colors.redAccent.withAlpha(70));
    });
  }

  void updateGMAP(Location location) async {
    Uint8List imageData = await getMarker();

    if (controller != null) {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(bearing: 192.8334901395799, target: LatLng(location.latitude, location.longitude), tilt: 0, zoom: 18),
          ),
        );

        updateMarkerAndCircle(location, imageData);
        print('updateGMAP -> ${location.address.street}');
      }

      await Future.delayed(Duration(seconds: 5));

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<Location> locationStream = LocatorService(uid: widget.user.uid).locationStream;

    return CWillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, kToolbarHeight),
          child: CAppBar(
            title: widget.user.username,
            actions: [CAppBarActions.Logout],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CButton(
                disabled: !isAktif,
                label: 'Aktifkan GPS',
                onPressed: () async {
                  setState(() {
                    isAktif = true;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    'Lokasi Anak Saat ini',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Divider(
                      thickness: 3,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              StreamBuilder<Location>(
                  stream: locationStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (isAktif) {
                        updateGMAP(snapshot.data);
                      }
                    }
                    return Expanded(
                      child: Container(
                        width: double.infinity,
                        child: GoogleMap(
                          mapType: MapType.hybrid,
                          initialCameraPosition: initialLocation,
                          markers: Set.of((marker != null) ? [marker] : []),
                          circles: Set.of((circle != null) ? [circle] : []),
                          compassEnabled: false,
                          onMapCreated: (GoogleMapController _controller) {
                            controller = _controller;
                          },
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
              SizedBox(height: 20),
              CButton(
                disabled: !isSend,
                label: 'Kirim ke Orang Tua',
                onPressed: () async {
                  if (isAktif) {
                    authService.setIsSend(value: true);
                    setState(() {
                      isSend = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('aktifkan GPS dahulu')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
