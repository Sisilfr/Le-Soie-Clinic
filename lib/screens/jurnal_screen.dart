import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/routine_item.dart';
import '../providers/routine_provider.dart';
import '../providers/notification_provider.dart';
import '../models/article.dart';
import '../providers/article_provider.dart';
import '../providers/auth_provider.dart';

class JurnalScreen extends StatefulWidget {
  const JurnalScreen({super.key});

  @override
  State<JurnalScreen> createState() => _JurnalScreenState();
}

class _JurnalScreenState extends State<JurnalScreen>
    with TickerProviderStateMixin {
  // Add form state
  bool _showAddForm = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _formAnimController;
  late Animation<double> _formSlideAnim;
  late Animation<double> _formFadeAnim;

  late TabController _tabController;
  String _selectedCategory = 'Semua';

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

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().fetchArticles();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _nameFocusNode.dispose();
    _formAnimController.dispose();
    _tabController.dispose();
    super.dispose();
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
      if (mounted) {
        setState(() {
          _showAddForm = false;
          _nameController.clear();
          _durationController.clear();
        });
      }
    });
  }

  void _submitRoutine(RoutineProvider routineProvider) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final duration = _durationController.text.trim().isEmpty
        ? '30s'
        : _durationController.text.trim();
        
    HapticFeedback.lightImpact();
    _formAnimController.reverse().then((_) {
      if (mounted) {
        routineProvider.addRoutineItem(name, duration, routineProvider.isAM);
        setState(() {
          _showAddForm = false;
          _nameController.clear();
          _durationController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Header ────────────────────────────────────────
              _buildTopHeader(),

              // TabBar in the Jurnal Screen
              _buildTabBar(),

              // ── TabBarView Body ───────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Jurnal Rutinitas
                    _buildRutinitasTab(routineProvider),
                    
                    // Tab 2: Artikel Skincare
                    _buildArtikelTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryGreen,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Jurnal Rutinitas'),
          Tab(text: 'Artikel Skincare'),
        ],
      ),
    );
  }

  Widget _buildRutinitasTab(RoutineProvider routineProvider) {
    final authProvider = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          _buildGreetingCard(authProvider.userName),
          const SizedBox(height: 20),

          // Routine card
          _buildRoutineCard(routineProvider),
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
              child: _buildAddForm(routineProvider),
            ),
            const SizedBox(height: 16),
          ],

          // Tambah Rutinitas button
          _buildTambahButton(),
        ],
      ),
    );
  }

  Widget _buildArtikelTab() {
    return Column(
      children: [
        _buildCategoryFilters(),
        Expanded(
          child: Consumer<ArticleProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (provider.errorMessage != null) {
                return _buildArticleErrorState(provider);
              }

              final filteredArticles = _selectedCategory == 'Semua'
                  ? provider.articles
                  : provider.articles
                      .where((a) => a.category == _selectedCategory)
                      .toList();

              if (filteredArticles.isEmpty) {
                return _buildArticleEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return _buildArticleCard(context, article);
                },
              );
            },
          ),
        ),
      ],
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
  Widget _buildGreetingCard(String? userName) {
    debugPrint("Debug JurnalScreen: userName = $userName");
    final displayUser = (userName != null && userName.isNotEmpty) ? userName : 'Alea';

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
            'Hai, $displayUser.',
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
              color: Colors.white.withAlpha(230),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── ROUTINE CARD ───────────────────────────────────────────────────────────
  Widget _buildRoutineCard(RoutineProvider routineProvider) {
    final doneCount = routineProvider.doneCount;
    final totalCount = routineProvider.totalCount;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;
    final currentItems = routineProvider.currentItems;

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
                _buildAmPmToggle(routineProvider),
              ],
            ),
          ),

          // Notification Reminders
          _buildReminderSwitches(),

          // Test Notification Button
          _buildTestNotificationButton(),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: maxWidth,
                              color: const Color(0xFFF0E8DC),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOut,
                              height: 6,
                              width: maxWidth * progress,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
          ...currentItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == currentItems.length - 1;
            return _buildRoutineItemRow(routineProvider, item, isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildReminderSwitches() {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, child) {
        final amTimeText = '${notifProvider.amHour.toString().padLeft(2, '0')}:${notifProvider.amMinute.toString().padLeft(2, '0')}';
        final pmTimeText = '${notifProvider.pmHour.toString().padLeft(2, '0')}:${notifProvider.pmMinute.toString().padLeft(2, '0')}';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF7F3EE), width: 0.8),
            ),
          ),
          child: Column(
            children: [
              // AM Reminder Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, size: 14, color: AppColors.accentGold),
                        const SizedBox(width: 8),
                        Text(
                          'Pengingat AM',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, true, notifProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  amTimeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 10,
                                  color: AppColors.primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: notifProvider.amReminderOn,
                      activeThumbColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        notifProvider.toggleAmReminder(val);
                      },
                    ),
                  ),
                ],
              ),
              // PM Reminder Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.nights_stay_rounded, size: 14, color: AppColors.primaryGreenLight),
                        const SizedBox(width: 8),
                        Text(
                          'Pengingat PM',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, false, notifProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pmTimeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 10,
                                  color: AppColors.primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: notifProvider.pmReminderOn,
                      activeThumbColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        notifProvider.toggleForPmReminder(val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    bool isAM,
    NotificationProvider notifProvider,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isAM
          ? TimeOfDay(hour: notifProvider.amHour, minute: notifProvider.amMinute)
          : TimeOfDay(hour: notifProvider.pmHour, minute: notifProvider.pmMinute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isAM) {
        await notifProvider.updateAmTime(picked.hour, picked.minute);
      } else {
        await notifProvider.updatePmTime(picked.hour, picked.minute);
      }
    }
  }

  Widget _buildTestNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen, width: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await notifProvider.testInstantNotification();
              },
              icon: const Icon(Icons.notification_important_rounded, size: 14, color: AppColors.primaryGreen),
              label: Text(
                'Test Notifikasi Instan',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmPmToggle(RoutineProvider routineProvider) {
    final isAM = routineProvider.isAM;
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
          _buildToggleButton(
            label: 'AM',
            icon: Icons.wb_sunny_outlined,
            isActive: isAM,
            onTap: () => routineProvider.toggleTab(true),
          ),
          _buildToggleButton(
            label: 'PM',
            icon: Icons.nights_stay_outlined,
            isActive: !isAM,
            onTap: () => routineProvider.toggleTab(false),
          ),
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

  Widget _buildRoutineItemRow(RoutineProvider routineProvider, RoutineItem item, {bool isLast = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        routineProvider.toggleDone(item);
      },
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
  Widget _buildAddForm(RoutineProvider routineProvider) {
    final isAM = routineProvider.isAM;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE8E0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D4A3E).withAlpha(15),
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
                'Tambah Rutinitas ${isAM ? "AM" : "PM"}',
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0E8),
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
            onTap: () => _submitRoutine(routineProvider),
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

  Widget _buildCategoryFilters() {
    final categories = ['Semua', 'Kandungan Skincare', 'Kesehatan Kulit', 'Kebiasaan Sehat'];
    return Container(
      height: 52,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
              selectedColor: AppColors.primaryGreen,
              backgroundColor: const Color(0xFFF5F5F5),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  width: 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showArticleDetail(context, article);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Image
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.asset(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Article Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        article.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Summary
                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleErrorState(ArticleProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Artikel',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  provider.fetchArticles();
                },
                child: Text(
                  'Coba Lagi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleEmptyState() {
    return Center(
      child: Text(
        'Tidak ada artikel dalam kategori ini.',
        style: GoogleFonts.inter(
          color: AppColors.textGray,
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Cover Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.asset(
                              article.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Category Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                article.category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          article.title,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFEDE8E0)),
                        const SizedBox(height: 16),
                        // Content Body
                        Text(
                          article.content,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textDark.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Close Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Selesai Membaca',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
