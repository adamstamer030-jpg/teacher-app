import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';

class AddGroupScreen extends StatefulWidget {
  final GroupModel? group;
  final int? presetGradeId;

  const AddGroupScreen({super.key, this.group, this.presetGradeId});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();

  List<GradeModel> _grades = [];
  int? _selectedGradeId;
  int _selectedColorIndex = 0;
  bool _saving = false;

  // Schedules
  final List<Map<String, dynamic>> _schedules = [];

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final grades = await _db.getGrades();
    setState(() {
      _grades = grades;
      if (widget.group != null) {
        final g = widget.group!;
        _nameCtrl.text = g.name;
        _notesCtrl.text = g.notes ?? '';
        _locationCtrl.text = g.location ?? '';
        _feeCtrl.text = g.monthlyFee > 0 ? g.monthlyFee.toStringAsFixed(0) : '';
        _selectedGradeId = g.gradeId;
        _selectedColorIndex = g.colorIndex;
      } else {
        _selectedGradeId = widget.presetGradeId ?? (grades.isNotEmpty ? grades.first.id : null);
      }
    });

    if (_isEditing) {
      final schedules = await _db.getSchedules(groupId: widget.group!.id);
      setState(() {
        for (final s in schedules) {
          _schedules.add({
            'id': s.id,
            'day': s.dayOfWeek,
            'start': s.startTime,
            'end': s.endTime,
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGradeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر الصف الدراسي', textAlign: TextAlign.right)),
      );
      return;
    }
    setState(() => _saving = true);

    final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0;
    final group = GroupModel(
      id: widget.group?.id,
      gradeId: _selectedGradeId!,
      name: _nameCtrl.text.trim(),
      colorIndex: _selectedColorIndex,
      monthlyFee: fee,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null,
    );

    int groupId;
    if (_isEditing) {
      await _db.updateGroup(group);
      groupId = group.id!;
      await _db.deleteSchedulesByGroup(groupId);
    } else {
      groupId = await _db.insertGroup(group);
    }

    // Save schedules
    for (final s in _schedules) {
      await _db.insertSchedule(ScheduleModel(
        groupId: groupId,
        dayOfWeek: s['day'] as int,
        startTime: s['start'] as String,
        endTime: s['end'] as String,
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل بيانات المجموعة' : 'إضافة مجموعة جديدة'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          children: [
            // Grade
            if (_grades.isNotEmpty)
              AppDropdown<int>(
                label: 'الصف الدراسي',
                value: _selectedGradeId,
                items: _grades
                    .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGradeId = v),
              ),
            const SizedBox(height: AppSizes.paddingL),

            // Name
            AppTextField(
              label: 'اسم المجموعة *',
              hint: 'مثال: مجموعة أولى ثانوي (أ)',
              controller: _nameCtrl,
              validator: (v) => v?.trim().isEmpty == true ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Monthly Fee
            AppTextField(
              label: 'رسوم الاشتراك الشهري (ج.م)',
              hint: '0',
              controller: _feeCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Location
            AppTextField(
              label: 'مكان الحصة',
              hint: 'مثال: قاعة A',
              controller: _locationCtrl,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Color Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('لون المجموعة',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: List.generate(AppColors.groupColors.length, (i) {
                    final selected = _selectedColorIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = i),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.groupColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? theme.colorScheme.onSurface : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: AppColors.groupColors[i].withOpacity(0.5), blurRadius: 6)]
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Schedules
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _addScheduleDialog,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('إضافة موعد'),
                    ),
                    const Spacer(),
                    Text('مواعيد الحصص',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                if (_schedules.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._schedules.asMap().entries.map((e) {
                    final s = e.value;
                    final day = AppStrings.daysOfWeek[s['day'] as int];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _schedules.removeAt(e.key)),
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.error, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Spacer(),
                          Text('${s['start']} - ${s['end']}  •  $day',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Notes
            AppTextField(
              label: 'ملاحظات',
              controller: _notesCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'حفظ التعديلات' : 'حفظ المجموعة'),
              ),
            ),
            const SizedBox(height: 40),
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
              // Day selector
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
                          color: sel
                              ? AppColors.primary
                              : Theme.of(ctx).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sel ? AppColors.primary : Theme.of(ctx).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.daysOfWeek[i],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: sel ? Colors.white : null,
                            ),
                          ),
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
                    child: _timePicker(ctx, 'وقت الانتهاء', endTime, (t) => setS(() => endTime = t)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timePicker(ctx, 'وقت البدء', startTime, (t) => setS(() => startTime = t)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _schedules.add({
                        'day': selectedDay,
                        'start': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                        'end': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                      });
                    });
                    Navigator.pop(ctx);
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

  Widget _timePicker(
    BuildContext ctx,
    String label,
    TimeOfDay time,
    void Function(TimeOfDay) onPicked,
  ) {
    final theme = Theme.of(ctx);
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: ctx, initialTime: time);
        if (picked != null) onPicked(picked);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: theme.dividerColor),
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
