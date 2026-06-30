import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import 'add_student_screen.dart';
import '../payments/add_payment_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabCtrl;
  StudentModel? _student;
  GradeModel? _grade;
  GroupModel? _group;
  List<PaymentModel> _payments = [];
  List<ExamResultModel> _examResults = [];
  List<AttendanceModel> _attendance = [];
  List<StudentNoteModel> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
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

    final student = await _db.getStudent(widget.studentId);
    if (student == null) { if (mounted) Navigator.pop(context); return; }

    final grades = await _db.getGrades();
    final groups = await _db.getGroups();
    final payments = await _db.getPayments(studentId: widget.studentId);
    final examResults = await _db.getStudentExamResults(widget.studentId);
    final attendance = await _db.getAttendance();
    final studentAttendance = attendance.where((a) => a.studentId == widget.studentId).toList();
    final notes = await _db.getStudentNotes(widget.studentId);

    if (mounted) {
      setState(() {
        _student = student;
        _grade = grades.where((g) => g.id == student.gradeId).firstOrNull;
        _group = student.groupId != null
            ? groups.where((g) => g.id == student.groupId).firstOrNull
            : null;
        _payments = payments;
        _examResults = examResults;
        _attendance = studentAttendance;
        _notes = notes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    final s = _student!;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScroll) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddStudentScreen(student: s)),
                ).then((_) => _load()),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white24,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0] : '?',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800,
                              color: Colors.white, fontFamily: 'Cairo'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(s.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'كود: ${s.code}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.studentStatuses[s.status] ?? s.status,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [
                Tab(text: 'البيانات'),
                Tab(text: 'المدفوعات'),
                Tab(text: 'الحضور'),
                Tab(text: 'الاختبارات'),
                Tab(text: 'الملاحظات'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _infoTab(theme, s),
            _paymentsTab(theme),
            _attendanceTab(theme),
            _examsTab(theme),
            _notesTab(theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddPaymentScreen(studentId: s.id, studentName: s.name)),
        ).then((_) => _load()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _infoTab(ThemeData theme, StudentModel s) {
    final totalPaid = _payments
        .where((p) => p.type != 'discount')
        .fold(0.0, (sum, p) => sum + p.amount);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      children: [
        // Contact Buttons
        Row(
          children: [
            if (s.parentPhone != null)
              Expanded(
                child: _contactBtn(
                  label: 'واتساب ولي الأمر',
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  onTap: () => _whatsapp(s.parentPhone!),
                ),
              ),
            if (s.parentPhone != null) const SizedBox(width: 8),
            Expanded(
              child: _contactBtn(
                label: 'واتساب الطالب',
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                onTap: () => _whatsapp(s.phone),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _contactBtn(
                label: 'اتصال',
                icon: Icons.call_rounded,
                color: AppColors.primary,
                onTap: () => launchUrl(Uri.parse('tel:${s.phone}')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryItem('إجمالي المدفوع', '${totalPaid.toStringAsFixed(0)} ج.م',
                    AppColors.success),
              ),
              Expanded(
                child: _summaryItem('نسبة الحضور',
                    _attendanceRate(), AppColors.info),
              ),
              Expanded(
                child: _summaryItem('متوسط الدرجات',
                    _avgScore(), AppColors.warning),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Fields
        _infoCard(theme, [
          _infoRow(theme, 'الاسم', s.name),
          _infoRow(theme, 'الكود', s.code),
          _infoRow(theme, 'الهاتف', s.phone),
          if (s.parentPhone != null) _infoRow(theme, 'ولي الأمر', s.parentPhone!),
          if (_grade != null) _infoRow(theme, 'الصف', _grade!.name),
          if (_group != null) _infoRow(theme, 'المجموعة', _group!.name),
          _infoRow(theme, 'النوع', s.gender == 'male' ? 'ذكر' : 'أنثى'),
          _infoRow(theme, 'تاريخ الاشتراك',
              '${s.enrollDate.year}/${s.enrollDate.month}/${s.enrollDate.day}'),
          if (s.school != null) _infoRow(theme, 'المدرسة', s.school!),
          if (s.address != null) _infoRow(theme, 'العنوان', s.address!),
          if (s.notes != null) _infoRow(theme, 'ملاحظات', s.notes!),
        ]),
      ],
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: color, fontFamily: 'Cairo')),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.grey,
                fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ],
    );
  }

  String _attendanceRate() {
    if (_attendance.isEmpty) return '-';
    final present = _attendance.where((a) => a.status == 'present' || a.status == 'late').length;
    return '${(present / _attendance.length * 100).round()}%';
  }

  String _avgScore() {
    final withScore = _examResults.where((r) => r.score != null).toList();
    if (withScore.isEmpty) return '-';
    final avg = withScore.fold(0.0, (s, r) => s + r.score!) / withScore.length;
    return avg.toStringAsFixed(1);
  }

  Widget _contactBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: color, fontFamily: 'Cairo'),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(ThemeData theme, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.left),
          ),
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _paymentsTab(ThemeData theme) {
    if (_payments.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_rounded,
        title: 'لا توجد مدفوعات بعد',
        actionLabel: 'تسجيل دفعة',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPaymentScreen(
                studentId: _student!.id, studentName: _student!.name),
          ),
        ).then((_) => _load()),
      );
    }

    final total = _payments
        .where((p) => p.type != 'discount')
        .fold(0.0, (s, p) => s + p.amount);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      children: [
        // Total
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.success, Color(0xFF059669)]),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            children: [
              const Text('إجمالي ما تم تحصيله',
                  style: TextStyle(color: Colors.white70, fontSize: 12,
                      fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${total.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._payments.map((p) => _paymentCard(theme, p)),
      ],
    );
  }

  Widget _paymentCard(ThemeData theme, PaymentModel p) {
    final typeLabel = switch (p.type) {
      'subscription' => 'اشتراك شهري',
      'extra_fee' => 'رسوم إضافية',
      'discount' => 'خصم',
      _ => p.type,
    };
    final color = p.type == 'discount' ? AppColors.error : AppColors.success;

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
          Text('${p.type == 'discount' ? '-' : ''}${p.amount.toStringAsFixed(0)} ج.م',
              style: TextStyle(
                  color: color, fontSize: 15,
                  fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(p.description ?? typeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('${p.date.year}/${p.date.month}/${p.date.day}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(typeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceTab(ThemeData theme) {
    if (_attendance.isEmpty) {
      return const EmptyState(
        icon: Icons.how_to_reg_rounded,
        title: 'لا توجد سجلات حضور بعد',
      );
    }

    final counts = {
      'present': _attendance.where((a) => a.status == 'present').length,
      'absent': _attendance.where((a) => a.status == 'absent').length,
      'late': _attendance.where((a) => a.status == 'late').length,
      'excused': _attendance.where((a) => a.status == 'excused').length,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      children: [
        Row(
          children: [
            Expanded(child: _attendanceStat('حاضر', counts['present']!, AppColors.success)),
            Expanded(child: _attendanceStat('غائب', counts['absent']!, AppColors.error)),
            Expanded(child: _attendanceStat('متأخر', counts['late']!, AppColors.warning)),
            Expanded(child: _attendanceStat('بإذن', counts['excused']!, AppColors.info)),
          ],
        ),
        const SizedBox(height: 16),
        ..._attendance.map((a) {
          final statusColor = switch (a.status) {
            'present' => AppColors.success,
            'absent' => AppColors.error,
            'late' => AppColors.warning,
            _ => AppColors.info,
          };
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                StatusChip(
                  label: AppStrings.attendanceStatuses[a.status] ?? a.status,
                  color: statusColor,
                ),
                const Spacer(),
                Text('${a.date.year}/${a.date.month}/${a.date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _attendanceStat(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: color, fontFamily: 'Cairo')),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey,
                  fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _examsTab(ThemeData theme) {
    if (_examResults.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_rounded,
        title: 'لا توجد اختبارات بعد',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      children: _examResults.map((r) {
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
              Text(
                r.score != null ? '${r.score!.toStringAsFixed(0)}' : '-',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: r.score != null ? AppColors.primary : Colors.grey,
                    fontFamily: 'Cairo'),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('اختبار #${r.examId}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (r.notes != null)
                    Text(r.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _notesTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addNoteDialog(theme),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة ملاحظة'),
            ),
          ),
        ),
        Expanded(
          child: _notes.isEmpty
              ? const EmptyState(
                  icon: Icons.notes_rounded,
                  title: 'لا توجد ملاحظات بعد')
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                  children: _notes.map((n) => _noteCard(theme, n)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _noteCard(ThemeData theme, StudentNoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await _db.deleteStudentNote(note.id!);
                      _load();
                    },
                    icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _editNoteDialog(theme, note),
                    icon: const Icon(Icons.edit_rounded, color: Colors.grey, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Spacer(),
              Text('${note.createdAt.year}/${note.createdAt.month}/${note.createdAt.day}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Future<void> _addNoteDialog(ThemeData theme) async {
    final ctrl = TextEditingController();
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
            const SheetHeader(title: 'إضافة ملاحظة'),
            TextField(
              controller: ctrl,
              maxLines: 4,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: 'اكتب ملاحظة...'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  await _db.insertStudentNote(StudentNoteModel(
                    studentId: widget.studentId,
                    text: ctrl.text.trim(),
                  ));
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

  Future<void> _editNoteDialog(ThemeData theme, StudentNoteModel note) async {
    final ctrl = TextEditingController(text: note.text);
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
            const SheetHeader(title: 'تعديل الملاحظة'),
            TextField(
              controller: ctrl,
              maxLines: 4,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: 'نص الملاحظة...'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  await _db.updateStudentNote(
                      StudentNoteModel(id: note.id, studentId: note.studentId, text: ctrl.text.trim()));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('حفظ التعديل'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _whatsapp(String phone) {
    launchUrl(Uri.parse('https://wa.me/2$phone'),
        mode: LaunchMode.externalApplication);
  }
}
