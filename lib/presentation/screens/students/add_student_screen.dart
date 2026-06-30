import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';

class AddStudentScreen extends StatefulWidget {
  final int? groupId;
  final StudentModel? student; // for editing

  const AddStudentScreen({super.key, this.groupId, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  List<GradeModel> _grades = [];
  List<GroupModel> _groups = [];
  List<GroupModel> _filteredGroups = [];

  int? _selectedGradeId;
  int? _selectedGroupId;
  String _gender = 'male';
  String _status = 'active';
  DateTime _enrollDate = DateTime.now();
  bool _useCustomDate = false;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final grades = await _db.getGrades();
    final groups = await _db.getGroups();

    if (widget.student != null) {
      final s = widget.student!;
      _nameCtrl.text = s.name;
      _phoneCtrl.text = s.phone;
      _parentPhoneCtrl.text = s.parentPhone ?? '';
      _addressCtrl.text = s.address ?? '';
      _schoolCtrl.text = s.school ?? '';
      _notesCtrl.text = s.notes ?? '';
      _codeCtrl.text = s.code;
      _selectedGradeId = s.gradeId;
      _selectedGroupId = s.groupId;
      _gender = s.gender;
      _status = s.status;
      _enrollDate = s.enrollDate;
    } else {
      final code = await _db.generateStudentCode();
      _codeCtrl.text = code;
      if (widget.groupId != null) _selectedGroupId = widget.groupId;
      if (grades.isNotEmpty) _selectedGradeId = grades.first.id;
    }

    setState(() {
      _grades = grades;
      _groups = groups;
      _filteredGroups = _selectedGradeId != null
          ? groups.where((g) => g.gradeId == _selectedGradeId).toList()
          : groups;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _addressCtrl.dispose();
    _schoolCtrl.dispose();
    _notesCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Check phone duplicate
    final isDuplicate = await _db.isPhoneDuplicate(
        _phoneCtrl.text.trim(),
        excludeId: widget.student?.id);

    if (isDuplicate && mounted) {
      setState(() => _saving = false);
      _showError('رقم الهاتف هذا مسجل لطالب آخر في النظام');
      return;
    }

    final student = StudentModel(
      id: widget.student?.id,
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      parentPhone: _parentPhoneCtrl.text.trim().isNotEmpty ? _parentPhoneCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      school: _schoolCtrl.text.trim().isNotEmpty ? _schoolCtrl.text.trim() : null,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      gradeId: _selectedGradeId ?? _grades.first.id!,
      groupId: _selectedGroupId,
      gender: _gender,
      status: _status,
      enrollDate: _enrollDate,
    );

    if (_isEditing) {
      await _db.updateStudent(student);
    } else {
      await _db.insertStudent(student);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.right), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل بيانات الطالب' : 'إضافة طالب جديد للنظام'),
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
            // Student Code
            AppTextField(
              label: 'كود الطالب',
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty == true ? 'الكود مطلوب' : null,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Name
            AppTextField(
              label: 'اسم الطالب رباعي بالكامل *',
              hint: 'مثال: أحمد محمد جلال',
              controller: _nameCtrl,
              validator: (v) => v?.trim().isEmpty == true ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Phone
            AppTextField(
              label: 'رقم هاتف الطالب *',
              hint: '01xxxxxxxxx',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v?.trim().isEmpty == true) return 'رقم الهاتف مطلوب';
                if (v!.trim().length < 11) return 'رقم غير صحيح';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Parent phone
            AppTextField(
              label: 'رقم هاتف ولي الأمر',
              hint: '01xxxxxxxxx',
              controller: _parentPhoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Gender
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('النوع',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _genderButton('أنثى', 'female', Icons.female_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _genderButton('ذكر', 'male', Icons.male_rounded),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Grade
            if (_grades.isNotEmpty)
              AppDropdown<int>(
                label: 'الصف الدراسي',
                value: _selectedGradeId,
                items: _grades.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedGradeId = v;
                    _filteredGroups = _groups.where((g) => g.gradeId == v).toList();
                    _selectedGroupId = null;
                  });
                },
              ),
            const SizedBox(height: AppSizes.paddingL),

            // Group
            if (_filteredGroups.isNotEmpty)
              AppDropdown<int>(
                label: 'المجموعة المقررة له',
                value: _selectedGroupId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون مجموعة')),
                  ..._filteredGroups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                ],
                onChanged: (v) => setState(() => _selectedGroupId = v),
              ),
            const SizedBox(height: AppSizes.paddingL),

            // Status (edit only)
            if (_isEditing)
              AppDropdown<String>(
                label: 'حالة الطالب',
                value: _status,
                items: AppStrings.studentStatuses.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            if (_isEditing) const SizedBox(height: AppSizes.paddingL),

            // Enroll Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('تاريخ الاشتراك',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (_useCustomDate)
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${_enrollDate.year}/${_enrollDate.month}/${_enrollDate.day}',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_today_rounded, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _useCustomDate,
                      onChanged: (v) => setState(() {
                        _useCustomDate = v;
                        if (!v) _enrollDate = DateTime.now();
                      }),
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      _useCustomDate ? 'تاريخ مخصص' : 'تاريخ اليوم',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // School
            AppTextField(
              label: 'المدرسة',
              controller: _schoolCtrl,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Address
            AppTextField(
              label: 'العنوان',
              controller: _addressCtrl,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Notes
            AppTextField(
              label: 'ملاحظات',
              controller: _notesCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'حفظ التعديلات' : 'حفظ الطالب وتوليد كود تلقائي'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _genderButton(String label, String value, IconData icon) {
    final selected = _gender == value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: selected ? theme.colorScheme.primary : null,
                )),
            const SizedBox(width: 4),
            Icon(icon, size: 18, color: selected ? theme.colorScheme.primary : Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _enrollDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _enrollDate = picked);
  }
}
