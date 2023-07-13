import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trail_qr_scanner/models/Barcode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trail_qr_scanner/models/scan_config.dart';

class FileHandler {
  FileHandler._privateConstructor();
  static final FileHandler instance = FileHandler._privateConstructor();

  // Get the data file
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/barcodes.txt');
  }

  Future<File> get _configFile async {
    final path = await _localPath;
    return File('$path/config.txt');
  }

  // Delete the file
  Future<int> deleteFile() async {
    final file = await _localFile;
    final configFile = await _configFile;

    await configFile.delete();
    await file.delete();
    return 1;
  }

  static Set<BarcodeData> _barcodeSet = {};
  Future<void> writeBarcodeData(BarcodeData barcode) async {
    final file = await _localFile;
    List<BarcodeData> barcodes = await readBarcode();
    barcodes.add(barcode);
    _barcodeSet = {...barcodes};
    // Now convert the set to a list as the jsonEncoder cannot encode
    // a set but a list.
    final barcodeListMap = _barcodeSet.map((e) => e.toJson()).toList();

    // await file.writeAsString(jsonEncode(barcodeListMap));
    await file
        .writeAsString(jsonEncode(barcodeListMap), mode: FileMode.write)
        .then((value) {
      print("success: " + value.toString());
    }).catchError((err) {
      throw (err);
    });
  }

  Future<void> saveScanConfig(ScanConfig config) async {
    final file = await _configFile;
    await file
        .writeAsString(jsonEncode(config.toJson()), mode: FileMode.write)
        .then((value) {
      print("success: " + value.toString());
    }).catchError((err) {
      throw (err);
    });
  }

  Future<List<BarcodeData>> readBarcode() async {
    final File fl = await _localFile;
    String content = "[]";
    try {
      content = await fl.readAsString();
    } catch (e) {
      print(e);
    }

    final List<dynamic> jsonData = jsonDecode(content);
    final List<BarcodeData> barcodes = jsonData
        .map(
          (e) => BarcodeData.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    return barcodes;
  }

  Future<ScanConfig> restoreScanConfig() async {
    final File fl = await _configFile;
    String content = "{}";
    try {
      content = await fl.readAsString();
    } catch (e) {
      print(e);
    }

    final jsonData = jsonDecode(content);
    final ScanConfig config = ScanConfig.fromJson(jsonData);
    return config;
  }

  Future<void> deleteBarcode(BarcodeData barcode) async {
    final File fl = await _localFile;

    _barcodeSet.removeWhere((e) => e.dateScanned == barcode.dateScanned);
    final barcodeListMap = _barcodeSet.map((e) => e.toJson()).toList();

    await fl.writeAsString(jsonEncode(barcodeListMap));
  }

  Future<void> updateBarcode({
    required int id,
    required BarcodeData updatedBarcode,
  }) async {
    _barcodeSet.removeWhere((e) => e.data == updatedBarcode.data);
    await writeBarcodeData(updatedBarcode);
  }
}
