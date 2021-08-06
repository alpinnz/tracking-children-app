import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking/bloc/app/app_bloc.dart';

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
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: Color(0xFF4f4f4f),
    minimumSize: Size(double.infinity, 45),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
  DateTime currentBackPressTime;

  bool isLoading;
  bool isGet;

  Marker marker;
  Circle circle;
  GoogleMapController controller;
  CameraPosition initialLocation;

  String selectedUsername;
  UserModel selectedUserModel;
  final Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance.collection('users').snapshots();

  final Stream<QuerySnapshot> locationsStream = FirebaseFirestore.instance.collection('locations').snapshots();

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to leave')),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
    isGet = false;
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
        print(locationModel.toJson().toString());
      }

      await Future.delayed(Duration(seconds: 5));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('${widget.userModel.username}'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              BlocProvider.of<AppBloc>(context)..add(AppLogoutEvent());
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
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
                      value: listUsername.contains(selectedUsername) ? selectedUsername : listUsername[0],
                      icon: Icon(Icons.arrow_drop_down_sharp),
                      isExpanded: true,
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        print(newValue);
                        setState(() {
                          selectedUsername = newValue;
                          selectedUserModel = userModels.singleWhere((e) => e.username == newValue);
                        });
                      },
                      items: listUsername.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  }),
              SizedBox(height: 16),
              ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () {
                  setState(() {
                    isGet = !isGet;
                  });
                },
                child: Text(
                  'Posisi Anak',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    'Lokasi Anak Pada Peta',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Divider(
                      thickness: 3,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                  stream: locationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<LocationModel> listLocationModel = snapshot.data.docs.map((e) => LocationModel.fromJson(e.data())).toList();
                      listLocationModel.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      List<LocationModel> userLocationModel =
                          listLocationModel.where((e) => e.uid == (selectedUserModel != null ? selectedUserModel.uid : 'not found')).toList();
                      // userLocationModel.forEach((e) {
                      //   print(DateTime.fromMillisecondsSinceEpoch(e.createdAt));
                      // });
                      if (userLocationModel.length > 1) {
                        getCurrentLocation(userLocationModel.last);
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
                          onMapCreated: (GoogleMapController controller) {
                            controller = controller;
                          },
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHistoryScreen(userModel: selectedUserModel)));
                },
                child: Text(
                  'History Lokasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
