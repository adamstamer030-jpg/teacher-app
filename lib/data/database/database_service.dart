import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;
  static const int _version = 1;
  static const String _dbName = 'teacher_app.db';

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grade_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color_index INTEGER DEFAULT 0,
        monthly_fee REAL DEFAULT 0,
        notes TEXT,
        location TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (grade_id) REFERENCES grades(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        location TEXT,
        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        parent_phone TEXT,
        address TEXT,
        school TEXT,
        grade_id INTEGER NOT NULL,
        group_id INTEGER,
        gender TEXT DEFAULT 'male',
        birth_date TEXT,
        notes TEXT,
        photo_path TEXT,
        status TEXT DEFAULT 'active',
        enroll_date TEXT NOT NULL,
        sort_position INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (grade_id) REFERENCES grades(id),
        FOREIGN KEY (group_id) REFERENCES groups(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_students_phone ON students(phone)');
    await db.execute('CREATE INDEX idx_students_group ON students(group_id)');
    await db.execute('CREATE INDEX idx_students_status ON students(status)');

    await db.execute('''
      CREATE TABLE student_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        group_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
        UNIQUE(student_id, group_id, date)
      )
    ''');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');

    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        total_score REAL DEFAULT 100,
        curriculum TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        score REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        UNIQUE(exam_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE exam_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_result_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (exam_result_id) REFERENCES exam_results(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE extra_fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        extra_fee_name TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_payments_student ON payments(student_id)');
    await db.execute('CREATE INDEX idx_payments_date ON payments(date)');

    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        parent_phone TEXT,
        grade_id INTEGER NOT NULL,
        study_type TEXT DEFAULT 'general',
        semester TEXT DEFAULT 'first',
        status TEXT DEFAULT 'new',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (grade_id) REFERENCES grades(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE general_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        teacher_name TEXT DEFAULT 'أستاذ',
        teacher_phone TEXT,
        center_name TEXT,
        center_logo_path TEXT,
        is_dark_mode INTEGER DEFAULT 0,
        primary_color_index INTEGER DEFAULT 0,
        font_size REAL DEFAULT 1.0,
        pin_enabled INTEGER DEFAULT 0,
        pin_code TEXT
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'id': 1, 'teacher_name': 'أستاذ', 'is_dark_mode': 0});

    // Insert default grades
    final grades = [
      'أولى إعدادي', 'ثانية إعدادي', 'ثالثة إعدادي',
      'أولى ثانوي', 'ثانية ثانوي', 'ثالثة ثانوي',
    ];
    for (int i = 0; i < grades.length; i++) {
      await db.insert('grades', {
        'name': grades[i],
        'sort_order': i,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ================== GRADES ==================
  Future<List<GradeModel>> getGrades() async {
    final d = await db;
    final rows = await d.query('grades', orderBy: 'sort_order ASC');
    return rows.map(GradeModel.fromMap).toList();
  }

  Future<int> insertGrade(GradeModel g) async {
    return (await db).insert('grades', g.toMap());
  }

  Future<void> updateGrade(GradeModel g) async {
    await (await db).update('grades', g.toMap(), where: 'id=?', whereArgs: [g.id]);
  }

  Future<void> deleteGrade(int id) async {
    await (await db).delete('grades', where: 'id=?', whereArgs: [id]);
  }

  // ================== GROUPS ==================
  Future<List<GroupModel>> getGroups({int? gradeId}) async {
    final d = await db;
    final rows = gradeId != null
        ? await d.query('groups', where: 'grade_id=?', whereArgs: [gradeId], orderBy: 'created_at ASC')
        : await d.query('groups', orderBy: 'created_at ASC');
    return rows.map(GroupModel.fromMap).toList();
  }

  Future<int> insertGroup(GroupModel g) async {
    return (await db).insert('groups', g.toMap());
  }

  Future<void> updateGroup(GroupModel g) async {
    await (await db).update('groups', g.toMap(), where: 'id=?', whereArgs: [g.id]);
  }

  Future<void> deleteGroup(int id) async {
    await (await db).delete('groups', where: 'id=?', whereArgs: [id]);
  }

  Future<int> getGroupStudentCount(int groupId) async {
    final d = await db;
    final result = await d.rawQuery(
        "SELECT COUNT(*) as cnt FROM students WHERE group_id=? AND status NOT IN ('archived','graduated')",
        [groupId]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ================== SCHEDULES ==================
  Future<List<ScheduleModel>> getSchedules({int? groupId}) async {
    final d = await db;
    final rows = groupId != null
        ? await d.query('schedules', where: 'group_id=?', whereArgs: [groupId], orderBy: 'day_of_week ASC')
        : await d.query('schedules', orderBy: 'day_of_week ASC, start_time ASC');
    return rows.map(ScheduleModel.fromMap).toList();
  }

  Future<int> insertSchedule(ScheduleModel s) async {
    return (await db).insert('schedules', s.toMap());
  }

  Future<void> deleteSchedulesByGroup(int groupId) async {
    await (await db).delete('schedules', where: 'group_id=?', whereArgs: [groupId]);
  }

  Future<void> deleteSchedule(int id) async {
    await (await db).delete('schedules', where: 'id=?', whereArgs: [id]);
  }

  // ================== STUDENTS ==================
  Future<String> generateStudentCode() async {
    final d = await db;
    final result = await d.rawQuery('SELECT MAX(CAST(code AS INTEGER)) as maxcode FROM students');
    final maxCode = (result.first['maxcode'] as int?) ?? 0;
    return (maxCode + 1).toString();
  }

  Future<bool> isPhoneDuplicate(String phone, {int? excludeId}) async {
    final d = await db;
    final rows = excludeId != null
        ? await d.query('students', where: 'phone=? AND id!=?', whereArgs: [phone, excludeId])
        : await d.query('students', where: 'phone=?', whereArgs: [phone]);
    return rows.isNotEmpty;
  }

  Future<List<StudentModel>> getStudents({
    int? groupId,
    int? gradeId,
    String? status,
    String? sortBy, // enroll_date, name, code, sort_position
  }) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (groupId != null) {
      where = 'group_id=?';
      whereArgs = [groupId];
    } else if (gradeId != null) {
      where = 'grade_id=?';
      whereArgs = [gradeId];
    }

    if (status != null) {
      where = where != null ? '$where AND status=?' : 'status=?';
      whereArgs = whereArgs != null ? [...whereArgs, status] : [status];
    } else {
      // Default: exclude archived
      where = where != null ? "$where AND status!='archived'" : "status!='archived'";
    }

    final orderBy = switch (sortBy) {
      'name' => 'name ASC',
      'code' => 'CAST(code AS INTEGER) ASC',
      'sort_position' => 'sort_position ASC, enroll_date ASC',
      _ => 'enroll_date ASC',
    };

    final rows = await d.query('students', where: where, whereArgs: whereArgs, orderBy: orderBy);
    return rows.map(StudentModel.fromMap).toList();
  }

  Future<StudentModel?> getStudent(int id) async {
    final d = await db;
    final rows = await d.query('students', where: 'id=?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return StudentModel.fromMap(rows.first);
  }

  Future<List<StudentModel>> searchStudents(String query) async {
    final d = await db;
    final q = '%$query%';
    final rows = await d.rawQuery(
      "SELECT * FROM students WHERE (name LIKE ? OR code LIKE ? OR phone LIKE ? OR parent_phone LIKE ?) AND status!='archived' ORDER BY name ASC",
      [q, q, q, q],
    );
    return rows.map(StudentModel.fromMap).toList();
  }

  Future<int> insertStudent(StudentModel s) async {
    return (await db).insert('students', s.toMap());
  }

  Future<void> updateStudent(StudentModel s) async {
    await (await db).update('students', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  }

  Future<void> deleteStudent(int id) async {
    await (await db).delete('students', where: 'id=?', whereArgs: [id]);
  }

  Future<int> getTotalStudentsCount() async {
    final d = await db;
    final result = await d.rawQuery("SELECT COUNT(*) as cnt FROM students WHERE status NOT IN ('archived','graduated')");
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<int> getLatePayersCount() async {
    final d = await db;
    final now = DateTime.now();
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final result = await d.rawQuery('''
      SELECT COUNT(DISTINCT s.id) as cnt FROM students s
      LEFT JOIN payments p ON p.student_id=s.id AND p.type='subscription' AND p.date >= ?
      WHERE s.status='active' AND p.id IS NULL
    ''', [monthStart]);
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ================== STUDENT NOTES ==================
  Future<List<StudentNoteModel>> getStudentNotes(int studentId) async {
    final d = await db;
    final rows = await d.query('student_notes',
        where: 'student_id=?', whereArgs: [studentId], orderBy: 'created_at DESC');
    return rows.map(StudentNoteModel.fromMap).toList();
  }

  Future<int> insertStudentNote(StudentNoteModel n) async {
    return (await db).insert('student_notes', n.toMap());
  }

  Future<void> updateStudentNote(StudentNoteModel n) async {
    await (await db).update('student_notes', n.toMap(), where: 'id=?', whereArgs: [n.id]);
  }

  Future<void> deleteStudentNote(int id) async {
    await (await db).delete('student_notes', where: 'id=?', whereArgs: [id]);
  }

  // ================== ATTENDANCE ==================
  Future<List<AttendanceModel>> getAttendance({int? groupId, String? date}) async {
    final d = await db;
    String? where;
    List<dynamic>? args;
    if (groupId != null && date != null) {
      where = 'group_id=? AND date=?';
      args = [groupId, date];
    } else if (groupId != null) {
      where = 'group_id=?';
      args = [groupId];
    }
    final rows = await d.query('attendance', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map(AttendanceModel.fromMap).toList();
  }

  Future<void> saveAttendance(AttendanceModel a) async {
    final d = await db;
    await d.insert('attendance', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ================== EXAMS ==================
  Future<List<ExamModel>> getExams({int? groupId}) async {
    final d = await db;
    final rows = groupId != null
        ? await d.query('exams', where: 'group_id=?', whereArgs: [groupId], orderBy: 'date DESC')
        : await d.query('exams', orderBy: 'date DESC');
    return rows.map(ExamModel.fromMap).toList();
  }

  Future<int> insertExam(ExamModel e) async {
    return (await db).insert('exams', e.toMap());
  }

  Future<void> updateExam(ExamModel e) async {
    await (await db).update('exams', e.toMap(), where: 'id=?', whereArgs: [e.id]);
  }

  Future<void> deleteExam(int id) async {
    await (await db).delete('exams', where: 'id=?', whereArgs: [id]);
  }

  Future<int> getTotalExamsCount() async {
    final d = await db;
    final result = await d.rawQuery('SELECT COUNT(*) as cnt FROM exams');
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ================== EXAM RESULTS ==================
  Future<List<ExamResultModel>> getExamResults(int examId) async {
    final d = await db;
    final rows = await d.query('exam_results', where: 'exam_id=?', whereArgs: [examId]);
    return rows.map(ExamResultModel.fromMap).toList();
  }

  Future<List<ExamResultModel>> getStudentExamResults(int studentId) async {
    final d = await db;
    final rows = await d.rawQuery(
        'SELECT er.* FROM exam_results er JOIN exams e ON e.id=er.exam_id WHERE er.student_id=? ORDER BY e.date DESC',
        [studentId]);
    return rows.map(ExamResultModel.fromMap).toList();
  }

  Future<void> saveExamResult(ExamResultModel r) async {
    await (await db).insert('exam_results', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ================== EXAM ATTACHMENTS ==================
  Future<List<ExamAttachmentModel>> getExamAttachments(int examResultId) async {
    final d = await db;
    final rows = await d.query('exam_attachments',
        where: 'exam_result_id=?', whereArgs: [examResultId], orderBy: 'created_at ASC');
    return rows.map(ExamAttachmentModel.fromMap).toList();
  }

  Future<int> insertExamAttachment(ExamAttachmentModel a) async {
    return (await db).insert('exam_attachments', a.toMap());
  }

  Future<void> deleteExamAttachment(int id) async {
    await (await db).delete('exam_attachments', where: 'id=?', whereArgs: [id]);
  }

  // ================== EXTRA FEES ==================
  Future<List<ExtraFeeModel>> getExtraFees(int groupId) async {
    final d = await db;
    final rows = await d.query('extra_fees', where: 'group_id=?', whereArgs: [groupId]);
    return rows.map(ExtraFeeModel.fromMap).toList();
  }

  Future<int> insertExtraFee(ExtraFeeModel f) async {
    return (await db).insert('extra_fees', f.toMap());
  }

  Future<void> deleteExtraFee(int id) async {
    await (await db).delete('extra_fees', where: 'id=?', whereArgs: [id]);
  }

  // ================== PAYMENTS ==================
  Future<List<PaymentModel>> getPayments({int? studentId, String? fromDate, String? toDate}) async {
    final d = await db;
    String where = '1=1';
    List<dynamic> args = [];
    if (studentId != null) { where += ' AND student_id=?'; args.add(studentId); }
    if (fromDate != null) { where += ' AND date>=?'; args.add(fromDate); }
    if (toDate != null) { where += ' AND date<=?'; args.add(toDate); }
    final rows = await d.query('payments', where: where, whereArgs: args, orderBy: 'date DESC, created_at DESC');
    return rows.map(PaymentModel.fromMap).toList();
  }

  Future<double> getTotalPayments({String? fromDate, String? toDate}) async {
    final d = await db;
    String where = "type != 'discount'";
    List<dynamic> args = [];
    if (fromDate != null) { where += ' AND date>=?'; args.add(fromDate); }
    if (toDate != null) { where += ' AND date<=?'; args.add(toDate); }
    final result = await d.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE $where', args);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> insertPayment(PaymentModel p) async {
    return (await db).insert('payments', p.toMap());
  }

  Future<void> deletePayment(int id) async {
    await (await db).delete('payments', where: 'id=?', whereArgs: [id]);
  }

  // ================== RESERVATIONS ==================
  Future<List<ReservationModel>> getReservations({String? status}) async {
    final d = await db;
    final rows = status != null
        ? await d.query('reservations', where: 'status=?', whereArgs: [status], orderBy: 'created_at DESC')
        : await d.query('reservations', orderBy: 'created_at DESC');
    return rows.map(ReservationModel.fromMap).toList();
  }

  Future<int> insertReservation(ReservationModel r) async {
    return (await db).insert('reservations', r.toMap());
  }

  Future<void> updateReservation(ReservationModel r) async {
    await (await db).update('reservations', r.toMap(), where: 'id=?', whereArgs: [r.id]);
  }

  Future<void> deleteReservation(int id) async {
    await (await db).delete('reservations', where: 'id=?', whereArgs: [id]);
  }

  Future<int> getReservationsCount() async {
    final d = await db;
    final result = await d.rawQuery("SELECT COUNT(*) as cnt FROM reservations WHERE status!='cancelled'");
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ================== GENERAL NOTES ==================
  Future<List<GeneralNoteModel>> getGeneralNotes() async {
    final d = await db;
    final rows = await d.query('general_notes', orderBy: 'updated_at DESC');
    return rows.map(GeneralNoteModel.fromMap).toList();
  }

  Future<int> insertGeneralNote(GeneralNoteModel n) async {
    return (await db).insert('general_notes', n.toMap());
  }

  Future<void> updateGeneralNote(GeneralNoteModel n) async {
    await (await db).update('general_notes', n.toMap(), where: 'id=?', whereArgs: [n.id]);
  }

  Future<void> deleteGeneralNote(int id) async {
    await (await db).delete('general_notes', where: 'id=?', whereArgs: [id]);
  }

  // ================== SETTINGS ==================
  Future<SettingsModel> getSettings() async {
    final d = await db;
    final rows = await d.query('settings', where: 'id=1');
    if (rows.isEmpty) return SettingsModel();
    return SettingsModel.fromMap(rows.first);
  }

  Future<void> saveSettings(SettingsModel s) async {
    final d = await db;
    final map = s.toMap();
    map['id'] = 1;
    await d.insert('settings', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ================== DASHBOARD STATS ==================
  Future<Map<String, dynamic>> getDashboardStats() async {
    final d = await db;
    final now = DateTime.now();
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    final students = await d.rawQuery(
        "SELECT COUNT(*) as cnt FROM students WHERE status NOT IN ('archived','graduated')");
    final grades = await d.rawQuery('SELECT COUNT(*) as cnt FROM grades');
    final groups = await d.rawQuery('SELECT COUNT(*) as cnt FROM groups');
    final exams = await d.rawQuery('SELECT COUNT(*) as cnt FROM exams');
    final reservations = await d.rawQuery(
        "SELECT COUNT(*) as cnt FROM reservations WHERE status!='cancelled'");
    final monthPayments = await d.rawQuery(
        "SELECT SUM(amount) as total FROM payments WHERE type!='discount' AND date>=?",
        [monthStart]);
    final latePayersResult = await d.rawQuery('''
      SELECT COUNT(DISTINCT s.id) as cnt FROM students s
      LEFT JOIN payments p ON p.student_id=s.id AND p.type='subscription' AND p.date >= ?
      WHERE s.status='active' AND p.id IS NULL
    ''', [monthStart]);

    // Today's schedule
    final todayDayIndex = (now.weekday + 1) % 7; // Convert dart weekday to 0=Sat
    final todaySchedules = await d.rawQuery('''
      SELECT sc.*, g.name as group_name FROM schedules sc
      JOIN groups g ON g.id=sc.group_id
      WHERE sc.day_of_week=?
      ORDER BY sc.start_time ASC
    ''', [todayDayIndex]);

    return {
      'students': (students.first['cnt'] as int?) ?? 0,
      'grades': (grades.first['cnt'] as int?) ?? 0,
      'groups': (groups.first['cnt'] as int?) ?? 0,
      'exams': (exams.first['cnt'] as int?) ?? 0,
      'reservations': (reservations.first['cnt'] as int?) ?? 0,
      'month_payments': (monthPayments.first['total'] as num?)?.toDouble() ?? 0,
      'late_payers': (latePayersResult.first['cnt'] as int?) ?? 0,
      'today_schedules': todaySchedules,
    };
  }

  // ================== BACKUP / EXPORT ==================
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), _dbName);
  }
}
