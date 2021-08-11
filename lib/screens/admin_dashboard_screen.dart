import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location.dart';
import '../models/user.dart';
import '../widget/c_app_bar.dart';
import '../widget/c_button.dart';
import '../widget/c_will_pop_scope.dart';
import 'admin_history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;
  AdminDashboardScreen({Key key, @required this.user}) : super(key: key);

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
  User selectedUser;
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

  void getCurrentLocation(Location location) async {
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
      }

      await Future.delayed(Duration(seconds: 5));

      if (isGet) {
        setState(() {
          isLoading = false;
          isHistory = true;
        });
      } else {
        setState(() {
          isHistory = false;
          isGet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: CAppBar(
          title: 'Orang Tua',
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

                    List<User> users = [];

                    snapshot.data.docs.forEach((e) {
                      User user = User.fromJson(e.data());
                      if (user.role == 'user') {
                        users.add(user);
                      }
                    });
                    List<String> usernames = users.map((e) => e.username).toList();

                    return DropdownButton<String>(
                      value: usernames.contains(selectedUsername) ? selectedUsername : null,
                      icon: Icon(Icons.arrow_drop_down_sharp),
                      hint: Text('Pilih Anak', style: TextStyle(color: Colors.grey)),
                      isExpanded: true,
                      items: usernames.map((String item) {
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
                        setState(() {
                          selectedUsername = newValue;
                          selectedUser = users.singleWhere((e) => e.username == newValue);
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
                      if (selectedUser != null) {
                        List<Location> listLocation = snapshot.data.docs.map((e) => Location.fromJson(e.data())).toList();
                        listLocation.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                        List<Location> userLocation =
                            listLocation.where((e) => e.uid == (selectedUser != null ? selectedUser.uid : 'not found')).toList();
                        if (isGet) {
                          print('get location ');
                          Future.delayed(Duration(seconds: 3), () {
                            getCurrentLocation(userLocation.last);
                          });
                          if (userLocation.length > 1) {
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
                              child: Center(child: Text('Lokasi Anak ${selectedUser.username} tidak ada')),
                            );
                          }
                        } else {
                          return Expanded(
                            child: Center(child: Text('Tekan Posisi Anak')),
                          );
                        }
                      }
                    }
                    return Expanded(child: Center(child: Text('Pilih Anak')));
                  }),
              SizedBox(height: 20),
              CButton(
                disabled: !isHistory || selectedUser == null,
                label: 'History Lokasi Anak',
                onPressed: () async {
                  if (isHistory && selectedUser != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHistoryScreen(user: selectedUser)));
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
