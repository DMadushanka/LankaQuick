import 'package:flutter/material.dart';

class PinKeypadWidget extends StatelessWidget {
  final Function(String) onKeyPress;

  const PinKeypadWidget({
    super.key,
    required this.onKeyPress,
  });

  Widget _buildKeypadButton({
    required BuildContext context,
    required String label,
    Widget? icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withOpacity(0.15),
            highlightColor: theme.colorScheme.primary.withOpacity(0.08),
            child: Center(
              child: icon ??
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Outfit',
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton(
              context: context,
              label: '1',
              onTap: () => onKeyPress('1'),
            ),
            _buildKeypadButton(
              context: context,
              label: '2',
              onTap: () => onKeyPress('2'),
            ),
            _buildKeypadButton(
              context: context,
              label: '3',
              onTap: () => onKeyPress('3'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton(
              context: context,
              label: '4',
              onTap: () => onKeyPress('4'),
            ),
            _buildKeypadButton(
              context: context,
              label: '5',
              onTap: () => onKeyPress('5'),
            ),
            _buildKeypadButton(
              context: context,
              label: '6',
              onTap: () => onKeyPress('6'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton(
              context: context,
              label: '7',
              onTap: () => onKeyPress('7'),
            ),
            _buildKeypadButton(
              context: context,
              label: '8',
              onTap: () => onKeyPress('8'),
            ),
            _buildKeypadButton(
              context: context,
              label: '9',
              onTap: () => onKeyPress('9'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton(
              context: context,
              label: 'C',
              icon: Text(
                'C',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent.shade200,
                  fontFamily: 'Outfit',
                ),
              ),
              onTap: () => onKeyPress('clear'),
            ),
            _buildKeypadButton(
              context: context,
              label: '0',
              onTap: () => onKeyPress('0'),
            ),
            _buildKeypadButton(
              context: context,
              label: 'back',
              icon: Icon(
                Icons.backspace_rounded,
                size: 22,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              onTap: () => onKeyPress('backspace'),
            ),
          ],
        ),
      ],
    );
  }
}
