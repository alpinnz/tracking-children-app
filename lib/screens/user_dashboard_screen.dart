import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking/services/auth_service.dart';
import 'package:tracking/widget/c_app_bar.dart';
import 'package:tracking/widget/c_button.dart';
import 'package:tracking/widget/c_will_pop_scope.dart';

import '../models/location_model.dart';
import '../models/user_model.dart';
import '../services/geolocator_service.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserModel userModel;
  UserDashboardScreen({Key key, @required this.userModel}) : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  bool isMount;
  bool isLoading;
  bool isAktif;
  bool isSend;
  AuthService authService = AuthService();
  Stream<LocationModel> getLocationStream;

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

  void updateMarkerAndCircle(LocationModel locationModel, Uint8List imageData) {
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: LatLng(locationModel.latitude, locationModel.longitude),
          rotation: locationModel.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("person"),
          radius: locationModel.accuracy,
          zIndex: 1,
          strokeColor: Colors.redAccent,
          center: LatLng(locationModel.latitude, locationModel.longitude),
          fillColor: Colors.redAccent.withAlpha(70));
    });
  }

  void updateGMAP(LocationModel locationModel) async {
    Uint8List imageData = await getMarker();

    if (controller != null) {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(bearing: 192.8334901395799, target: LatLng(locationModel.latitude, locationModel.longitude), tilt: 0, zoom: 18),
          ),
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(locationModel.latitude, locationModel.longitude);
        print('placemarks' + placemarks.first.toJson().toString());

        updateMarkerAndCircle(locationModel, imageData);
        print('updateGMAP -> ${locationModel.address.streetAddress}');
      }

      await Future.delayed(Duration(seconds: 5));

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getLocationStream = GeolocatorService(uid: widget.userModel.uid).locationStream;

    return CWillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, kToolbarHeight),
          child: CAppBar(
            title: widget.userModel.username,
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
                    getLocationStream.asBroadcastStream();
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
              StreamBuilder<LocationModel>(
                  stream: getLocationStream,
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
