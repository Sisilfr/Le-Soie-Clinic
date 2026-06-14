import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textGray),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
