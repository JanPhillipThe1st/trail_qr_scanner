import 'package:flutter/material.dart';

class ScanConfig {
  int order = 0;
  String raceID = "";
  String scanType = "";
  String scanningPoint = "";
  ScanConfig(
      {required this.order,
      required this.raceID,
      required this.scanType,
      required this.scanningPoint}) {}
  ScanConfig.fromJson(Map<String, dynamic> map)
      : raceID = map['raceID'],
        scanType = map['scanType'],
        order = map['order'],
        scanningPoint = map['scanningPoint'];
  Map<String, dynamic> toJson() {
    return {
      "raceID": raceID,
      "scanType": scanType,
      "order": order,
      "scanningPoint": scanningPoint,
    };
  }
}
