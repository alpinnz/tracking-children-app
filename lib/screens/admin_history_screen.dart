import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location_model.dart';
import '../models/user_model.dart';

class AdminHistoryScreen extends StatefulWidget {
  final UserModel userModel;
  AdminHistoryScreen({Key key, @required this.userModel}) : super(key: key);

  @override
  _AdminHistoryScreenState createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final Stream<QuerySnapshot> locationsStream = FirebaseFirestore.instance.collection('locations').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: locationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<LocationModel> listLocationModel = snapshot.data.docs.map((e) => LocationModel.fromJson(e.data())).toList();
            listLocationModel.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            List<LocationModel> userLocationModel = listLocationModel.where((e) => e.uid == widget.userModel.uid).toList();
            // userLocationModel.forEach((e) {
            //   print(DateTime.fromMillisecondsSinceEpoch(e.createdAt));
            // });
            return ListView.builder(
              itemCount: userLocationModel.length,
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(DateFormat('kk:mm:ss\ndd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(userLocationModel[i].createdAt))),
                  title: Text('${userLocationModel[i].address.addressLine}'),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
