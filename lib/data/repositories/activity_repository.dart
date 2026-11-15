import '../mock/app_database.dart';
import '../models/activity_log.dart';
import '../models/enums.dart';

abstract class ActivityRepository {
  Future<List<ActivityLog>> fetchLogs({ActivityType? type, String query = '', int limit = 100});

  Future<List<ActivityLog>> fetchRecent({int limit = 6});
}

class MockActivityRepository implements ActivityRepository {
  MockActivityRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<ActivityLog>> fetchLogs({ActivityType? type, String query = '', int limit = 100}) async {
    await _db.delay(140);
    final q = query.trim();
    return _db.activityLogs
        .where((l) {
          if (type != null && l.type != type) return false;
          if (q.isEmpty) return true;
          return l.title.contains(q) || l.description.contains(q) || l.actor.contains(q);
        })
        .take(limit)
        .toList();
  }

  @override
  Future<List<ActivityLog>> fetchRecent({int limit = 6}) async {
    await _db.delay(80);
    return _db.activityLogs.take(limit).toList();
  }
}
