// ==================== GRADE ====================
class GradeModel {
  final int? id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  GradeModel({
    this.id,
    required this.name,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
      };

  factory GradeModel.fromMap(Map<String, dynamic> m) => GradeModel(
        id: m['id'],
        name: m['name'],
        sortOrder: m['sort_order'] ?? 0,
        createdAt: DateTime.parse(m['created_at']),
      );

  GradeModel copyWith({int? id, String? name, int? sortOrder}) => GradeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
      );
}

// ==================== GROUP ====================
class GroupModel {
  final int? id;
  final int gradeId;
  final String name;
  final int colorIndex;
  final double monthlyFee;
  final String? notes;
  final String? location;
  final DateTime createdAt;

  GroupModel({
    this.id,
    required this.gradeId,
    required this.name,
    this.colorIndex = 0,
    this.monthlyFee = 0,
    this.notes,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'grade_id': gradeId,
        'name': name,
        'color_index': colorIndex,
        'monthly_fee': monthlyFee,
        'notes': notes,
        'location': location,
        'created_at': createdAt.toIso8601String(),
      };

  factory GroupModel.fromMap(Map<String, dynamic> m) => GroupModel(
        id: m['id'],
        gradeId: m['grade_id'],
        name: m['name'],
        colorIndex: m['color_index'] ?? 0,
        monthlyFee: (m['monthly_fee'] as num?)?.toDouble() ?? 0,
        notes: m['notes'],
        location: m['location'],
        createdAt: DateTime.parse(m['created_at']),
      );

  GroupModel copyWith({
    int? id,
    int? gradeId,
    String? name,
    int? colorIndex,
    double? monthlyFee,
    String? notes,
    String? location,
  }) =>
      GroupModel(
        id: id ?? this.id,
        gradeId: gradeId ?? this.gradeId,
        name: name ?? this.name,
        colorIndex: colorIndex ?? this.colorIndex,
        monthlyFee: monthlyFee ?? this.monthlyFee,
        notes: notes ?? this.notes,
        location: location ?? this.location,
        createdAt: createdAt,
      );
}

// ==================== SCHEDULE ====================
class ScheduleModel {
  final int? id;
  final int groupId;
  final int dayOfWeek; // 0=Sat .. 6=Fri
  final String startTime; // HH:mm
  final String endTime;
  final String? location;

  ScheduleModel({
    this.id,
    required this.groupId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'group_id': groupId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'location': location,
      };

  factory ScheduleModel.fromMap(Map<String, dynamic> m) => ScheduleModel(
        id: m['id'],
        groupId: m['group_id'],
        dayOfWeek: m['day_of_week'],
        startTime: m['start_time'],
        endTime: m['end_time'],
        location: m['location'],
      );
}

// ==================== STUDENT ====================
class StudentModel {
  final int? id;
  final String code;
  final String name;
  final String phone;
  final String? parentPhone;
  final String? address;
  final String? school;
  final int gradeId;
  final int? groupId;
  final String gender; // male / female
  final DateTime? birthDate;
  final String? notes;
  final String? photoPath;
  final String status; // active, paused, withdrawn, deferred, graduated, archived
  final DateTime enrollDate;
  final int sortPosition;
  final DateTime createdAt;

  StudentModel({
    this.id,
    required this.code,
    required this.name,
    required this.phone,
    this.parentPhone,
    this.address,
    this.school,
    required this.gradeId,
    this.groupId,
    this.gender = 'male',
    this.birthDate,
    this.notes,
    this.photoPath,
    this.status = 'active',
    DateTime? enrollDate,
    this.sortPosition = 0,
    DateTime? createdAt,
  })  : enrollDate = enrollDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'code': code,
        'name': name,
        'phone': phone,
        'parent_phone': parentPhone,
        'address': address,
        'school': school,
        'grade_id': gradeId,
        'group_id': groupId,
        'gender': gender,
        'birth_date': birthDate?.toIso8601String(),
        'notes': notes,
        'photo_path': photoPath,
        'status': status,
        'enroll_date': enrollDate.toIso8601String(),
        'sort_position': sortPosition,
        'created_at': createdAt.toIso8601String(),
      };

  factory StudentModel.fromMap(Map<String, dynamic> m) => StudentModel(
        id: m['id'],
        code: m['code'],
        name: m['name'],
        phone: m['phone'],
        parentPhone: m['parent_phone'],
        address: m['address'],
        school: m['school'],
        gradeId: m['grade_id'],
        groupId: m['group_id'],
        gender: m['gender'] ?? 'male',
        birthDate: m['birth_date'] != null ? DateTime.parse(m['birth_date']) : null,
        notes: m['notes'],
        photoPath: m['photo_path'],
        status: m['status'] ?? 'active',
        enrollDate: DateTime.parse(m['enroll_date']),
        sortPosition: m['sort_position'] ?? 0,
        createdAt: DateTime.parse(m['created_at']),
      );

  StudentModel copyWith({
    int? id,
    String? code,
    String? name,
    String? phone,
    String? parentPhone,
    String? address,
    String? school,
    int? gradeId,
    int? groupId,
    String? gender,
    DateTime? birthDate,
    String? notes,
    String? photoPath,
    String? status,
    DateTime? enrollDate,
    int? sortPosition,
  }) =>
      StudentModel(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        parentPhone: parentPhone ?? this.parentPhone,
        address: address ?? this.address,
        school: school ?? this.school,
        gradeId: gradeId ?? this.gradeId,
        groupId: groupId ?? this.groupId,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        notes: notes ?? this.notes,
        photoPath: photoPath ?? this.photoPath,
        status: status ?? this.status,
        enrollDate: enrollDate ?? this.enrollDate,
        sortPosition: sortPosition ?? this.sortPosition,
        createdAt: createdAt,
      );
}

// ==================== STUDENT NOTE ====================
class StudentNoteModel {
  final int? id;
  final int studentId;
  final String text;
  final DateTime createdAt;

  StudentNoteModel({
    this.id,
    required this.studentId,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'student_id': studentId,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };

  factory StudentNoteModel.fromMap(Map<String, dynamic> m) => StudentNoteModel(
        id: m['id'],
        studentId: m['student_id'],
        text: m['text'],
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== ATTENDANCE ====================
class AttendanceModel {
  final int? id;
  final int studentId;
  final int groupId;
  final DateTime date;
  final String status; // present, absent, late, excused
  final String? notes;

  AttendanceModel({
    this.id,
    required this.studentId,
    required this.groupId,
    required this.date,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'student_id': studentId,
        'group_id': groupId,
        'date': date.toIso8601String().split('T').first,
        'status': status,
        'notes': notes,
      };

  factory AttendanceModel.fromMap(Map<String, dynamic> m) => AttendanceModel(
        id: m['id'],
        studentId: m['student_id'],
        groupId: m['group_id'],
        date: DateTime.parse(m['date']),
        status: m['status'],
        notes: m['notes'],
      );
}

// ==================== EXAM ====================
class ExamModel {
  final int? id;
  final int groupId;
  final String name;
  final DateTime date;
  final double totalScore;
  final String? curriculum;
  final String? notes;
  final DateTime createdAt;

  ExamModel({
    this.id,
    required this.groupId,
    required this.name,
    required this.date,
    this.totalScore = 100,
    this.curriculum,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'group_id': groupId,
        'name': name,
        'date': date.toIso8601String().split('T').first,
        'total_score': totalScore,
        'curriculum': curriculum,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExamModel.fromMap(Map<String, dynamic> m) => ExamModel(
        id: m['id'],
        groupId: m['group_id'],
        name: m['name'],
        date: DateTime.parse(m['date']),
        totalScore: (m['total_score'] as num?)?.toDouble() ?? 100,
        curriculum: m['curriculum'],
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== EXAM RESULT ====================
class ExamResultModel {
  final int? id;
  final int examId;
  final int studentId;
  final double? score;
  final String? notes;
  final DateTime createdAt;

  ExamResultModel({
    this.id,
    required this.examId,
    required this.studentId,
    this.score,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'exam_id': examId,
        'student_id': studentId,
        'score': score,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExamResultModel.fromMap(Map<String, dynamic> m) => ExamResultModel(
        id: m['id'],
        examId: m['exam_id'],
        studentId: m['student_id'],
        score: (m['score'] as num?)?.toDouble(),
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== EXAM ATTACHMENT ====================
class ExamAttachmentModel {
  final int? id;
  final int examResultId;
  final String filePath;
  final DateTime createdAt;

  ExamAttachmentModel({
    this.id,
    required this.examResultId,
    required this.filePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'exam_result_id': examResultId,
        'file_path': filePath,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExamAttachmentModel.fromMap(Map<String, dynamic> m) =>
      ExamAttachmentModel(
        id: m['id'],
        examResultId: m['exam_result_id'],
        filePath: m['file_path'],
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== EXTRA FEE ====================
class ExtraFeeModel {
  final int? id;
  final int groupId;
  final String name;
  final double amount;
  final DateTime createdAt;

  ExtraFeeModel({
    this.id,
    required this.groupId,
    required this.name,
    required this.amount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'group_id': groupId,
        'name': name,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExtraFeeModel.fromMap(Map<String, dynamic> m) => ExtraFeeModel(
        id: m['id'],
        groupId: m['group_id'],
        name: m['name'],
        amount: (m['amount'] as num).toDouble(),
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== PAYMENT ====================
class PaymentModel {
  final int? id;
  final int studentId;
  final String type; // subscription, extra_fee, discount
  final double amount;
  final String? description;
  final String? extraFeeName;
  final DateTime date;
  final DateTime createdAt;

  PaymentModel({
    this.id,
    required this.studentId,
    required this.type,
    required this.amount,
    this.description,
    this.extraFeeName,
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'student_id': studentId,
        'type': type,
        'amount': amount,
        'description': description,
        'extra_fee_name': extraFeeName,
        'date': date.toIso8601String().split('T').first,
        'created_at': createdAt.toIso8601String(),
      };

  factory PaymentModel.fromMap(Map<String, dynamic> m) => PaymentModel(
        id: m['id'],
        studentId: m['student_id'],
        type: m['type'],
        amount: (m['amount'] as num).toDouble(),
        description: m['description'],
        extraFeeName: m['extra_fee_name'],
        date: DateTime.parse(m['date']),
        createdAt: DateTime.parse(m['created_at']),
      );
}

// ==================== RESERVATION ====================
class ReservationModel {
  final int? id;
  final String studentName;
  final String phone;
  final String? parentPhone;
  final int gradeId;
  final String studyType; // general, azhari, baccalaureate
  final String semester; // first, second
  final String status; // new, contacted, registered, cancelled
  final String? notes;
  final DateTime createdAt;

  ReservationModel({
    this.id,
    required this.studentName,
    required this.phone,
    this.parentPhone,
    required this.gradeId,
    this.studyType = 'general',
    this.semester = 'first',
    this.status = 'new',
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'student_name': studentName,
        'phone': phone,
        'parent_phone': parentPhone,
        'grade_id': gradeId,
        'study_type': studyType,
        'semester': semester,
        'status': status,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory ReservationModel.fromMap(Map<String, dynamic> m) => ReservationModel(
        id: m['id'],
        studentName: m['student_name'],
        phone: m['phone'],
        parentPhone: m['parent_phone'],
        gradeId: m['grade_id'],
        studyType: m['study_type'] ?? 'general',
        semester: m['semester'] ?? 'first',
        status: m['status'] ?? 'new',
        notes: m['notes'],
        createdAt: DateTime.parse(m['created_at']),
      );

  ReservationModel copyWith({String? status, String? notes}) => ReservationModel(
        id: id,
        studentName: studentName,
        phone: phone,
        parentPhone: parentPhone,
        gradeId: gradeId,
        studyType: studyType,
        semester: semester,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}

// ==================== GENERAL NOTE ====================
class GeneralNoteModel {
  final int? id;
  final String title;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  GeneralNoteModel({
    this.id,
    required this.title,
    required this.text,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'text': text,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory GeneralNoteModel.fromMap(Map<String, dynamic> m) => GeneralNoteModel(
        id: m['id'],
        title: m['title'],
        text: m['text'],
        createdAt: DateTime.parse(m['created_at']),
        updatedAt: DateTime.parse(m['updated_at']),
      );
}

// ==================== SETTINGS ====================
class SettingsModel {
  final String teacherName;
  final String? teacherPhone;
  final String? centerName;
  final String? centerLogoPath;
  final bool isDarkMode;
  final int primaryColorIndex;
  final double fontSize; // 1.0 = normal
  final bool pinEnabled;
  final String? pinCode;

  SettingsModel({
    this.teacherName = 'أستاذ',
    this.teacherPhone,
    this.centerName,
    this.centerLogoPath,
    this.isDarkMode = false,
    this.primaryColorIndex = 0,
    this.fontSize = 1.0,
    this.pinEnabled = false,
    this.pinCode,
  });

  Map<String, dynamic> toMap() => {
        'teacher_name': teacherName,
        'teacher_phone': teacherPhone,
        'center_name': centerName,
        'center_logo_path': centerLogoPath,
        'is_dark_mode': isDarkMode ? 1 : 0,
        'primary_color_index': primaryColorIndex,
        'font_size': fontSize,
        'pin_enabled': pinEnabled ? 1 : 0,
        'pin_code': pinCode,
      };

  factory SettingsModel.fromMap(Map<String, dynamic> m) => SettingsModel(
        teacherName: m['teacher_name'] ?? 'أستاذ',
        teacherPhone: m['teacher_phone'],
        centerName: m['center_name'],
        centerLogoPath: m['center_logo_path'],
        isDarkMode: (m['is_dark_mode'] ?? 0) == 1,
        primaryColorIndex: m['primary_color_index'] ?? 0,
        fontSize: (m['font_size'] as num?)?.toDouble() ?? 1.0,
        pinEnabled: (m['pin_enabled'] ?? 0) == 1,
        pinCode: m['pin_code'],
      );

  SettingsModel copyWith({
    String? teacherName,
    String? teacherPhone,
    String? centerName,
    String? centerLogoPath,
    bool? isDarkMode,
    int? primaryColorIndex,
    double? fontSize,
    bool? pinEnabled,
    String? pinCode,
  }) =>
      SettingsModel(
        teacherName: teacherName ?? this.teacherName,
        teacherPhone: teacherPhone ?? this.teacherPhone,
        centerName: centerName ?? this.centerName,
        centerLogoPath: centerLogoPath ?? this.centerLogoPath,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        primaryColorIndex: primaryColorIndex ?? this.primaryColorIndex,
        fontSize: fontSize ?? this.fontSize,
        pinEnabled: pinEnabled ?? this.pinEnabled,
        pinCode: pinCode ?? this.pinCode,
      );
}
