import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';
import 'add_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _db = DatabaseService();
  List<GradeModel> _grades = [];
  List<GroupModel> _groups = [];
  Map<int, int> _studentCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final grades = await _db.getGrades();
    final groups = await _db.getGroups();
    final counts = <int, int>{};
    for (final g in groups) {
      counts[g.id!] = await _db.getGroupStudentCount(g.id!);
    }
    if (mounted) {
      setState(() {
        _grades = grades;
        _groups = groups;
        _studentCounts = counts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('المجموعات الدراسية المتاحة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? EmptyState(
                  icon: Icons.layers_rounded,
                  title: 'لا توجد مجموعات بعد',
                  subtitle: 'اضغط على + لإضافة مجموعة جديدة',
                  actionLabel: 'إضافة مجموعة',
                  onAction: () => _openAdd(context),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    itemCount: _grades.length,
                    itemBuilder: (ctx, i) {
                      final grade = _grades[i];
                      final gradeGroups =
                          _groups.where((g) => g.gradeId == grade.id).toList();
                      if (gradeGroups.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              grade.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                          ...gradeGroups.map((g) => _groupCard(ctx, g, grade)),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _groupCard(BuildContext context, GroupModel g, GradeModel grade) {
    final theme = Theme.of(context);
    final count = _studentCounts[g.id] ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GroupDetailScreen(group: g, grade: grade)),
      ).then((_) => _load()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            // 3-dots menu
            IconButton(
              onPressed: () => _showGroupMenu(context, g, grade),
              icon: Icon(Icons.more_vert_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(g.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(grade.name,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_rounded,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('$count طالب مقيد',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            GroupColorBar(colorIndex: g.colorIndex, height: 56),
          ],
        ),
      ),
    );
  }

  void _showGroupMenu(BuildContext context, GroupModel g, GradeModel grade) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: g.name),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
              title: const Text('تعديل بيانات المجموعة',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddGroupScreen(group: g)),
                ).then((_) => _load());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text('حذف المجموعة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, g);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GroupModel g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المجموعة', textAlign: TextAlign.right),
        content: Text('سيتم حذف "${g.name}" وكل جداولها ورسومها الإضافية.\nالطلاب لن يُحذفوا.',
            textAlign: TextAlign.right),
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
    if (ok == true) {
      await _db.deleteGroup(g.id!);
      _load();
    }
  }

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGroupScreen()),
    ).then((_) => _load());
  }
}
