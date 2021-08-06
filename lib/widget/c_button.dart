import 'package:flutter/material.dart';

class CButton extends StatelessWidget {
  final Function onPressed;
  final String label;
  final bool disabled, loading;

  CButton({Key key, this.onPressed, this.label, this.disabled = false, this.loading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: disabled ? Colors.white : Colors.white,
      primary: disabled ? Colors.grey : Colors.red[400],
      minimumSize: Size(double.infinity, 45),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: raisedButtonStyle,
        onPressed: onPressed,
        child: loading
            ? Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator()))
            : Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
