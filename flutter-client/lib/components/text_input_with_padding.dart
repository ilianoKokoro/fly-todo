import 'package:flutter/material.dart';

class TextInputWithPadding extends StatelessWidget {
  final String placeholder;
  final double padding;
  final Function onChanged;
  final TextInputType type;

  const TextInputWithPadding({
    required this.placeholder,
    required this.padding,
    required this.onChanged,
    this.type = TextInputType.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: placeholder,
        ),
        onChanged: (value) => onChanged(value),
        keyboardType: type,
        obscureText: type == TextInputType.visiblePassword,
      ),
    );
  }
}
