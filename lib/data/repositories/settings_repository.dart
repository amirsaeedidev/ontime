import '../mock/app_database.dart';
import '../models/business_settings.dart';

abstract class SettingsRepository {
  Future<BusinessSettings> fetchSettings();

  Future<void> saveSettings(BusinessSettings settings, {String? logTitle, String? logDescription});
}

class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<BusinessSettings> fetchSettings() async {
    await _db.delay(120);
    return _db.settings;
  }

  @override
  Future<void> saveSettings(BusinessSettings settings, {String? logTitle, String? logDescription}) async {
    await _db.delay(240);
    _db.updateSettings(settings, logTitle: logTitle, logDescription: logDescription);
  }
}
