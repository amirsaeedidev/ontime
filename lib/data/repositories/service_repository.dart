import '../mock/app_database.dart';
import '../models/service.dart';

abstract class ServiceRepository {
  Future<List<Service>> fetchServices({bool onlyActive = false, String query = ''});

  Future<Service?> findById(String id);

  Future<void> create(Service service);

  Future<void> update(Service service);

  Future<void> delete(String id);

  Future<void> toggle(String id, bool isActive);
}

class MockServiceRepository implements ServiceRepository {
  MockServiceRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Service>> fetchServices({bool onlyActive = false, String query = ''}) async {
    await _db.delay(140);
    final q = query.trim();
    return _db.services
        .where((s) => (!onlyActive || s.isActive) && (q.isEmpty || s.title.contains(q)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<Service?> findById(String id) async => _db.serviceById(id);

  @override
  Future<void> create(Service service) async {
    await _db.delay(220);
    _db.addService(service);
  }

  @override
  Future<void> update(Service service) async {
    await _db.delay(200);
    _db.updateService(service);
  }

  @override
  Future<void> delete(String id) async {
    await _db.delay(180);
    _db.deleteService(id);
  }

  @override
  Future<void> toggle(String id, bool isActive) async {
    await _db.delay(120);
    _db.toggleService(id, isActive);
  }
}
