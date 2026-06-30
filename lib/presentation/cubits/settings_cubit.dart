import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database/database_service.dart';
import '../../data/models/models.dart';

class SettingsCubit extends Cubit<SettingsModel> {
  final DatabaseService _db;

  SettingsCubit(this._db) : super(SettingsModel());

  Future<void> load() async {
    final settings = await _db.getSettings();
    emit(settings);
  }

  Future<void> update(SettingsModel s) async {
    await _db.saveSettings(s);
    emit(s);
  }

  Future<void> toggleDarkMode() async {
    final updated = state.copyWith(isDarkMode: !state.isDarkMode);
    await _db.saveSettings(updated);
    emit(updated);
  }
}
