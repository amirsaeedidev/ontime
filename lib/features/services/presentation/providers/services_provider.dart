import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/service.dart';
import '../../../../data/repositories/service_repository.dart';

/// مدیریت خدمات.
class ServicesProvider extends DbBoundProvider {
  ServicesProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final ServiceRepository _repository;

  List<Service> _items = const [];
  bool _loading = true;
  String? _loadError;
  String _query = '';
  bool _activeOnly = false;

  List<Service> get items => _items;
  bool get loading => _loading;
  String? get loadError => _loadError;
  String get query => _query;
  bool get activeOnly => _activeOnly;
  List<Service> get activeServices => _items.where((s) => s.isActive).toList();
  int get activeCount => _items.where((s) => s.isActive).length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await _repository.fetchServices(onlyActive: _activeOnly);
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Services] load failed: $error');
    } finally {
      _loading = false;
    }
    notifyListeners();
  }

  @override
  void onDatabaseChanged() {
    _items = db.services;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void setActiveOnly(bool value) {
    _activeOnly = value;
    load();
  }

  List<Service> get filtered {
    final q = _query.trim();
    return _items.where((s) {
      if (_activeOnly && !s.isActive) return false;
      if (q.isEmpty) return true;
      return s.title.contains(q) || s.category.contains(q);
    }).toList();
  }

  Future<Service?> byId(String id) => _repository.findById(id);

  Future<bool> create(Service service) async {
    await _repository.create(service);
    return true;
  }

  Future<bool> update(Service service) async {
    await _repository.update(service);
    return true;
  }

  Future<void> remove(String id) => _repository.delete(id);

  Future<void> toggle(String id, bool active) => _repository.toggle(id, active);

  String nextId() => 'srv-${DateTime.now().millisecondsSinceEpoch}';
}
