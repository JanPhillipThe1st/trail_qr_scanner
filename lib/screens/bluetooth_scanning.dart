import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trail_qr_scanner/models/Barcode.dart';
import 'package:trail_qr_scanner/models/file_handler.dart';
import 'package:trail_qr_scanner/models/scan_config.dart';
import 'package:trail_qr_scanner/screens/bluetooth_registration.dart';
import 'package:trail_qr_scanner/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:trail_qr_scanner/widgets/custom_text_field.dart';

import 'ScanDetails.dart';

class BluetoothScanning extends StatefulWidget {
  const BluetoothScanning({super.key});

  @override
  State<BluetoothScanning> createState() => _BluetoothScanningState();
}

class _BluetoothScanningState extends State<BluetoothScanning> {
  List<BarcodeData> barcodes = [];
  bool isScanning = false;
  List<String> list = ["Check-in", "Timing checkpoint", "Finish line"];
  ScanConfig? scanConfig;
  String dropdownValue = "";
  TextEditingController _RFIDCode = TextEditingController(text: "");
  TextEditingController _raceIDController = TextEditingController(text: "");
  TextEditingController _orderController = TextEditingController(text: "1");
  TextEditingController _scanningPointController =
      TextEditingController(text: "");
  String barcodeString = "";
  BarcodeData? barcodeData;
  FileHandler fl = FileHandler.instance;
  Future getBarcodesFromFiles() async {
    barcodes = await fl.readBarcode();
    await fl.restoreScanConfig().then((value) {
      _raceIDController.text = value.raceID;
      if (value.order == null) {
        _orderController.text = "0";
      } else {
        _orderController.text = value.order.toString();
      }
      _scanningPointController.text = value.scanningPoint;
    });
    setState(() {});
  }

  Stream<ScanResult>? _bluetoothDevicesSubscription;
  final FocusNode _focusNode = FocusNode();

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  Future<void> listenToBluetooth() async {
    Permission.bluetoothConnect.request();
    Permission.bluetoothScan.request();
    print(flutterBlue.isAvailable.toString());
    if (flutterBlue.isScanningNow) {
      flutterBlue.stopScan();
    } else {
      flutterBlue = FlutterBluePlus.instance;
      _bluetoothDevicesSubscription =
          flutterBlue.scan(scanMode: ScanMode.lowLatency);
      // Listen to scan results
      flutterBlue.scanResults.listen((event) async {
        event.forEach((element) async {
          await element.device.pair();
          print("Service: ${element}");
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    getBarcodesFromFiles();
    // listenToBluetooth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dropdownValue == "") {
      dropdownValue = list.first;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Scanning mode"),
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(vertical: 25)),
          Expanded(
            flex: 2,
            child: !isScanning
                ? Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 60)),
                      Text("Waiting for Scanner...",
                          style: TextStyle(
                              color: Color.fromARGB(255, 14, 14, 14),
                              fontSize: 18)),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: isScanning ? 0 : 30)),
                      Container(
                        width: 300,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: KeyboardListener(
                          autofocus: true,
                          focusNode: _focusNode,
                          child: Container(
                              width: 150,
                              height: 50,
                              margin: EdgeInsets.only(top: 50),
                              padding: EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide()),
                              ),
                              child: _bluetoothDevicesSubscription == null
                                  ? Text("No Devices Nearby")
                                  : StreamBuilder(
                                      stream: _bluetoothDevicesSubscription,
                                      builder: (context, snapshot) => Container(
                                        child: Text(snapshot.data != null
                                            ? snapshot.data!.device.name == ""
                                                ? "Unnamed device"
                                                : "No data for device"
                                            : "No data for device"),
                                      ),
                                    )),
                        ),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    ],
                  ),
          ),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      gradient: primaryGradient,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        scanConfig = ScanConfig(
                            order: int.parse(_orderController.text),
                            raceID: _raceIDController.text,
                            scanType: dropdownValue,
                            scanningPoint: _scanningPointController.text);
                        await fl.saveScanConfig(scanConfig!);
                        setState(() {
                          _focusNode.requestFocus();
                          if (!isScanning) {
                            if (_raceIDController.text == "") {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Please put a race ID before scanning")));
                            } else {
                              flutterBlue.stopScan;
                              listenToBluetooth();
                              isScanning = true;
                            }
                          } else {
                            flutterBlue.stopScan;
                            _bluetoothDevicesSubscription = null;
                            isScanning = false;
                          }
                        });
                      },
                      child: Text(
                        isScanning ? "Stop Scanning" : "Start Scanning",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                    Container(
                      child: Text(
                        "Race ID ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      width: 300,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Container(
                      child: !isScanning
                          ? CustomTextField(
                              onEditingDone: () {
                                _focusNode.requestFocus();
                              },
                              controller: _raceIDController,
                              inputType: TextInputType.text,
                              enabled: !isScanning,
                              width: 200,
                            )
                          : Text(_raceIDController.text),
                      width: 300,
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                    Container(
                      child: Text(
                        "Scanning Option ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      width: 300,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(),
                              borderRadius: BorderRadius.circular(10))),
                      child: !isScanning
                          ? DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 40,
                              ),
                              elevation: 16,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 70, 100, 121),
                                  fontStyle: FontStyle.italic),
                              underline: Container(
                                height: 2,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                FocusScope.of(context).requestFocus(_focusNode);
                                setState(() {
                                  dropdownValue = value!;
                                });
                              },
                              items: list.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child:
                                      Container(width: 300, child: Text(value)),
                                );
                              }).toList(),
                            )
                          : Text(dropdownValue),
                      width: 300,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Container(
                      height: 100,
                      width: 300,
                      child: dropdownValue == "Timing checkpoint"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4)),
                                    Container(
                                      child: !isScanning
                                          ? CustomTextField(
                                              onEditingDone: () {},
                                              controller: _orderController,
                                              inputType: TextInputType.number,
                                              width: 100,
                                            )
                                          : Text(_orderController.text),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Scanning Point ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4)),
                                    Container(
                                      child: !isScanning
                                          ? CustomTextField(
                                              onEditingDone: () {
                                                _focusNode.requestFocus();
                                              },
                                              controller:
                                                  _scanningPointController,
                                              enabled: !isScanning,
                                              inputType: TextInputType.text,
                                              width: 200,
                                            )
                                          : Text(_scanningPointController.text),
                                    )
                                  ],
                                )
                              ],
                            )
                          : Text(
                              "For timing checkpoint only",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Container(
                      child: Text(
                        "Scanned Data ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      width: 300,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Expanded(
                      flex: 2,
                      child: Container(
                          decoration: ShapeDecoration(
                              shape:
                                  RoundedRectangleBorder(side: BorderSide())),
                          height: 200,
                          child: barcodes.isNotEmpty
                              ? RefreshIndicator(
                                  onRefresh: getBarcodesFromFiles,
                                  child: ListView.builder(
                                      itemExtent: 60,
                                      padding: EdgeInsets.zero,
                                      itemCount: barcodes.length,
                                      itemBuilder: (context, index) =>
                                          Container(
                                            decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            )),
                                            child: TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return ScanDetails(
                                                      barcodes: barcodes,
                                                      callBack: () {
                                                        getBarcodesFromFiles();
                                                      });
                                                }));
                                              },
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 5),
                                                    decoration: ShapeDecoration(
                                                        color: Colors.black,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2))),
                                                    child: Text(
                                                      barcodes[index].data,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              249,
                                                              255,
                                                              255),
                                                          fontSize: 16),
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: .3)),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 5),
                                                    decoration: ShapeDecoration(
                                                        color: Colors.black,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2))),
                                                    child: Text(
                                                      "Time: ${DateFormat.yM().add_jms().format(barcodes[index].dateScanned)}",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              248,
                                                              255,
                                                              255),
                                                          fontSize: 16),
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                )
                              : RefreshIndicator(
                                  onRefresh: getBarcodesFromFiles,
                                  child: Text("Start Scanning"))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
