import 'package:flutter/material.dart';
import 'package:trail_qr_scanner/widgets/bluetoothDeviceWidget.dart';
import 'package:trail_qr_scanner/widgets/defaultTextStyle.dart';

class BluetoothRegistration extends StatefulWidget {
  const BluetoothRegistration({super.key});

  @override
  State<BluetoothRegistration> createState() => _BluetoothRegistrationState();
}

class _BluetoothRegistrationState extends State<BluetoothRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 60, 109),
      appBar: AppBar(
        title: Text(
          "Bluetooth Device Registration",
          style: defaultTextStyle.copyWith(fontSize: 16),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: ListView(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Registered Devices:",
                    style: defaultTextStyle.copyWith(
                        color: Color.fromARGB(218, 232, 235, 240)),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                Container(
                  height: 670,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  decoration: ShapeDecoration(
                      color: Color.fromARGB(255, 221, 221, 222),
                      shadows: [
                        BoxShadow(
                            offset: Offset(0, -4),
                            blurRadius: 5,
                            color: Color.fromARGB(117, 24, 24, 24))
                      ],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30)))),
                  child: ListView.builder(
                      itemCount: 15,
                      itemBuilder: (context, index) =>
                          BluetoothDeviceWidget(deviceName: index.toString())),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
