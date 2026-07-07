import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLocalLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLocalLoading = true;
    });

    try {
      await context.read<AuthProvider>().login(email, password);
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
            // Top Image Background Placeholder
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundDarker,
                image: DecorationImage(
                  image: AssetImage('assets/images/Login.png'),
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
                      Colors.white.withAlpha(50),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            
            // Main Content Container
            Padding(
              padding: const EdgeInsets.only(top: 250, left: 24, right: 24, bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading 1: Le Soie
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
                    
                    // Heading 2: Greeting
                    Text(
                      'Selamat Datang Kembali!',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sentuhan Alami, Kilau Sempurnamu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    
                    // Form Inputs
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
                    const SizedBox(height: 24),
                    
                    // Login Button
                    _isLocalLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : CustomButton(
                            text: 'Login',
                            onPressed: _handleLogin,
                          ),
                    const SizedBox(height: 24),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE8E8E8))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau masuk dengan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE8E8E8))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Buttons
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
                      icon: const Icon(Icons.apple, color: Colors.black, size: 24),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 32),
                    
                    // Sign Up Text
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Belum punya akun? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
