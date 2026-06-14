import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class RoutineItem {
  final String id;
  String name;
  String duration; // e.g. "60s"
  bool isDone;

  RoutineItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isDone = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class JurnalScreen extends StatefulWidget {
  const JurnalScreen({Key? key}) : super(key: key);

  @override
  State<JurnalScreen> createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen>
    with SingleTickerProviderStateMixin {
  bool _isAM = true;

  // AM Routine items
  final List<RoutineItem> _amItems = [
    RoutineItem(id: 'am1', name: 'Gentle Foam Cleanser', duration: '60s', isDone: true),
    RoutineItem(id: 'am2', name: 'Brightening Essence', duration: '30s', isDone: true),
    RoutineItem(id: 'am3', name: 'Hydra-Glow Serum', duration: '60s', isDone: true),
    RoutineItem(id: 'am4', name: 'Barrier Repair Cream', duration: '30s', isDone: false),
    RoutineItem(id: 'am5', name: 'UV Tint SPF50', duration: '30s', isDone: false),
  ];

  // PM Routine items
  final List<RoutineItem> _pmItems = [
    RoutineItem(id: 'pm1', name: 'Oil Cleanser', duration: '60s', isDone: false),
    RoutineItem(id: 'pm2', name: 'Foam Cleanser', duration: '60s', isDone: false),
    RoutineItem(id: 'pm3', name: 'Retinol Serum', duration: '30s', isDone: false),
    RoutineItem(id: 'pm4', name: 'Night Cream', duration: '60s', isDone: false),
  ];

  // Add form state
  bool _showAddForm = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _formAnimController;
  late Animation<double> _formSlideAnim;
  late Animation<double> _formFadeAnim;

  List<RoutineItem> get _currentItems => _isAM ? _amItems : _pmItems;

  int get _doneCount => _currentItems.where((e) => e.isDone).length;
  int get _totalCount => _currentItems.length;

  @override
  void initState() {
    super.initState();
    _formAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _formSlideAnim = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(parent: _formAnimController, curve: Curves.easeOutCubic),
    );
    _formFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _nameFocusNode.dispose();
    _formAnimController.dispose();
    super.dispose();
  }

  void _toggleDone(RoutineItem item) {
    HapticFeedback.lightImpact();
    setState(() => item.isDone = !item.isDone);
  }

  void _openAddForm() {
    setState(() => _showAddForm = true);
    _formAnimController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 100), () {
      _nameFocusNode.requestFocus();
    });
  }

  void _closeAddForm() {
    _formAnimController.reverse().then((_) {
      setState(() {
        _showAddForm = false;
        _nameController.clear();
        _durationController.clear();
      });
    });
  }

  void _submitRoutine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final duration = _durationController.text.trim().isEmpty
        ? '30s'
        : _durationController.text.trim();
    final newItem = RoutineItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      duration: duration,
      isDone: false,
    );
    HapticFeedback.lightImpact();
    _formAnimController.reverse().then((_) {
      setState(() {
        if (_isAM) {
          _amItems.add(newItem);
        } else {
          _pmItems.add(newItem);
        }
        _showAddForm = false;
        _nameController.clear();
        _durationController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Header ────────────────────────────────────────
              _buildTopHeader(),

              // ── Scrollable Body ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting card
                      _buildGreetingCard(),
                      const SizedBox(height: 20),

                      // Routine card
                      _buildRoutineCard(),
                      const SizedBox(height: 20),

                      // Add Form (inline, animated)
                      if (_showAddForm) ...[
                        AnimatedBuilder(
                          animation: _formAnimController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _formFadeAnim.value,
                              child: Transform.translate(
                                offset: Offset(0, _formSlideAnim.value),
                                child: child,
                              ),
                            );
                          },
                          child: _buildAddForm(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tambah Rutinitas button
                      _buildTambahButton(),
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

  // ── TOP HEADER ─────────────────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI BEAUTY SUITE',
            style: GoogleFonts.inter(
              color: AppColors.accentGold,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Intelligence Studio',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryGreen,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── GREETING CARD ──────────────────────────────────────────────────────────
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [
            Color(0xFF4A6B5A),
            Color(0xFF2D4A3E),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hai, Alea.',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waktunya memanjakan kulitmu hari ini.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── ROUTINE CARD ───────────────────────────────────────────────────────────
  Widget _buildRoutineCard() {
    final doneCount = _doneCount;
    final totalCount = _totalCount;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header: title + AM/PM toggle
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0E8DC), width: 0.8),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rutinitas Harian',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                _buildAmPmToggle(),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          color: const Color(0xFFF0E8DC),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          height: 6,
                          width: MediaQuery.of(context).size.width * progress,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$doneCount/$totalCount',
                  style: GoogleFonts.inter(
                    color: AppColors.textGray,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Checklist items
          ..._currentItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == _currentItems.length - 1;
            return _buildRoutineItemRow(item, isLast: isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmPmToggle() {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EAD8),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(label: 'AM', icon: Icons.wb_sunny_outlined, isActive: _isAM, onTap: () => setState(() => _isAM = true)),
          _buildToggleButton(label: 'PM', icon: Icons.nights_stay_outlined, isActive: !_isAM, onTap: () => setState(() => _isAM = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 9,
              color: isActive ? Colors.white : const Color(0xFF6B6B5E),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : const Color(0xFF6B6B5E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineItemRow(RoutineItem item, {bool isLast = false}) {
    return GestureDetector(
      onTap: () => _toggleDone(item),
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF7F3EE), width: 0.8),
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.8),
        child: Row(
          children: [
            // Checkbox circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isDone ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: item.isDone
                      ? AppColors.primaryGreen
                      : const Color(0xFFD4C4A8),
                  width: 1.6,
                ),
              ),
              child: item.isDone
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 11,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Item name
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.inter(
                  color: item.isDone
                      ? const Color(0xFFB0B0A0)
                      : const Color(0xFF2A2A1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFFB0B0A0),
                ),
              ),
            ),
            // Duration
            Text(
              item.duration,
              style: GoogleFonts.inter(
                color: const Color(0xFFC0C0B0),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ADD FORM (inline, no navigation) ──────────────────────────────────────
  Widget _buildAddForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D4A3E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Rutinitas ${_isAM ? "AM" : "PM"}',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              GestureDetector(
                onTap: _closeAddForm,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFF6B6B5E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nama produk field
          Text(
            'Nama Produk / Langkah',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B6B6B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF2A2A1E),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Vitamin C Serum',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFB0B0A0),
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
            ),
          ),
          const SizedBox(height: 12),

          // Duration field
          Text(
            'Durasi',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B6B6B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final dur in ['30s', '60s', '2m', '5m'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _durationController.text = dur);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _durationController.text == dur
                            ? AppColors.primaryGreen
                            : const Color(0xFFF2EAD8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        dur,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _durationController.text == dur
                              ? Colors.white
                              : const Color(0xFF6B6B5E),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit button
          GestureDetector(
            onTap: _submitRoutine,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Simpan Rutinitas',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAMBAH BUTTON ──────────────────────────────────────────────────────────
  Widget _buildTambahButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _showAddForm
          ? const SizedBox.shrink()
          : GestureDetector(
              key: const ValueKey('tambah_btn'),
              onTap: _openAddForm,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Tambah Rutinitas',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
