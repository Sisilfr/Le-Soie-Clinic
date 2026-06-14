import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'jurnal_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _buildPages() {
    return [
      const HomeScreen(),
      // Belanja placeholder
      _buildPlaceholder('Belanja', Icons.shopping_bag_outlined),
      // AI placeholder
      _buildPlaceholder('AI', Icons.auto_awesome_outlined),
      // Konsultasi placeholder
      _buildPlaceholder('Konsultasi', Icons.calendar_today_outlined),
      // Jurnal screen
      const JurnalScreen(),
    ];
  }

  Widget _buildPlaceholder(String label, IconData icon) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.textGray),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                color: AppColors.textGray,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Belanja'),
      _NavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'AI'),
      _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Konsultasi'),
      _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Jurnal'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEDE8E0), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      // Reset AI sub-tab when switching away and back
                      if (index != 2) {
                        // keep sub-tab state
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active indicator pill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 40 : 0,
                        height: isSelected ? 4 : 0,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
