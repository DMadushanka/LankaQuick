import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/core/theme/app_background.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_link/features/auth/presentation/widgets/pin_keypad_widget.dart';

enum PinScreenMessage {
  create,
  confirm,
  mismatch,
  enter,
  incorrect,
}

class PinScreen extends ConsumerStatefulWidget {
  final bool isSetup;

  const PinScreen({
    super.key,
    required this.isSetup,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _firstEnteredPin = ''; // Used for matching during setup confirmation
  bool _isConfirming = false;
  late PinScreenMessage _messageType;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _messageType = widget.isSetup
        ? PinScreenMessage.create
        : PinScreenMessage.enter;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward();
    setState(() {
      _enteredPin = '';
    });
  }

  void _handleKeyPress(String value) {
    if (value == 'clear') {
      setState(() {
        _enteredPin = '';
      });
      return;
    }

    if (value == 'backspace') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
      return;
    }

    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += value;
    });

    if (_enteredPin.length == 4) {
      _processFullPin();
    }
  }

  Future<void> _processFullPin() async {
    // Wait briefly so the last dot fill animation renders
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.isSetup) {
      if (!_isConfirming) {
        // First entry in setup
        setState(() {
          _firstEnteredPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
          _messageType = PinScreenMessage.confirm;
        });
      } else {
        // Confirmation entry in setup
        if (_enteredPin == _firstEnteredPin) {
          // Successfully configured
          await ref.read(appLockControllerProvider.notifier).savePin(_enteredPin);
        } else {
          // Pins do not match
          _triggerShake();
          setState(() {
            _isConfirming = false;
            _firstEnteredPin = '';
            _messageType = PinScreenMessage.mismatch;
          });
        }
      }
    } else {
      // Login validation mode
      final success = await ref
          .read(appLockControllerProvider.notifier)
          .verifyPin(_enteredPin);

      if (!success) {
        _triggerShake();
        setState(() {
          _messageType = PinScreenMessage.incorrect;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String getDisplayMessage() {
      switch (_messageType) {
        case PinScreenMessage.create:
          return tr(ref, 'pin_create');
        case PinScreenMessage.confirm:
          return tr(ref, 'pin_confirm');
        case PinScreenMessage.mismatch:
          return tr(ref, 'pin_mismatch');
        case PinScreenMessage.enter:
          return tr(ref, 'pin_enter');
        case PinScreenMessage.incorrect:
          return tr(ref, 'pin_incorrect');
      }
    }

    Color getMessageColor() {
      switch (_messageType) {
        case PinScreenMessage.mismatch:
        case PinScreenMessage.incorrect:
          return Colors.redAccent.shade200;
        default:
          return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      }
    }

    return AppBackground(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                
                // App Logo Icon with subtle glow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.offline_bolt_rounded,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LankaQuick',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Prompt message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    getDisplayMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: getMessageColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Animated PIN indicator dots
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final offsetVal =
                        sin(_shakeAnimation.value * pi * 2) * _shakeAnimation.value;
                    return Transform.translate(
                      offset: Offset(offsetVal, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final filled = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: filled
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? Colors.white.withOpacity(0.24)
                                    : Colors.black.withOpacity(0.2)),
                            width: 2.5,
                          ),
                          boxShadow: filled && isDark ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ] : null,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 52),

                // Premium keypad panel
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: AppTheme.glassDecoration(
                    isDark: isDark,
                    opacity: 0.4,
                    borderRadius: 28,
                  ),
                  child: PinKeypadWidget(
                    onKeyPress: _handleKeyPress,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
