import 'package:flutter/material.dart';

class CWillPopScope extends StatefulWidget {
  final Widget child;
  CWillPopScope({Key key, @required this.child}) : super(key: key);

  @override
  _CWillPopScopeState createState() => _CWillPopScopeState();
}

class _CWillPopScopeState extends State<CWillPopScope> {
  DateTime currentBackPressTime;

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
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: onWillPop, child: widget.child);
  }
}
