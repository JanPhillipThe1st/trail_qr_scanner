import 'package:flutter/material.dart';

class BluetoothDeviceWidget extends StatefulWidget {
  const BluetoothDeviceWidget({super.key, this.deviceName});
  final String? deviceName;
  @override
  State<BluetoothDeviceWidget> createState() => _BluetoothDeviceWidgetState();
}

class _BluetoothDeviceWidgetState extends State<BluetoothDeviceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: Row(
              children: [
                Text(widget.deviceName.toString()),
                VerticalDivider(
                  color: Color.fromARGB(255, 47, 47, 49),
                )
              ],
            ),
          ),
          Divider(
            height: 8,
            thickness: 1,
            endIndent: 0,
            color: Color.fromARGB(255, 113, 114, 119),
          )
        ],
      ),
    );
  }
}
