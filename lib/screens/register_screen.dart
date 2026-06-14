import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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
                      Colors.white.withOpacity(0.15),
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
                    const CustomTextField(hintText: 'Nama Lengkap'),
                    const SizedBox(height: 16),
                    const CustomTextField(hintText: 'Email'),
                    const SizedBox(height: 16),
                    const CustomTextField(hintText: 'Password', isPassword: true),
                    const SizedBox(height: 16),
                    const CustomTextField(
                        hintText: 'Konfirmasi Password', isPassword: true),
                    const SizedBox(height: 24),

                    // Daftar button
                    CustomButton(
                      text: 'Daftar',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/main');
                      },
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
