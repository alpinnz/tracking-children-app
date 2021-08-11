import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/address.dart';
import '../models/location.dart';
import '../models/user.dart';
import '../widget/c_app_bar.dart';

class AdminHistoryScreen extends StatefulWidget {
  final User user;
  AdminHistoryScreen({Key key, @required this.user}) : super(key: key);

  @override
  _AdminHistoryScreenState createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final Stream<QuerySnapshot> locationsStream = FirebaseFirestore.instance.collection('locations').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: CAppBar(
          title: 'History Lokasi ${widget.user.username}',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: locationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Location> locations = snapshot.data.docs.map((e) => Location.fromJson(e.data())).toList();

            List<Location> listLocationByUser = locations.where((e) => (e.uid == widget.user.uid) && (e.address != null)).toList();

            listLocationByUser.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              itemCount: listLocationByUser.length,
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                Location location = listLocationByUser[i];
                Address address = location.address;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 55,
                      leading: SizedBox(
                        width: 55,
                        child: Center(
                          child: Text(
                            DateFormat('kk:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(location.createdAt)).toString(),
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      title: Text(
                        '${address.street.replaceAll('Jalan', 'Jl')}, ${address.subLocality}, ${address.locality.replaceAll('Kecamatan', 'Kec')}, ${address.subAdministrativeArea}, ${address.administrativeArea}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
