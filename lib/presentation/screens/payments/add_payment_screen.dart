import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/models.dart';
import '../../widgets/common_widgets.dart';

class AddPaymentScreen extends StatefulWidget {
  final int? studentId;
  final String? studentName;

  const AddPaymentScreen({super.key, this.studentId, this.studentName});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  List<StudentModel> _students = [];
  int? _selectedStudentId;
  String _type = 'subscription';
  DateTime _date = DateTime.now();
  bool _saving = false;
  List<ExtraFeeModel> _extraFees = [];
  String? _selectedExtraFeeName;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _db.getStudents();
    setState(() => _students = students);

    if (_selectedStudentId != null) {
      _loadExtraFees(_selectedStudentId!);
    }
  }

  Future<void> _loadExtraFees(int studentId) async {
    final student = _students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => _students.first);
    if (student.groupId != null) {
      final fees = await _db.getExtraFees(student.groupId!);
      setState(() => _extraFees = fees);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      _showErr('اختر الطالب أولاً');
      return;
    }
    setState(() => _saving = true);

    final payment = PaymentModel(
      studentId: _selectedStudentId!,
      type: _type,
      amount: double.parse(_amountCtrl.text.trim()),
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      extraFeeName: _type == 'extra_fee' ? _selectedExtraFeeName : null,
      date: _date,
    );

    await _db.insertPayment(payment);
    if (mounted) Navigator.pop(context);
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.right),
          backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل دفعة مالية'),
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
            // Student selector
            if (widget.studentId == null) ...[
              AppDropdown<int>(
                label: 'الطالب *',
                value: _selectedStudentId,
                items: _students.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text('${s.name} (${s.code})'),
                )).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedStudentId = v;
                    _extraFees = [];
                    _selectedExtraFeeName = null;
                  });
                  if (v != null) _loadExtraFees(v);
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.studentName ?? '',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    const Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],

            // Payment type
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('نوع الدفعة',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _typeBtn('خصم', 'discount', AppColors.error),
                    const SizedBox(width: 8),
                    _typeBtn('رسوم إضافية', 'extra_fee', AppColors.warning),
                    const SizedBox(width: 8),
                    _typeBtn('اشتراك شهري', 'subscription', AppColors.success),
                  ].reversed.toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Extra fee selector
            if (_type == 'extra_fee' && _extraFees.isNotEmpty) ...[
              AppDropdown<String>(
                label: 'نوع الرسوم',
                value: _selectedExtraFeeName,
                items: [
                  const DropdownMenuItem(value: null, child: Text('مخصص')),
                  ..._extraFees.map((f) => DropdownMenuItem(
                    value: f.name,
                    child: Text('${f.name} (${f.amount.toStringAsFixed(0)} ج.م)'),
                  )),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedExtraFeeName = v;
                    if (v != null) {
                      final fee = _extraFees.firstWhere((f) => f.name == v);
                      _amountCtrl.text = fee.amount.toStringAsFixed(0);
                    }
                  });
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
            ],

            // Amount
            AppTextField(
              label: 'المبلغ (ج.م) *',
              hint: '0',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty == true) return 'المبلغ مطلوب';
                if (double.tryParse(v!.trim()) == null) return 'رقم غير صحيح';
                if (double.parse(v.trim()) <= 0) return 'المبلغ يجب أن يكون أكبر من صفر';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Description
            AppTextField(
              label: 'وصف (اختياري)',
              hint: 'مثال: اشتراك شهر أكتوبر',
              controller: _descCtrl,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Date
            GestureDetector(
              onTap: _pickDate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('تاريخ الدفع',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Container(
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
                          '${_date.year}/${_date.month}/${_date.day}',
                          style: const TextStyle(
                              fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
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
                    : const Text('تسجيل الدفعة'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String label, String value, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: selected ? color : Theme.of(context).dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: selected ? color : null)),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }
}
