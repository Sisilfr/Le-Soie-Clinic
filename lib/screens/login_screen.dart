import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                      Colors.white.withOpacity(0.2),
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
                      color: Colors.black.withOpacity(0.05),
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
                    const CustomTextField(hintText: 'Email'),
                    const SizedBox(height: 16),
                    const CustomTextField(hintText: 'Password', isPassword: true),
                    const SizedBox(height: 24),
                    
                    // Login Button
                    CustomButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
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
