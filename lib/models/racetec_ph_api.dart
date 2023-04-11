import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Barcode.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:android_multiple_identifier/android_multiple_identifier.dart';

class RaceTecPH {
  Future<String> getDeviceSerialNumber() async {
    String? identifier = await UniqueIdentifier.serial;

    if (identifier == null) {
      return "No IMEI Available";
    } else {
      return identifier;
    }
  }

  Future<http.Response> uploadRaceRecord(List<BarcodeData> barcodes) async {
    String deviceId = await getDeviceSerialNumber();
    print('{"insert_data:"' +
        jsonDecode(await barcodesToJSON(barcodes, deviceId)).toString() +
        "}");
    return http.post(Uri.parse('https://racetechph.com/mobile/scan/insert'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"insert_data":' +
            jsonDecode(await barcodesToJSON(barcodes, deviceId)).toString() +
            "}");
  }

  Future<String> barcodesToJSON(
      List<BarcodeData> barcodes, String deviceId) async {
    List<String> JSONBarcodes = [];
    for (BarcodeData barcodeData in barcodes) {
      JSONBarcodes.add(jsonEncode(<String, String>{
        "device_id": deviceId,
        "race_id": barcodeData.raceID,
        "scan_type": barcodeData.scanType ?? "Not specified",
        "scan_order": barcodeData.order.toString(),
        "scan_point": barcodeData.scanningPoint,
        "chip_id": barcodeData.data,
        "scan_time": (barcodeData.dateScanned.millisecondsSinceEpoch / 1000)
            .round()
            .toString()
      }));
    }
    return jsonEncode(JSONBarcodes);
  }
}
