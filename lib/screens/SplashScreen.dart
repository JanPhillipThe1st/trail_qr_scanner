import 'package:flutter/material.dart';
import 'package:trail_qr_scanner/models/file_handler.dart';
import 'package:trail_qr_scanner/screens/RFIDScan.dart';
import 'package:trail_qr_scanner/screens/ScanQR.dart';
import 'package:trail_qr_scanner/screens/bluetooth.dart';
import 'package:trail_qr_scanner/screens/bluetooth_scanning.dart';

import '../models/Barcode.dart';
import 'ScanDetails.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<BarcodeData> barcodes = [];
  FileHandler fl = FileHandler.instance;

  Future getBarcodesFromFiles() async {
    barcodes = await fl.readBarcode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 80)),
          Text("RACETECH",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontFamily: 'RaceSport')),
          Padding(padding: EdgeInsets.symmetric(vertical: 20)),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => ScanQR())));
              },
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(),
                          borderRadius: BorderRadius.circular(40))),
                  child:
                      Text("QR SCAN", style: TextStyle(color: Colors.black)))),
          Padding(padding: EdgeInsets.symmetric(vertical: 2)),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => RFIDScan())));
              },
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(),
                          borderRadius: BorderRadius.circular(40))),
                  child: Text("RFID SCAN",
                      style: TextStyle(color: Colors.black)))),
          Padding(padding: EdgeInsets.symmetric(vertical: 2)),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        // builder: ((context) => BluetoothScanning())));
                        builder: ((context) => BluetoothScanning())));
              },
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(),
                          borderRadius: BorderRadius.circular(40))),
                  child: Text("BLUETOOTH SCAN",
                      style: TextStyle(color: Colors.black)))),
          Padding(padding: EdgeInsets.symmetric(vertical: 2)),
          Padding(padding: EdgeInsets.symmetric(vertical: 2)),
          TextButton(
              onPressed: () async {
                await getBarcodesFromFiles();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ScanDetails(
                      barcodes: barcodes,
                      callBack: () {
                        setState(() {});
                      });
                }));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(),
                        borderRadius: BorderRadius.circular(40))),
                child:
                    Text("VIEW RESULTS", style: TextStyle(color: Colors.black)),
              )),
        ],
      ),
    ));
  }
}
