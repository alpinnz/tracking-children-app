import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking/services/auth_service.dart';
import 'package:tracking/widget/c_app_bar.dart';
import 'package:tracking/widget/c_button.dart';
import 'package:tracking/widget/c_will_pop_scope.dart';
import 'package:tracking/main_user.dart';

import '../models/location_model.dart';
import '../models/user_model.dart';
import '../services/get_location_service.dart';
import '../services/location_service.dart';

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

  GoogleMapController controller;
  CameraPosition initialLocation;

  @override
  void initState() {
    isLoading = false;
    isSend = false;
    isAktif = false;
    initialLocation = CameraPosition(target: LatLng(-6.170166, 106.831375), zoom: 18);

    // initCheck();

    super.initState();
  }

  Future initCheck() async {
    bool _isSend = await authService.getIsSend();
    if (_isSend) {
      setState(() {
        isSend = true;
        isAktif = true;
      });
      FlutterBackgroundService().sendData(
        {"action": "startService", "UserModel": widget.userModel.toJson()},
      );
    } else {
      FlutterBackgroundService().sendData(
        {"action": "stopService"},
      );
    }
  }

  void updateGMAP(LocationModel locationModel) async {
    if (controller != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(bearing: 192.8334901395799, target: LatLng(locationModel.latitude, locationModel.longitude), tilt: 0, zoom: 18),
        ),
      );

      if (isSend) {
        locationModel.createdAt = DateTime.now().millisecondsSinceEpoch;
        locationModel.updatedAt = DateTime.now().millisecondsSinceEpoch;
        LocationService.saveLocation(locationModel: locationModel);

        print('sendLocationModel -> ${locationModel.createdAt}');
      }

      print('updateGMAP -> ${locationModel.address.streetAddress}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<LocationModel> getLocationStream = GetLocationService(uid: widget.userModel.uid).locationStream;

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
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.125,
                              padding: EdgeInsets.all(16),
                              child: Text(
                                snapshot.hasData && isAktif ? snapshot.data.address.streetAddress : 'not address',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: GoogleMap(
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: initialLocation,
                                  onMapCreated: (GoogleMapController _controller) {
                                    controller = _controller;
                                  },
                                  compassEnabled: false,
                                  scrollGesturesEnabled: false,
                                  trafficEnabled: false,
                                  myLocationEnabled: false,
                                  zoomGesturesEnabled: false,
                                  mapToolbarEnabled: false,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  rotateGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  indoorViewEnabled: false,
                                  liteModeEnabled: false,
                                ),
                              ),
                            ),
                          ],
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
                    var isRunning = await FlutterBackgroundService().isServiceRunning();
                    if (isRunning) {
                      FlutterBackgroundService().sendData(
                        {"action": "stopService"},
                      );
                    } else {
                      FlutterBackgroundService.initialize(onStart, autoStart: true, foreground: false);
                      FlutterBackgroundService().sendData(
                        {"action": "startService", "UserModel": widget.userModel.toJson()},
                      );
                    }
                    if (!isRunning) {
                      authService.setIsSend(value: true);
                      setState(() {
                        isSend = true;
                      });
                    } else {
                      authService.setIsSend(value: false);
                      setState(() {
                        isSend = false;
                      });
                    }
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
