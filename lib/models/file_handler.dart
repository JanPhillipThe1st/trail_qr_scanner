import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trail_qr_scanner/models/Barcode.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Delete the file
  Future<int> deleteFile() async {
    final file = await _localFile;

    await file.delete();
    return 1;
  }

  static Set<BarcodeData> _barcodeSet = {};
  Future<void> writeBarcodeData(BarcodeData barcode) async {
    final file = await _localFile;
    _barcodeSet = {
      ...[...await readBarcode()]
    };
    _barcodeSet.add(barcode);
    // Now convert the set to a list as the jsonEncoder cannot encode
    // a set but a list.
    final barcodeListMap = _barcodeSet.map((e) => e.toJson()).toList();

    // await fl.writeAsString(jsonEncode(_barcodeListMap));
    await file
        .writeAsString(jsonEncode(barcodeListMap), mode: FileMode.write)
        .then((value) {
      print("success: " + value.toString());
    }).catchError((err) {
      throw (err);
    });
  }

  Future<List<BarcodeData>> readBarcode() async {
    final File fl = await _localFile;
    String content = "";
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
