import 'package:flutter/material.dart';

class TextInputWithPadding extends StatelessWidget {
  final String placeholder;
  final double padding;
  final Function onChanged;
  final Function? onSubmitted;
  final TextInputType type;
  final bool enabled;
  final String initialValue;

  const TextInputWithPadding({
    required this.placeholder,
    required this.padding,
    required this.onChanged,
    this.type = TextInputType.text,
    this.enabled = true,
    this.onSubmitted,
    this.initialValue = "",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: placeholder,
        ),
        onChanged: (value) => onChanged(value),
        keyboardType: type,
        obscureText: type == TextInputType.visiblePassword,
        onFieldSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
      ),
    );
  }
}
