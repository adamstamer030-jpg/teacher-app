import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../cubits/settings_cubit.dart';
import '../../widgets/common_widgets.dart';
import '../students/students_screen.dart';
import '../groups/groups_screen.dart';
import '../payments/payments_screen.dart';
import '../students/add_student_screen.dart';
import '../payments/add_payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final stats = await _db.getDashboardStats();
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Container(
                color: theme.cardTheme.color,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: AppSizes.paddingXL,
                  right: AppSizes.paddingXL,
                  bottom: AppSizes.paddingL,
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showSideMenu(context),
                          icon: const Icon(Icons.menu_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _notificationBell(theme),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'مرحباً، ${settings.teacherName}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'يمكنك إدارة طلابك ومجموعاتك بسهولة',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner
            SliverToBoxAdapter(child: _heroBanner(theme)),

            // Stats Grid
            SliverToBoxAdapter(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _statsGrid(theme),
            ),

            // Today's Schedule
            if (_stats != null && (_stats!['today_schedules'] as List).isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'جدول حصص اليوم',
                  icon: Icons.calendar_today_rounded,
                  actionLabel: 'عرض الكل',
                ),
              ),
              SliverToBoxAdapter(child: _todaySchedule(theme)),
            ],

            // Quick Actions
            SliverToBoxAdapter(
              child: SectionHeader(title: 'اختصارات سريعة', icon: Icons.flash_on_rounded),
            ),
            SliverToBoxAdapter(child: _quickActions(context, theme)),

            // Main Sections
            SliverToBoxAdapter(
              child: SectionHeader(title: 'الأقسام الرئيسية', icon: Icons.grid_view_rounded),
            ),
            SliverToBoxAdapter(child: _mainSections(context, theme)),

            SliverToBoxAdapter(child: const SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _notificationBell(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.notifications_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('3',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingXL),
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: Colors.white54, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'منظّم دروسك ... نجاح طلابك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  'كل ما تحتاجه لإدارة مركزك التعليمي في مكان واحد',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(ThemeData theme) {
    final s = _stats!;
    final now = DateTime.now();
    final monthPayments = s['month_payments'] as double;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'إجمالي الطلاب',
                  value: '${s['students']}',
                  icon: Icons.people_rounded,
                  iconBgColor: AppColors.primary.withOpacity(0.12),
                  iconColor: AppColors.primary,
                  subtitle: 'طالب مقيد',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'المجموعات',
                  value: '${s['groups']}',
                  icon: Icons.layers_rounded,
                  iconBgColor: AppColors.warning.withOpacity(0.12),
                  iconColor: AppColors.warning,
                  subtitle: 'مجموعة نشطة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'مدفوعات الشهر',
                  value: '${monthPayments.toStringAsFixed(0)} ج.م',
                  icon: Icons.account_balance_wallet_rounded,
                  iconBgColor: AppColors.success.withOpacity(0.12),
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'متأخرين في الدفع',
                  value: '${s['late_payers']}',
                  icon: Icons.warning_rounded,
                  iconBgColor: AppColors.error.withOpacity(0.12),
                  iconColor: AppColors.error,
                  subtitle: 'طالب',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'الاختبارات',
                  value: '${s['exams']}',
                  icon: Icons.assignment_rounded,
                  iconBgColor: AppColors.info.withOpacity(0.12),
                  iconColor: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'الحجوزات',
                  value: '${s['reservations']}',
                  icon: Icons.event_note_rounded,
                  iconBgColor: AppColors.accent.withOpacity(0.12),
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _todaySchedule(ThemeData theme) {
    final schedules = _stats!['today_schedules'] as List;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: schedules.asMap().entries.map((entry) {
          final s = entry.value as Map<String, dynamic>;
          final isLast = entry.key == schedules.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
                child: Row(
                  children: [
                    Text(
                      '${s['start_time']} - ${s['end_time']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      s['group_name'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 0, color: theme.dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _quickActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: Row(
        children: [
          Expanded(
            child: _quickActionButton(
              context,
              label: 'إضافة طالب جديد',
              icon: Icons.person_add_rounded,
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddStudentScreen()),
              ).then((_) => _loadStats()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickActionButton(
              context,
              label: 'تسجيل دفعة مالية',
              icon: Icons.add_card_rounded,
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
              ).then((_) => _loadStats()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainSections(BuildContext context, ThemeData theme) {
    final sections = [
      {'label': 'الطلاب', 'icon': Icons.people_rounded, 'screen': const StudentsScreen()},
      {'label': 'المجموعات', 'icon': Icons.layers_rounded, 'screen': const GroupsScreen()},
      {'label': 'المدفوعات', 'icon': Icons.account_balance_wallet_rounded, 'screen': const PaymentsScreen()},
      {'label': 'الاختبارات', 'icon': Icons.assignment_rounded, 'screen': null},
      {'label': 'الحجوزات', 'icon': Icons.event_note_rounded, 'screen': null},
      {'label': 'المزيد', 'icon': Icons.more_horiz_rounded, 'screen': null},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: sections.map((s) {
          return GestureDetector(
            onTap: s['screen'] != null
                ? () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => s['screen'] as Widget))
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s['icon'] as IconData,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    s['label'] as String,
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSideMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SideMenuDrawer(),
    );
  }
}

class _SideMenuDrawer extends StatelessWidget {
  const _SideMenuDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      {'icon': Icons.home_rounded, 'label': 'الشاشة الرئيسية'},
      {'icon': Icons.people_rounded, 'label': 'إدارة الطلاب'},
      {'icon': Icons.layers_rounded, 'label': 'المجموعات والصفوف'},
      {'icon': Icons.assignment_rounded, 'label': 'الاختبارات'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'المدفوعات'},
      {'icon': Icons.event_note_rounded, 'label': 'الحجوزات'},
      {'icon': Icons.bar_chart_rounded, 'label': 'التقارير'},
      {'icon': Icons.calendar_today_rounded, 'label': 'جدول الحصص'},
      {'icon': Icons.notes_rounded, 'label': 'الملاحظات'},
      {'icon': Icons.settings_rounded, 'label': 'الإعدادات'},
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    ),
                    const Spacer(),
                    const Text(
                      'قائمة النظام الشاملة',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: items.map((item) {
                    return ListTile(
                      leading: Icon(item['icon'] as IconData, color: Colors.white70, size: 20),
                      title: Text(
                        item['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.right,
                      ),
                      onTap: () => Navigator.pop(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hoverColor: Colors.white10,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('تسجيل الخروج',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
