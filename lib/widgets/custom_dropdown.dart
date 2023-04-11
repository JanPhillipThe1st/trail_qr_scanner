import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key, required this.list, required this.width});
  final List<String> list;
  final double width;
  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String dropdownValue = "";
  @override
  Widget build(BuildContext context) {
    if (dropdownValue == "") {
      dropdownValue = widget.list.first;
    }
    return Container(
        width: widget.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                side: BorderSide(), borderRadius: BorderRadius.circular(10))),
        child: DropdownButton<String>(
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
          items: widget.list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Container(width: 300, child: Text(value)),
            );
          }).toList(),
        ));
  }
}
