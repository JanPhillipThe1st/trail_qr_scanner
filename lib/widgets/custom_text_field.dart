import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.inputType,
      this.enabled = true,
      this.onEditingDone,
      required this.width});
  final TextEditingController controller;
  final TextInputType inputType;
  final double width;
  final Function? onEditingDone;
  final bool enabled;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(), borderRadius: BorderRadius.circular(10))),
      child: TextField(
        decoration: InputDecoration(border: InputBorder.none),
        enabled: widget.enabled,
        onEditingComplete: widget.onEditingDone!(),
        keyboardType: widget.inputType,
        controller: widget.controller,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
