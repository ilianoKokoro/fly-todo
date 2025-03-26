import 'package:flutter/material.dart';

class TextInputWithPadding extends StatelessWidget {
  final String placeholder;
  final double padding;

  const TextInputWithPadding({
    required this.placeholder,
    required this.padding,
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
      ),
    );
  }
}
