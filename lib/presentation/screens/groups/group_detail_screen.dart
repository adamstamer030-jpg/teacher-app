import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import '../students/students_screen.dart';
import 'add_group_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  final GradeModel grade;

  const GroupDetailScreen({super.key, required this.group, required this.grade});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabCtrl;
  late GroupModel _group;
  List<ScheduleModel> _schedules = [];
  List<ExtraFeeModel> _extraFees = [];
  int _studentCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final schedules = await _db.getSchedules(groupId: _group.id);
    final fees = await _db.getExtraFees(_group.id!);
    final count = await _db.getGroupStudentCount(_group.id!);
    if (mounted) {
      setState(() {
        _schedules = schedules;
        _extraFees = fees;
        _studentCount = count;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.groupColors[_group.colorIndex % AppColors.groupColors.length];

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddGroupScreen(group: _group)),
                ).then((_) => _load()),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: color.withOpacity(0.15),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_group.name,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800)),
                                Text(widget.grade.name,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 8,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_group.monthlyFee > 0)
                              _badge('${_group.monthlyFee.toStringAsFixed(0)} ج.م / شهر',
                                  AppColors.success),
                            const SizedBox(width: 8),
                            _badge('$_studentCount طالب', AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: color,
              unselectedLabelColor: Colors.grey,
              indicatorColor: color,
              labelStyle: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'الطلاب'),
                Tab(text: 'المواعيد'),
                Tab(text: 'الرسوم الإضافية'),
              ],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _studentsTab(),
                  _schedulesTab(theme),
                  _feesTab(theme),
                ],
              ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: color, fontFamily: 'Cairo')),
    );
  }

  Widget _studentsTab() {
    return StudentsScreen(
      groupId: _group.id,
      groupName: _group.name,
    );
  }

  Widget _schedulesTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addScheduleDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة موعد'),
            ),
          ),
        ),
        Expanded(
          child: _schedules.isEmpty
              ? const EmptyState(
                  icon: Icons.calendar_today_rounded,
                  title: 'لا توجد مواعيد بعد')
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                  children: _schedules.map((s) => _scheduleCard(theme, s)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _scheduleCard(ThemeData theme, ScheduleModel s) {
    final day = AppStrings.daysOfWeek[s.dayOfWeek];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await _db.deleteSchedule(s.id!);
              _load();
            },
            icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(day,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text('${s.startTime} - ${s.endTime}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.groupColors[_group.colorIndex % AppColors.groupColors.length],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feesTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addFeeDialog(theme),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة رسوم'),
            ),
          ),
        ),
        Expanded(
          child: _extraFees.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'لا توجد رسوم إضافية')
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                  children: _extraFees.map((f) => _feeCard(theme, f)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _feeCard(ThemeData theme, ExtraFeeModel fee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await _db.deleteExtraFee(fee.id!);
              _load();
            },
            icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fee.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text('${fee.amount.toStringAsFixed(0)} ج.م',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addFeeDialog(ThemeData theme) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: 'إضافة رسوم إضافية'),
            AppTextField(label: 'اسم الرسوم', hint: 'مثال: ثمن مذكرة', controller: nameCtrl),
            const SizedBox(height: 12),
            AppTextField(
              label: 'المبلغ (ج.م)',
              hint: '0',
              controller: amountCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (name.isEmpty || amount <= 0) return;
                  await _db.insertExtraFee(
                      ExtraFeeModel(groupId: _group.id!, name: name, amount: amount));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('حفظ'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _addScheduleDialog() async {
    int selectedDay = 0;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHeader(title: 'إضافة موعد حصة'),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: AppStrings.daysOfWeek.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final sel = selectedDay == i;
                    return GestureDetector(
                      onTap: () => setS(() => selectedDay = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Theme.of(ctx).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel ? AppColors.primary : Theme.of(ctx).dividerColor),
                        ),
                        child: Center(
                          child: Text(AppStrings.daysOfWeek[i],
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: sel ? Colors.white : null)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _timeBtn(ctx, 'وقت الانتهاء', endTime,
                        (t) => setS(() => endTime = t)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeBtn(ctx, 'وقت البدء', startTime,
                        (t) => setS(() => startTime = t)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final fmt = (TimeOfDay t) =>
                        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                    await _db.insertSchedule(ScheduleModel(
                      groupId: _group.id!,
                      dayOfWeek: selectedDay,
                      startTime: fmt(startTime),
                      endTime: fmt(endTime),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _load();
                  },
                  child: const Text('إضافة الموعد'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeBtn(BuildContext ctx, String label, TimeOfDay time, void Function(TimeOfDay) onPick) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: ctx, initialTime: time);
        if (t != null) onPick(t);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: Theme.of(ctx).dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
