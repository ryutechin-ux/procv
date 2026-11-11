import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';
import '../../data/models/user_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAs(String role) async {
    setState(() => _isLoading = true);

    if (firebaseConfigured) {
      final email = role == 'admin'
          ? 'admin@procv.com'
          : role == 'developer'
              ? 'dev@procv.com'
              : 'john@example.com';
      final password = role == 'admin'
          ? 'Admin@123456'
          : role == 'developer'
              ? 'Dev@123456'
              : 'User@123456';
      final name = role == 'admin'
          ? 'System Admin'
          : role == 'developer'
              ? 'Sarah Developer'
              : 'John Doe';
      try {
        final repo = ref.read(firebaseRepositoryProvider);
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
        UserModel user;
        try {
          user = await repo.signIn(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            user = await repo.register(name: name, email: email, password: password);
          } else {
            rethrow;
          }
        }
        if (!mounted) return;
        ref.read(currentUserProvider.notifier).state = user;
        if (user.role == 'admin') {
          context.go('/admin');
        } else if (user.role == 'developer') {
          context.go('/developer');
        } else {
          context.go('/dashboard');
        }
        return;
      } catch (e) {
        debugPrint('Firebase quick login fallback to mock: $e');
      }
    }

    if (!mounted) return;
    if (role == 'admin') {
      ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'admin');
      context.go('/admin');
    } else if (role == 'developer') {
      ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'developer');
      context.go('/developer');
    } else {
      ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'user');
      context.go('/dashboard');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      setState(() => _isLoading = true);

      if (firebaseConfigured) {
        try {
          final user = await ref.read(firebaseRepositoryProvider).signIn(
                email: email,
                password: password,
              );
          if (!mounted) return;
          ref.read(currentUserProvider.notifier).state = user;
          if (user.role == 'admin') {
            context.go('/admin');
          } else if (user.role == 'developer') {
            context.go('/developer');
          } else {
            context.go('/dashboard');
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                'Login failed: ${e.toString().replaceAll("Exception:", "").trim()}',
              ),
            ),
          );
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
        return;
      }

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final user = MockDataService.users.cast<dynamic>().firstWhere(
              (u) => u.email.toLowerCase() == email.toLowerCase(),
              orElse: () => null,
            );

        if (user != null) {
          ref.read(currentUserProvider.notifier).state = user;
          if (user.role == 'admin') {
            context.go('/admin');
          } else if (user.role == 'developer') {
            context.go('/developer');
          } else {
            context.go('/dashboard');
          }
        } else {
          // Default to regular user if not found in mock table
          _loginAs('user');
        }
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (firebaseConfigured) {
      setState(() => _isLoading = true);
      try {
        final user = await ref.read(firebaseRepositoryProvider).signInWithGoogle();
        if (!mounted) return;
        ref.read(currentUserProvider.notifier).state = user;
        if (user.role == 'admin') {
          context.go('/admin');
        } else if (user.role == 'developer') {
          context.go('/developer');
        } else {
          context.go('/dashboard');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Google sign-in failed: ${e.toString().replaceAll("Exception:", "").trim()}',
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _loginAs('user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Branding Side Panel (Desktop only)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'ProCV',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transform your career with handcrafted resumes.',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ProCV connects ambitious candidates with expert human CV developers for bespoke, ATS-optimized resumes that land interviews.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.sidebarText,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_outlined, color: AppColors.accentLighter, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '3-Tier Quality Review: User Submission → Dedicated Developer Crafting → Admin Final Approval.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '© 2026 ProCV Inc. All rights reserved.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),

          // Form Panel
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Welcome Back', style: AppTextStyles.heading2),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to access your resumes, requests, and portfolios.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),

                            // Quick Role Switcher for Demo testing
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.flash_on, size: 16, color: AppColors.accent),
                                      const SizedBox(width: 6),
                                      Text('Demo Quick Sign-in:', style: AppTextStyles.labelSmall),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _loginAs('user'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text('User', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _loginAs('developer'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text('Developer', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _loginAs('admin'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text('Admin', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter email address';
                                if (!val.contains('@')) return 'Enter valid email address';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR', style: AppTextStyles.caption),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Google Sign In Button
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.red),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account?", style: AppTextStyles.bodyMedium),
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: const Text('Create an Account'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

