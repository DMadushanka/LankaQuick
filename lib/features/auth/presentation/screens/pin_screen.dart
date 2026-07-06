import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // App Identity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.offline_bolt_rounded,
                        size: 38,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LankaQuick',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    getDisplayMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

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
                          width: 20,
                          height: 20,
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
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Keypad Grid
                  PinKeypadWidget(
                    onKeyPress: _handleKeyPress,
                  ),

                  const SizedBox(height: 24),

                  // Help actions / Sign out option
                  if (!widget.isSetup)
                    TextButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(tr(ref, 'dialog_signout_title')),
                            content: Text(tr(ref, 'dialog_signout_body')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(tr(ref, 'btn_cancel')),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ref
                                      .read(appLockControllerProvider.notifier)
                                      .resetAndLogout();
                                },
                                child: Text(
                                  tr(ref, 'auth_login'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_outlined, size: 18),
                      label: Text(
                        tr(ref, 'btn_sign_out'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                  if (widget.isSetup && _isConfirming)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isConfirming = false;
                          _firstEnteredPin = '';
                          _enteredPin = '';
                          _messageType = PinScreenMessage.create;
                        });
                      },
                      child: Text(tr(ref, 'btn_back_to_create')),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
