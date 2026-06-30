import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import 'add_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _db = DatabaseService();
  List<PaymentModel> _payments = [];
  Map<int, String> _studentNames = {};
  bool _loading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final from = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final to = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-$lastDay';

    final payments = await _db.getPayments(fromDate: from, toDate: to);

    // Get student names
    final students = await _db.getStudents(status: 'active');
    final allStudents = await _db.getStudents();
    final nameMap = <int, String>{};
    for (final s in [...students, ...allStudents]) {
      nameMap[s.id!] = s.name;
    }

    if (mounted) {
      setState(() {
        _payments = payments;
        _studentNames = nameMap;
        _loading = false;
      });
    }
  }

  double get _totalThisMonth => _payments
      .where((p) => p.type != 'discount')
      .fold(0.0, (s, p) => s + p.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة السجلات المالية'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
            ).then((_) => _load()),
            child: Text('+ تسجيل دفعة',
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          _monthSelector(theme),

          // Total card
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL, vertical: AppSizes.paddingM),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: Column(
                children: [
                  const Text('إجمالي ما تم تحصيله هذا الشهر',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12,
                          fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    '${_totalThisMonth.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                    ? EmptyState(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'لا توجد مدفوعات هذا الشهر',
                        actionLabel: 'تسجيل دفعة',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
                        ).then((_) => _load()),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                          itemCount: _payments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) => _paymentCard(ctx, _payments[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
        ).then((_) => _load()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _monthSelector(ThemeData theme) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL, vertical: AppSizes.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                    _selectedMonth.year, _selectedMonth.month + 1);
              });
              _load();
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                    _selectedMonth.year, _selectedMonth.month - 1);
              });
              _load();
            },
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(BuildContext context, PaymentModel p) {
    final theme = Theme.of(context);
    final studentName = _studentNames[p.studentId] ?? 'طالب #${p.studentId}';
    final typeLabel = switch (p.type) {
      'subscription' => 'اشتراك شهري',
      'extra_fee' => 'رسوم إضافية',
      'discount' => 'خصم',
      _ => p.type,
    };
    final color = p.type == 'discount' ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Text(
            '${p.type == 'discount' ? '-' : ''}${p.amount.toStringAsFixed(0)} ج.م',
            style: TextStyle(
                color: color, fontSize: 15,
                fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(p.description ?? typeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('الطالب: $studentName',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(typeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
