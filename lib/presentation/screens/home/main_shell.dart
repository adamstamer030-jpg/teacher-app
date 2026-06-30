import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../home/home_screen.dart';
import '../students/students_screen.dart';
import '../payments/payments_screen.dart';
import '../groups/groups_screen.dart';
import '../students/add_student_screen.dart';
import '../payments/add_payment_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    StudentsScreen(),
    SizedBox.shrink(), // placeholder for FAB
    GroupsScreen(),
    PaymentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: [
          const HomeScreen(),
          const StudentsScreen(),
          const GroupsScreen(),
          const PaymentsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSizes.navBarHeight,
            child: Row(
              children: [
                _navItem(0, Icons.wallet_rounded, Icons.wallet_rounded, 'المدفوعات'),
                _navItem(3, Icons.layers_rounded, Icons.layers_rounded, 'المجموعات'),
                // Center FAB
                Expanded(
                  child: GestureDetector(
                    onTap: _showQuickActions,
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
                _navItem(1, Icons.people_rounded, Icons.people_rounded, 'الطلاب'),
                _navItem(0, Icons.home_rounded, Icons.home_rounded, 'الرئيسية'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    // Map display index to actual screen index
    final screenIndex = switch (label) {
      'الرئيسية' => 0,
      'الطلاب' => 1,
      'المجموعات' => 2,
      'المدفوعات' => 3,
      _ => 0,
    };
    final isSelected = _currentIndex == screenIndex;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = screenIndex),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected
                  ? theme.bottomNavigationBarTheme.selectedItemColor
                  : theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? theme.bottomNavigationBarTheme.selectedItemColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final actions = [
          {
            'label': 'إضافة طالب جديد',
            'icon': Icons.person_add_rounded,
            'color': AppColors.success,
            'screen': const AddStudentScreen(),
          },
          {
            'label': 'تسجيل دفعة مالية',
            'icon': Icons.add_card_rounded,
            'color': AppColors.primary,
            'screen': const AddPaymentScreen(),
          },
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('إضافة سريعة',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => a['screen'] as Widget),
                      );
                    },
                    icon: Icon(a['icon'] as IconData),
                    label: Text(a['label'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: a['color'] as Color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
