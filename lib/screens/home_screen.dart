import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Sticky Header ─────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Hero Section (node 2:182) ──────────────
                _HeroSection(),

                // ── Ingredients Section (node 2:65) ────────
                _IngredientsSection(),

                // ── Clinic Section (node 2:199) ─────────────
                _ClinicSection(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER (node 2:240)
// bg-[#faf7f2], border-bottom rgba(74,107,90,0.15), py-16, px-20
// Left: "Le Soie" Cormorant Garamond 24px medium
// Right: person icon + bag icon (with "0" badge in green circle)
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 64,
      color: const Color(0xFFFAF7F2),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Text(
                    'Le Soie',
                    style: GoogleFonts.cormorantGaramond(
                      color: const Color(0xFF2C2C2C),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      // Search / Person icon
                      GestureDetector(
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2C2C2C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Bag icon with badge
                      GestureDetector(
                        onTap: () {},
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF2C2C2C),
                              size: 24,
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2D4A3E),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '0',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom border: rgba(74,107,90,0.15)
          Container(
            height: 1.15,
            color: const Color(0xFF4A6B5A).withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Keluar Akun',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF2D4A3E),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari Le Soie?',
            style: GoogleFonts.inter(
              color: const Color(0xFF2C2C2C),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9A9A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4A3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: Text(
                'Keluar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION (node 2:182)
// Full-width image (556px tall, bg #faf8f5), gradient overlay
// Text positioned at y=230 from top of image:
//   "Sentuhan Elegan Alam, Pancarkan Kilaumu" (Cormorant 36px)
//   Subtitle paragraph (Inter 16px #6b6b6b)
//   Two buttons: "Eksplor Koleksi" (filled green), "Cek Kondisi Kulitmu" (white outlined)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 556,
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Home.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.2),
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFFAF8F5),
              ),
            ),
          ),

          // Gradient overlay: top white 70% → middle white 50% → bottom white 90%
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xB3FFFFFF), // white 70%
                    Color(0x80FFFFFF), // white 50%
                    Color(0xE6FFFFFF), // white 90%
                  ],
                ),
              ),
            ),
          ),

          // Content pinned to bottom-left at ~y=230 from top
          Positioned(
            left: 27,
            top: 230,
            right: 27,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Text(
                  'Sentuhan Elegan Alam,\nPancarkan Kilaumu',
                  style: GoogleFonts.cormorantGaramond(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    height: 1.25, // 45px line height
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle
                Text(
                  'Temukan harmoni kulitmu melalui kemewahan bahan alami dan presisi teknologi dermatologi.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B6B6B),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.625, // 26px line height
                  ),
                ),
                const SizedBox(height: 28),
                // Button: Eksplor Koleksi (filled green)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4A3E),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 1.5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Eksplor Koleksi',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Button: Cek Kondisi Kulitmu (white outlined)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF2D4A3E),
                        width: 1.15,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cek Kondisi Kulitmu',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2D4A3E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INGREDIENTS SECTION (node 2:65)
// bg-[#faf7f2], px-20, py-64
// Centered title: "Sentuhan Murni Alam dan Inovasi Teknologi" (Cormorant 32px center)
// Subtitle paragraph (Inter 14px #6b6b6b center)
// 3 ingredient cards side by side (Tea Tree, Centella Asiatica, Beras)
//   - rounded-[16px] image 109.8px × 109.8px
//   - Bold name + regular description, 12px centered
// ─────────────────────────────────────────────────────────────────────────────
class _IngredientsSection extends StatelessWidget {
  static const _ingredients = [
    {
      'image': 'assets/images/tea_tree.png',
      'name': 'Tea Tree',
      'desc': 'Menenangkan peradangan dan merawat kulit berjerawat',
    },
    {
      'image': 'assets/images/centella_asiatica.png',
      'name': 'Centella Asiatica',
      'desc': 'Mempercepat pemulihan skin barrier dan meredakan kemerahan.',
    },
    {
      'image': 'assets/images/beras.png',
      'name': 'Beras',
      'desc': 'Nutrisi alami untuk kulit yang tampak lebih cerah dan halus.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF7F2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
      child: Column(
        children: [
          // Section title — centered, Cormorant 32px
          Text(
            'Sentuhan Murni Alam dan Inovasi Teknologi',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFF2C2C2C),
              fontSize: 32,
              fontWeight: FontWeight.w500,
              height: 1.125, // 36px line height
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Kulitmu layak mendapatkan yang terbaik. Le Soie bukan hanya memilih bahan alami, kami menyempurnakannya',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF6B6B6B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.625, // ~22.75px line height
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 3 ingredient cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_ingredients.length, (i) {
              final item = _ingredients[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i > 0 ? 6 : 0,
                    right: i < _ingredients.length - 1 ? 6 : 0,
                  ),
                  child: _IngredientCard(
                    imagePath: item['image']!,
                    name: item['name']!,
                    description: item['desc']!,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String description;

  const _IngredientCard({
    required this.imagePath,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image with rounded corners
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFEDE8E0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name (bold) + description (regular), 12px, centered
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: '$name\n',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2C2C2C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              TextSpan(
                text: description,
                style: GoogleFonts.inter(
                  color: const Color(0xFF2C2C2C),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLINIC SECTION (node 2:199)
// bg: linear-gradient(132.48deg, #2d4a3e → #4a6b5a)
// px-20 pt-64, centered text
// Title: "Beyond Skincare. A Holistic Beauty Experience." (Cormorant 30px white center)
// Subtitle: Inter 14px white 90% opacity center
// Button: white with green border pill, "Reservasi Jadwal Treatment"
// ─────────────────────────────────────────────────────────────────────────────
class _ClinicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.65, -0.76),
          end: Alignment(0.65, 0.76),
          colors: [
            Color(0xFF2D4A3E),
            Color(0xFF4A6B5A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 64, 20, 64),
        child: Column(
          children: [
            // Title — Cormorant 30px white center
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Beyond Skincare. A Holistic Beauty Experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  height: 1.25, // 37.5px line height
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Subtitle — Inter 14px white 90% opacity center
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Perawatan sejati bekerja dari luar dan dalam. Kunjungi Le Soie Clinic untuk konsultasi dermatologi, treatment facial berstandar medis, dan teknologi laser terkini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.625, // 22.75px line height
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Button — white with green border, pill shape
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF2D4A3E),
                    width: 1.15,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Reservasi Jadwal Treatment',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2D4A3E),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
