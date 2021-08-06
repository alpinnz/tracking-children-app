import 'package:flutter/material.dart';

class CInput extends StatefulWidget {
  final String label, hintText;
  final TextEditingController controller;
  final Function(TextEditingController) onChanged;
  final bool obscureText;
  CInput({Key key, @required this.label, this.hintText, @required this.controller, @required this.onChanged, this.obscureText = false})
      : super(key: key);

  @override
  _CInputState createState() => _CInputState();
}

class _CInputState extends State<CInput> {
  @override
  void initState() {
    widget.controller.addListener(() {
      widget.onChanged(widget.controller);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.label,
            fillColor: Colors.white,
            filled: true,
            errorStyle: TextStyle(color: Colors.red[50]),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '* tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}
