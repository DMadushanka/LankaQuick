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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withOpacity(0.12),
            highlightColor: theme.colorScheme.primary.withOpacity(0.06),
            child: Center(
              child: icon ??
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent.shade400,
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
              icon: const Icon(
                Icons.backspace_outlined,
                size: 24,
                color: Colors.grey,
              ),
              onTap: () => onKeyPress('backspace'),
            ),
          ],
        ),
      ],
    );
  }
}
