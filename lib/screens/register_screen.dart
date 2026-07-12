import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLocalLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom harus diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLocalLoading = true;
    });

    try {
      await context.read<AuthProvider>().register(name, email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // ── Top background image ────────────────────────
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundDarker,
                image: DecorationImage(
                  image: AssetImage('assets/images/Register.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withAlpha(38), // 0.15 * 255 = 38
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            // ── Main Content ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                  top: 230, left: 24, right: 24, bottom: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12), // 0.05 * 255 = 12
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Le Soie',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 64,
                            color: AppColors.primaryGreenLight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Heading
                    Text(
                      'Dapatkan Kulit Terbaikmu',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dapatkan akses eksklusif ke Personal Skin Journal, penawaran khusus, dan diskon 10% untuk pembelian pertamamu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Form fields
                    CustomTextField(
                      hintText: 'Nama Lengkap',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Password',
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Konfirmasi Password',
                      isPassword: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 24),

                    // Daftar button
                    _isLocalLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : CustomButton(
                            text: 'Daftar',
                            onPressed: _handleRegister,
                          ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: Color(0xFFE8E8E8))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau daftar dengan',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: Color(0xFFE8E8E8))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social buttons
                    CustomButton(
                      text: 'Continue with Google',
                      isPrimary: false,
                      icon: SvgPicture.asset(
                        'assets/icons/gg_google.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Continue with Apple',
                      isPrimary: false,
                      icon: const Icon(Icons.apple,
                          color: Colors.black, size: 24),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 32),

                    // Already have account
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Masuk di sini',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
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
    );
  }
}
