import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widget/c_app_bar.dart';
import '../widget/c_button.dart';
import '../widget/c_will_pop_scope.dart';

import '../models/location_model.dart';
import '../models/user_model.dart';
import 'admin_history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel userModel;
  AdminDashboardScreen({Key key, @required this.userModel}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading;
  bool isGet;
  bool isHistory;

  Marker marker;
  Circle circle;
  GoogleMapController controller;
  CameraPosition initialLocation;

  String selectedUsername;
  UserModel selectedUserModel;
  final Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance.collection('users').snapshots();

  final Stream<QuerySnapshot> locationsStream = FirebaseFirestore.instance.collection('locations').snapshots();

  @override
  void initState() {
    super.initState();

    isLoading = false;
    isGet = false;
    isHistory = false;
    initialLocation = CameraPosition(target: LatLng(-6.170166, 106.831375), zoom: 18);
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

  void getCurrentLocation(LocationModel locationModel) async {
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

        updateMarkerAndCircle(locationModel, imageData);
        // print(locationModel.toJson().toString());
      }

      await Future.delayed(Duration(seconds: 5));

      setState(() {
        isLoading = false;
        isHistory = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: CAppBar(
          title: widget.userModel.username,
          actions: [CAppBarActions.Logout],
        ),
      ),
      body: CWillPopScope(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: usersStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading...");
                    }

                    List<UserModel> userModels = [];

                    snapshot.data.docs.forEach((e) {
                      UserModel user = UserModel.fromJson(e.data());
                      if (user.role == 'user') {
                        userModels.add(user);
                      }
                    });
                    List<String> listUsername = userModels.map((e) => e.username).toList();

                    userModels.add(UserModel(username: 'Username'));
                    return DropdownButton<String>(
                      value: listUsername.contains(selectedUsername) ? selectedUsername : null,
                      icon: Icon(Icons.arrow_drop_down_sharp),
                      hint: Text('pilih anak', style: TextStyle(color: Colors.grey)),
                      isExpanded: true,
                      items: listUsername.map((String item) {
                        return DropdownMenuItem<String>(
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.redAccent, size: 20),
                              SizedBox(width: 8),
                              Text(item, style: TextStyle(color: item == selectedUsername ? Colors.black87 : Colors.grey)),
                            ],
                          ),
                          value: item,
                        );
                      }).toList(),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
                      underline: Container(
                        height: 1,
                        color: Colors.redAccent,
                      ),
                      onChanged: (String newValue) {
                        print(newValue);
                        setState(() {
                          selectedUsername = newValue;
                          selectedUserModel = userModels.singleWhere((e) => e.username == newValue);
                          isGet = false;
                          isHistory = false;
                        });
                      },
                    );
                  }),
              SizedBox(height: 16),
              CButton(
                disabled: !isGet,
                label: 'Posisi Anak',
                onPressed: () async {
                  locationsStream.asBroadcastStream();
                  setState(() {
                    isGet = true;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    'Lokasi Anak Pada Peta',
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
              StreamBuilder<QuerySnapshot>(
                  stream: locationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (selectedUserModel != null) {
                        List<LocationModel> listLocationModel = snapshot.data.docs.map((e) => LocationModel.fromJson(e.data())).toList();
                        listLocationModel.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                        List<LocationModel> userLocationModel =
                            listLocationModel.where((e) => e.uid == (selectedUserModel != null ? selectedUserModel.uid : 'not found')).toList();
                        if (isGet) {
                          print('get location ');
                          Future.delayed(Duration(seconds: 3), () {
                            getCurrentLocation(userLocationModel.last);
                          });
                          if (userLocationModel.length > 1) {
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
                          } else {
                            return Expanded(
                              child: Center(child: Text('data lokasi anak ${selectedUserModel.username} tidak ada')),
                            );
                          }
                        } else {
                          return Expanded(
                            child: Center(child: Text('tekan tombol Posisi Anak')),
                          );
                        }
                      }
                    }
                    return Expanded(child: Center(child: Text('Pilih anak')));
                  }),
              SizedBox(height: 20),
              CButton(
                disabled: !isHistory || selectedUserModel == null,
                label: 'History Lokasi',
                onPressed: () async {
                  if (isHistory && selectedUserModel != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHistoryScreen(userModel: selectedUserModel)));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
