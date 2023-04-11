import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trail_qr_scanner/main.dart';
import 'package:trail_qr_scanner/models/Barcode.dart';
import 'package:intl/intl.dart';
import 'package:trail_qr_scanner/models/racetec_ph_api.dart';
import 'package:http/http.dart' as http;
import 'package:trail_qr_scanner/screens/SplashScreen.dart';
import 'package:trail_qr_scanner/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_handler.dart';

class ScanDetails extends StatefulWidget {
  const ScanDetails(
      {super.key, required this.barcodes, required this.callBack});
  final List<BarcodeData> barcodes;
  final Function callBack;

  @override
  State<ScanDetails> createState() => _ScanDetailsState();
}

List<BarcodeData> barcodeList = [];

FileHandler fl = FileHandler.instance;

class _ScanDetailsState extends State<ScanDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    barcodeList = widget.barcodes;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {},
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you sure you want to delete this record?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  TextEditingController _saveFileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Race Results ",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Container(
        height: 850,
        color: Color.fromARGB(255, 40, 41, 43),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Container(
              width: 400,
              padding: EdgeInsets.all(4),
              height: 400,
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: BorderSide(color: Colors.grey))),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        width: 600,
                        child: Row(
                          children: [
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: ShapeDecoration(
                                  gradient: primaryGradient,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide())),
                              child: Text(
                                "QR Code",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 249, 255, 255),
                                    fontSize: 16),
                                softWrap: false,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 55),
                              width: 250,
                              decoration: ShapeDecoration(
                                  gradient: primaryGradient,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide())),
                              child: Text(
                                "Scan Time",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 248, 255, 255),
                                    fontSize: 16),
                                softWrap: false,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1)),
                            Container(
                              width: 130,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: ShapeDecoration(
                                  gradient: primaryGradient,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide())),
                              child: Text(
                                "Delete item",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 248, 255, 255),
                                    fontSize: 16),
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 340,
                        width: 600,
                        margin: EdgeInsets.zero,
                        child: ListView.builder(
                          itemCount: widget.barcodes.length,
                          itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: Row(
                              children: [
                                Container(
                                  width: 200,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: ShapeDecoration(
                                      color: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: BorderSide())),
                                  child: Text(
                                    barcodeList[index].data,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 249, 255, 255),
                                        fontSize: 16),
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1)),
                                Container(
                                  width: 250,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 30),
                                  decoration: ShapeDecoration(
                                      color: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: BorderSide())),
                                  child: Text(
                                    DateFormat.yM()
                                        .add_jms()
                                        .format(barcodeList[index].dateScanned),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 248, 255, 255),
                                        fontSize: 16),
                                    softWrap: false,
                                  ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1)),
                                Container(
                                    width: 130,
                                    height: 45,
                                    decoration: ShapeDecoration(
                                        color: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: BorderSide())),
                                    child: IconButton(
                                      onPressed: () async {
                                        Widget cancelButton = TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        );
                                        Widget continueButton = TextButton(
                                          child: Text("Delete"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await fl.deleteBarcode(
                                                barcodeList[index]);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "${barcodeList[index].data} is removed")));
                                            barcodeList.removeAt(index);
                                            setState(() {
                                              widget.callBack();
                                            });
                                          },
                                        );
                                        // set up the AlertDialog
                                        AlertDialog alert = AlertDialog(
                                          title: Text("Delete " +
                                              barcodeList[index].data),
                                          content: Text(
                                              "Are you sure you want to delete this record?"),
                                          actions: [
                                            cancelButton,
                                            continueButton,
                                          ],
                                        );
                                        // show the dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            Column(
              children: [
                Container(
                  decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 51, 72, 104),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  width: 400,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () {
                      Widget cancelButton = TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      );
                      Widget continueButton = TextButton(
                        child: Text("Upload"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          http.Response response =
                              await RaceTecPH().uploadRaceRecord(barcodeList);
                          AlertDialog responseDialog = AlertDialog(
                            title: Column(
                              children: [
                                Text(
                                  response.statusCode != 200
                                      ? "Error. Status Code: " +
                                          response.statusCode.toString()
                                      : "Data uploaded successfully!",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          );
                          showDialog(
                              context: context,
                              builder: ((context) => responseDialog));
                        },
                      );
                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("Upload Race Record"),
                        content: Text(
                            "Are you sure you want to upload this record?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );
                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Text(
                      "Upload Data",
                      style:
                          TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                Container(
                  decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 51, 72, 104),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  width: 400,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () {
                      _saveFileController.text = barcodeList[0].raceID +
                          DateFormat('MMMM-dd-yyyy-hh-mm')
                              .format(DateTime.now());
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Save File'),
                              content: TextField(
                                controller: _saveFileController,
                                decoration:
                                    InputDecoration(hintText: "File name"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Save'),
                                  onPressed: () async {
                                    savetoCSV(context, _saveFileController);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Data Saved Successfully!"),
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text(
                      "Save File",
                      style:
                          TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                Container(
                  decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 51, 72, 104),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  width: 400,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () {
                      Widget cancelButton = TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      );
                      Widget continueButton = TextButton(
                        child: Text("Yes, the race has finished."),
                        onPressed: () async {
                          _saveFileController.text = barcodeList[0].raceID +
                              DateFormat('MMMM-dd-yyyy-hh-mm')
                                  .format(DateTime.now());
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Save File'),
                                  content: TextField(
                                    controller: _saveFileController,
                                    decoration:
                                        InputDecoration(hintText: "File name"),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Save'),
                                      onPressed: () async {
                                        savetoCSV(context, _saveFileController);
                                        await fl.deleteFile();
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                                "Data Saved Successfully!"),
                                          ),
                                        );
                                        exit(1);
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      );
                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("Finish Scanning"),
                        content:
                            Text("Are you sure you want to finish scanning?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );
                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Text(
                      "Finish Scanning",
                      style:
                          TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

Future<void> savetoCSV(
    BuildContext context, TextEditingController saveFileController) async {
  List<List<String>> barcodesAsCSVList = [
    [
      "device_id",
      "race_id",
      "scan_type",
      "scan_order",
      "scan_point",
      "chip_id",
      "scan_time"
    ]
  ];

  barcodeList.forEach((element) {
    barcodesAsCSVList.add([
      "Device_ID",
      element.raceID,
      element.scanType,
      element.order.toString(),
      element.scanningPoint,
      element.data,
      (element.dateScanned.millisecondsSinceEpoch / 10000).round().toString()
    ]);
  });
  Navigator.of(context).pop();
  String csvData = ListToCsvConverter().convert(barcodesAsCSVList);
  final String directory = (await getExternalStorageDirectory())!.path;
  final path = "$directory/${saveFileController.text}.csv";
  print(path);
  final File file = File(path);
  await file.writeAsString(csvData);
}
