import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static const UserCollection = 'users';

  Future<dynamic> signInWithEmail({@required String email, @required String password}) async {
    final res = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final User user = res.user;
    return user;
  }

  Future<User> signupWithEmail({@required String username, @required String email, @required String password}) async {
    final res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final User user = res.user;
    await saveUser(user: user, username: username);
    return user;
  }

  Future<bool> hasUser() async {
    if (_auth != null) {
      if (_auth.currentUser != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<User> getUser() async {
    return _auth.currentUser;
  }

  Future<void> logOut() async {
    setIsSend(value: false);
    return _auth.signOut();
  }

  Future<dynamic> saveUser({@required User user, String username}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    final random = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> userData = UserModel(
      uid: user.uid,
      username: username ?? random,
      email: user.email,
      role: 'user',
      buildNumber: buildNumber,
      createdAt: user.metadata.creationTime.millisecondsSinceEpoch,
      updatedAt: user.metadata.lastSignInTime.millisecondsSinceEpoch,
    ).toJson();

    final userRef = _db.collection("users").doc(user.uid);
    if ((await userRef.get()).exists) {
      await userRef.update(UserModel(
        buildNumber: buildNumber,
        updatedAt: user.metadata.lastSignInTime.millisecondsSinceEpoch,
      ).toJson());
    } else {
      await _db.collection(UserCollection).doc(user.uid).set(userData);
    }

    UserModel userModel;

    await _db.collection(UserCollection).doc(user.uid).get().then((querySnapshot) {
      userModel = UserModel.fromJson(querySnapshot.data());
    });

    return userModel;
  }

  Future<bool> getIsSend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool('IsSend');
    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  Future<void> setIsSend({bool value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IsSend', value);
  }
}
