import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/core/theme/app_background.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';

class AuthDemoScreen extends ConsumerStatefulWidget {
  final bool isSupabaseConfigured;

  const AuthDemoScreen({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  ConsumerState<AuthDemoScreen> createState() => _AuthDemoScreenState();
}

class _AuthDemoScreenState extends ConsumerState<AuthDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  String _selectedRole = 'seeker'; // 'seeker' or 'provider'

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (widget.isSupabaseConfigured) {
      if (_isSignUp) {
        await ref.read(authControllerProvider.notifier).signup(
              name: name,
              email: email,
              password: password,
              role: _selectedRole,
            );
      } else {
        await ref.read(authControllerProvider.notifier).login(email, password);
      }
    } else {
      // Mock Sign In/Sign Up using the unified mock controller
      ref.read(mockUserControllerProvider.notifier).setUser(
        UserEntity(
          uid: 'mock_uid_12345',
          name: _isSignUp ? name : 'Demo Seeker User',
          email: email,
          role: _isSignUp ? _selectedRole : 'seeker',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControllerState = ref.watch(authControllerProvider);
    final isLoading = authControllerState.isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Brand Identity with glow and custom shape
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                      shape: BoxShape.circle,
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: -5,
                        )
                      ] : null,
                    ),
                    child: Icon(
                      Icons.diversity_3_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(ref, 'app_title'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Outfit',
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(ref, 'auth_subtitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Authentication Form Box (Glassmorphic Container)
              Container(
                decoration: AppTheme.glassDecoration(isDark: isDark),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sleek custom tab selector for Sign In vs Sign Up
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isSignUp = false),
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isSignUp
                                        ? (isDark ? const Color(0xFF1F2937) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: !_isSignUp && isDark ? [
                                      const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ] : null,
                                  ),
                                  child: Text(
                                    tr(ref, 'auth_login'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: !_isSignUp
                                          ? (isDark ? Colors.white : Colors.black87)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isSignUp = true),
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isSignUp
                                        ? (isDark ? const Color(0xFF1F2937) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _isSignUp && isDark ? [
                                      const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ] : null,
                                  ),
                                  child: Text(
                                    tr(ref, 'auth_signup'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _isSignUp
                                          ? (isDark ? Colors.white : Colors.black87)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'profile_name'),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (val) => val == null || val.isEmpty ? tr(ref, 'auth_validation_name') : null,
                        ),
                        const SizedBox(height: 18),
                      ],

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: tr(ref, 'profile_email').replaceAll(' (Cannot be modified)', ''),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (val) => val == null || !val.contains('@') ? tr(ref, 'auth_validation_email') : null,
                      ),
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        validator: (val) => val == null || val.length < 6 ? tr(ref, 'auth_validation_pass') : null,
                      ),
                      const SizedBox(height: 18),

                      if (_isSignUp) ...[
                        Text(
                          tr(ref, 'profile_role'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: Text(tr(ref, 'role_seeker')),
                                selected: _selectedRole == 'seeker',
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedRole = 'seeker');
                                },
                                selectedColor: AppTheme.primaryColor.withOpacity(0.18),
                                side: BorderSide(
                                  color: _selectedRole == 'seeker' ? AppTheme.primaryColor : Colors.transparent,
                                  width: 1.5,
                                ),
                                labelStyle: TextStyle(
                                  color: _selectedRole == 'seeker' ? AppTheme.primaryColor : Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: Text(tr(ref, 'role_provider')),
                                selected: _selectedRole == 'provider',
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedRole = 'provider');
                                },
                                selectedColor: AppTheme.secondaryColor.withOpacity(0.18),
                                side: BorderSide(
                                  color: _selectedRole == 'provider' ? AppTheme.secondaryColor : Colors.transparent,
                                  width: 1.5,
                                ),
                                labelStyle: TextStyle(
                                  color: _selectedRole == 'provider' ? AppTheme.secondaryColor : Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (authControllerState.hasError) ...[
                        Text(
                          authControllerState.error.toString(),
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Gradient Button Container
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: AppTheme.premiumButtonStyle(),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isSignUp ? tr(ref, 'auth_signup') : tr(ref, 'auth_login'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
