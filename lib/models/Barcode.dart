import 'package:flutter/material.dart';

class BarcodeData {
  String data = "";
  DateTime dateScanned = DateTime.now();
  String raceID = "";
  String scanType = "";
  int order = 0;
  String scanningPoint = "";

  BarcodeData(
      {required this.data,
      required this.dateScanned,
      required this.order,
      required this.raceID,
      required this.scanType,
      required this.scanningPoint}) {}
  BarcodeData.fromScan(String data, DateTime scanDate) {
    data = data;
    dateScanned = scanDate;
  }
  BarcodeData.fromJson(Map<String, dynamic> map)
      : data = map['data'],
        dateScanned = DateTime.parse(map['dateScanned']),
        raceID = map['raceID'],
        scanType = map['scanType'],
        order = map['order'],
        scanningPoint = map['scanningPoint'];

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'dateScanned': dateScanned.toIso8601String(),
      'raceID': raceID,
      'order': order,
      'scanType': scanType,
      'scanningPoint': scanningPoint,
    };
  }
}
