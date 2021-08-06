import 'package:flutter/material.dart';

enum Flavor { USER, ADMIN }

class FlavorValues {
  FlavorValues({@required this.baseUrl});

  final String baseUrl;
  //Add other flavor specific values, e.g database name
}

class FlavorConfig {
  factory FlavorConfig({
    @required Flavor flavor,
    @required FlavorValues values,
  }) {
    _instance ??= FlavorConfig._internal(flavor, 'Tracking Children ${flavor == Flavor.ADMIN ? ' Admin' : ''}', values);
    return _instance;
  }

  FlavorConfig._internal(this.flavor, this.name, this.values);
  final Flavor flavor;
  final String name;
  final FlavorValues values;

  static FlavorConfig _instance;

  static FlavorConfig get instance {
    return _instance;
  }

  static bool isUser() => _instance.flavor == Flavor.USER;

  static bool isAdmin() => _instance.flavor == Flavor.ADMIN;
}
