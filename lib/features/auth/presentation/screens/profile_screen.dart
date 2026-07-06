import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_link/core/localization/app_localizations.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/auth/domain/entities/user_entity.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _uidController;
  late String _selectedRole;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _uidController = TextEditingController();
    _selectedRole = 'seeker';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  void _initializeFields(UserEntity user) {
    if (_initialized) return;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _uidController.text = user.uid;
    _selectedRole = user.role;
    _initialized = true;
  }

  void _save(UserEntity user) async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    
    await ref.read(authControllerProvider.notifier).updateProfile(
          uid: user.uid,
          name: newName,
          role: _selectedRole,
        );

    final authControllerState = ref.read(authControllerProvider);
    if (!authControllerState.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(tr(ref, 'toast_profile_updated'))),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _initialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);
    final currentLocale = ref.watch(localeStateProvider);
    final isLoading = authState.isLoading;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    _initializeFields(user);

    final isModified = _nameController.text.trim() != user.name ||
        _selectedRole != user.role;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top User Card Profile Identity
                Card(
                  elevation: isDark ? 2 : 4,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _selectedRole == 'provider'
                              ? AppTheme.secondaryColor
                              : AppTheme.primaryColor,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Language Selection Section
                Text(
                  tr(ref, 'lang_select'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: isDark ? 1 : 2,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('English'),
                          selected: currentLocale == 'en',
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(localeStateProvider.notifier).setLocale('en');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('සිංහල'),
                          selected: currentLocale == 'si',
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(localeStateProvider.notifier).setLocale('si');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('தமிழ்'),
                          selected: currentLocale == 'ta',
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(localeStateProvider.notifier).setLocale('ta');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profile Fields Group
                Text(
                  tr(ref, 'profile_edit'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Edit Form Cards
                Card(
                  elevation: isDark ? 1 : 2,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'profile_name'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? tr(ref, 'auth_validation_name')
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'profile_email'),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _uidController,
                          enabled: false,
                          style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'profile_uid'),
                            prefixIcon: const Icon(Icons.perm_identity_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                  if (selected) {
                                    setState(() {
                                      _selectedRole = 'seeker';
                                    });
                                  }
                                },
                                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedRole == 'seeker' ? AppTheme.primaryColor : Colors.grey,
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
                                  if (selected) {
                                    setState(() {
                                      _selectedRole = 'provider';
                                    });
                                  }
                                },
                                selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedRole == 'provider' ? AppTheme.secondaryColor : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (authState.hasError) ...[
                          Text(
                            authState.error.toString(),
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],

                        ElevatedButton(
                          onPressed: (isModified && !isLoading) ? () => _save(user) : null,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(tr(ref, 'btn_save')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Out Action Button
                ElevatedButton.icon(
                  onPressed: () {
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
                              ref.read(appLockControllerProvider.notifier).resetAndLogout();
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout_outlined),
                  label: Text(tr(ref, 'btn_sign_out')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
