import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'package:bookShare/main.dart';
import 'package:bookShare/app_state_container.dart';

void main() {
  enableFlutterDriverExtension();
  runApp( AppStateContainer( child: new BSApp() ));
}
