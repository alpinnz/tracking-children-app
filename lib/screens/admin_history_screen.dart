import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/location_model.dart';
import '../models/user_model.dart';
import '../widget/c_app_bar.dart';

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
    void modalDetail(LocationModel locationModel) {
      showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8.0),
                  topRight: const Radius.circular(8.0),
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Data Lengkap",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('kk:mm:ss dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(locationModel.createdAt)),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: locationModel.address
                        .toJson()
                        .entries
                        .toList()
                        .map(
                          (e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '',
                                // e.key.toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                e.value.toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: CAppBar(
          title: 'History lokasi ${widget.userModel.username}',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: locationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<LocationModel> listLocationModel = snapshot.data.docs.map((e) => LocationModel.fromJson(e.data())).toList();

            print('address' + listLocationModel.last.address.toJson().toString());

            List<LocationModel> listLocationModelByUser =
                listLocationModel.where((e) => (e.uid == widget.userModel.uid) && (e.address != null)).toList();
            listLocationModelByUser.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              itemCount: listLocationModelByUser.length,
              padding: EdgeInsets.all(20),
              itemBuilder: (context, i) {
                LocationModel locationModel = listLocationModelByUser[i];
                Address address = locationModel.address;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 55,
                      leading: SizedBox(
                        width: 55,
                        child: Center(
                          child: Text(
                            DateFormat('kk:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(locationModel.createdAt)).toString(),
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      title: Text(
                        '${address.streetAddress.replaceAll('Jalan', 'Jl')}, Rt/Rw, ${address.city}, ${address.region} ,${address.countryName}',
                        style: TextStyle(fontSize: 14),
                      ),
                      // subtitle: Text('${address.city}, ${address.region} ,${address.countryName}'),
                      // onTap: () {
                      //   modalDetail(locationModel);
                      // },
                    ),
                    Divider(),
                  ],
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
