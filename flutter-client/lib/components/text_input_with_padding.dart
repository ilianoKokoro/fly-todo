import 'package:flutter/material.dart';

class TextInputWithPadding extends StatelessWidget {
  final String placeholder;
  final double padding;
  final Function onChanged;
  final Function? onSubmitted;
  final TextInputType type;
  final bool enabled;

  const TextInputWithPadding({
    required this.placeholder,
    required this.padding,
    required this.onChanged,
    this.type = TextInputType.text,
    this.enabled = true,
    this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextField(
        enabled: enabled,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: placeholder,
        ),
        onChanged: (value) => onChanged(value),
        keyboardType: type,
        obscureText: type == TextInputType.visiblePassword,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
      ),
    );
  }
}
