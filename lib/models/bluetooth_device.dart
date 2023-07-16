import 'package:flutter/material.dart';

class BluetoothDeviceModel {
  String deviceName = "";
  String deviceAddress = "";
  //A bluetooth device is very complex
  //It requires a list of characteristics
  List<String> characteristics = [];
  //It also requires a list of services for every characteristic.
  List<String> services = [];
}
