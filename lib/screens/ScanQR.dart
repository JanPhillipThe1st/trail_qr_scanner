import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:intl/intl.dart';
import 'package:trail_qr_scanner/models/Barcode.dart';
import 'package:trail_qr_scanner/models/file_handler.dart';
import 'package:trail_qr_scanner/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:trail_qr_scanner/widgets/custom_dropdown.dart';
import 'package:trail_qr_scanner/widgets/custom_text_field.dart';

import '../models/scan_config.dart';
import 'ScanDetails.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  List<BarcodeData> barcodes = [];
  bool isScanning = false;
  QRViewController? controller;
  List<String> list = ["Check-in", "Timing checkpoint", "Finish line"];
  String dropdownValue = "";
  ScanConfig? scanConfig;
  TextEditingController _raceIDController = TextEditingController(text: "");
  TextEditingController _orderController = TextEditingController(text: "1");
  TextEditingController _scanningPointController =
      TextEditingController(text: "");
  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  BarcodeData? barcodeData;
  FileHandler fl = FileHandler.instance;
  Future getBarcodesFromFiles() async {
    barcodes = await fl.readBarcode();
    await fl.restoreScanConfig().then((value) {
      _raceIDController.text = value.raceID;
      _orderController.text = value.order.toString();
      _scanningPointController.text = value.scanningPoint;
    });
    setState(() {});
  }

  void closedScreen() {
    getBarcodesFromFiles();
  }

  StreamSubscription? _homeButtonSubscription;
  StreamSubscription? _powerButtonSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBarcodesFromFiles();
  }

  @override
  Widget build(BuildContext context) {
    if (dropdownValue == "") {
      dropdownValue = list.first;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanning mode"),
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(vertical: 25)),
          Expanded(
            flex: 2,
            child: QRView(
              overlay: QrScannerOverlayShape(
                  borderRadius: 10,
                  overlayColor: Color.fromARGB(131, 135, 156, 156),
                  borderLength: 40,
                  borderColor: Color.fromARGB(255, 0, 132, 184)),
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
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
                          if (!isScanning) {
                            isScanning = true;
                            controller!.resumeCamera();
                          } else {
                            isScanning = false;
                            controller!.pauseCamera();
                          }
                        });
                      },
                      child: Text(
                        isScanning ? "Stop" : "Scan",
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
                              onEditingDone: () {},
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
                                              onEditingDone: () {},
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
              ))
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData != null) {}
      result = scanData;
      if (_raceIDController.text == "" ||
          _orderController.text == "" ||
          _scanningPointController.text == "") {
        if (dropdownValue == list[1]) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Please fill in all the fields before scanning.")));
          controller.pauseCamera();
          return;
        } else {
          barcodeData = BarcodeData(
              data: scanData.code.toString(),
              scanType: dropdownValue,
              dateScanned: DateTime.now(),
              raceID: _raceIDController.text,
              order: int.parse(_orderController.text),
              scanningPoint: _scanningPointController.text);

          barcodes = [
            ...{...barcodes}
          ];
          controller.pauseCamera();
          await fl.writeBarcodeData(barcodeData!);
          barcodes = await fl.readBarcode();
          isScanning = false;
        }
      } else {
        barcodeData = BarcodeData(
            data: scanData.code.toString(),
            scanType: dropdownValue,
            dateScanned: DateTime.now(),
            raceID: _raceIDController.text,
            order: int.parse(_orderController.text),
            scanningPoint: _scanningPointController.text);

        barcodes = [
          ...{...barcodes}
        ];
        controller.pauseCamera();
        await fl.writeBarcodeData(barcodeData!);
        barcodes = await fl.readBarcode();
        isScanning = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    scanConfig = ScanConfig(
        order: int.parse(_orderController.text),
        raceID: _raceIDController.text,
        scanType: dropdownValue,
        scanningPoint: _scanningPointController.text);
    fl.saveScanConfig(scanConfig!);
    barcodes = [];
    super.dispose();
  }
}
