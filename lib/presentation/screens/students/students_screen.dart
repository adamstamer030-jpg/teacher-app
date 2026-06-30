import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class StudentsScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const StudentsScreen({super.key, this.groupId, this.groupName});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _db = DatabaseService();
  final _searchCtrl = TextEditingController();
  List<StudentModel> _students = [];
  List<StudentModel> _filtered = [];
  String _sortBy = 'enroll_date';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final students = await _db.getStudents(groupId: widget.groupId, sortBy: _sortBy);
    if (mounted) {
      setState(() {
        _students = students;
        _filtered = students;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _students
          : _students.where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.code.contains(q) ||
              s.phone.contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName ?? 'قائمة الطلاب المقيدين'),
        actions: [
          IconButton(
            onPressed: _showSortSheet,
            icon: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: TextField(
              controller: _searchCtrl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث عن طالب بالاسم أو الكود...',
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () { _searchCtrl.clear(); _filter(); },
                        icon: const Icon(Icons.close_rounded))
                    : const Icon(Icons.search_rounded),
              ),
            ),
          ),

          // Count badge
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_filtered.length} طالب',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'لا يوجد طلاب بعد',
                        subtitle: 'اضغط على + لإضافة طالب جديد',
                        actionLabel: 'إضافة طالب',
                        onAction: () => _openAdd(context),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _studentCard(ctx, _filtered[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _studentCard(BuildContext context, StudentModel student) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(student.status);

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _callStudent(student.phone),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.call_rounded,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => _whatsapp(student.phone),
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            icon: Icons.chat_rounded,
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, student),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentDetailScreen(studentId: student.id!)),
        ).then((_) => _load()),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (student.status != 'active')
                            StatusChip(
                              label: AppStrings.studentStatuses[student.status] ?? student.status,
                              color: statusColor,
                            ),
                          if (student.status != 'active') const SizedBox(width: 6),
                          const Icon(Icons.phone_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(
                            student.phone,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              StudentCodeBadge(code: student.code),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'active' => AppColors.success,
        'paused' => AppColors.warning,
        'withdrawn' => AppColors.error,
        'deferred' => AppColors.info,
        'graduated' => AppColors.primary,
        _ => Colors.grey,
      };

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(groupId: widget.groupId),
      ),
    ).then((_) => _load());
  }

  void _callStudent(String phone) async {
    await launchUrl(Uri.parse('tel:$phone'));
  }

  void _whatsapp(String phone) async {
    final url = 'https://wa.me/2$phone';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(BuildContext context, StudentModel s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الطالب', textAlign: TextAlign.right),
        content: Text('هل تريد حذف الطالب ${s.name}؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteStudent(s.id!);
      _load();
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final sorts = {
          'enroll_date': 'تاريخ الاشتراك',
          'name': 'الاسم',
          'code': 'الكود',
          'sort_position': 'الترتيب اليدوي',
        };
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHeader(title: 'ترتيب الطلاب'),
              ...sorts.entries.map((e) => ListTile(
                    title: Text(e.value, textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                    trailing: _sortBy == e.key
                        ? const Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _sortBy = e.key);
                      Navigator.pop(ctx);
                      _load();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
