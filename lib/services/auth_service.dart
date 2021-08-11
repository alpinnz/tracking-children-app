import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  static firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static const UserCollection = 'users';

  Future<firebase_auth.User> signInWithEmail({@required String email, @required String password}) async {
    final res = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final firebase_auth.User user = res.user;
    return user;
  }

  Future<bool> signupWithEmail({@required String username, @required String email, @required String password}) async {
    final res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final firebase_auth.User user = res.user;
    return (await saveUser(firebaseAuthUser: user, username: username)) != null;
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

  Future<firebase_auth.User> getUser() async {
    return _auth.currentUser;
  }

  Future<void> logOut() async {
    setIsSend(value: false);
    return _auth.signOut();
  }

  Future<dynamic> saveUser({@required firebase_auth.User firebaseAuthUser, String username}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    final random = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> userData = User(
      uid: firebaseAuthUser.uid,
      username: username ?? random,
      email: firebaseAuthUser.email,
      role: 'user',
      buildNumber: buildNumber,
      createdAt: firebaseAuthUser.metadata.creationTime.millisecondsSinceEpoch,
      updatedAt: firebaseAuthUser.metadata.lastSignInTime.millisecondsSinceEpoch,
    ).toJson();

    final userRef = _db.collection(UserCollection).doc(firebaseAuthUser.uid);
    if ((await userRef.get()).exists) {
      await userRef.update(User(
        buildNumber: buildNumber,
        updatedAt: firebaseAuthUser.metadata.lastSignInTime.millisecondsSinceEpoch,
      ).toJson());
    } else {
      await _db.collection(UserCollection).doc(firebaseAuthUser.uid).set(userData);
    }

    User user;

    await _db.collection(UserCollection).doc(firebaseAuthUser.uid).get().then((querySnapshot) {
      user = User.fromJson(querySnapshot.data());
    });

    return user;
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
