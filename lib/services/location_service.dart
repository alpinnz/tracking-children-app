import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/location_model.dart';

class LocationService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static const LocationCollection = 'locations';

  static saveLocation({@required LocationModel locationModel}) async {
    _db.collection(LocationCollection).add(locationModel.toJson());
  }
}
