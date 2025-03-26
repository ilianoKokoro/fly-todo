import 'package:flutter/material.dart';

class BottomButtonRow extends StatelessWidget {
  final String leftButtonText;
  final VoidCallback leftButtonAction;
  final bool leftButtonEnabled;
  final String rightButtonText;
  final VoidCallback rightButtonAction;
  final bool rightButtonEnabled;
  final bool mainButtonIsLeft;

  const BottomButtonRow({
    super.key,
    required this.leftButtonText,
    required this.leftButtonAction,
    this.leftButtonEnabled = true,
    required this.rightButtonText,
    required this.rightButtonAction,
    this.rightButtonEnabled = true,
    this.mainButtonIsLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          if (mainButtonIsLeft) ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: leftButtonEnabled ? leftButtonAction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,

                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                    ),
                  ),
                  child: Text(leftButtonText),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: rightButtonEnabled ? rightButtonAction : null,
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        bottomLeft: Radius.zero,
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  child: Text(rightButtonText),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: leftButtonEnabled ? leftButtonAction : null,
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                    ),
                  ),
                  child: Text(leftButtonText),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: rightButtonEnabled ? rightButtonAction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,

                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        bottomLeft: Radius.zero,
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  child: Text(rightButtonText),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
