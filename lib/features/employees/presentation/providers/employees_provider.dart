import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/repositories/employee_repository.dart';

/// مدیریت پرسنل و برنامه کاری.
class EmployeesProvider extends DbBoundProvider {
  EmployeesProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final EmployeeRepository _repository;

  List<Employee> _items = const [];
  bool _loading = true;
  String? _loadError;

  List<Employee> get items => _items;
  List<Employee> get activeItems => _items.where((e) => e.isActive).toList();
  bool get loading => _loading;
  String? get loadError => _loadError;
  int get activeCount => _items.where((e) => e.isActive).length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await _repository.fetchEmployees();
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Employees] load failed: $error');
    } finally {
      _loading = false;
    }
    notifyListeners();
  }

  @override
  void onDatabaseChanged() {
    _items = db.employees;
    notifyListeners();
  }

  Future<List<Employee>> forService(String serviceId) => _repository.fetchEmployees(serviceId: serviceId);

  Future<Employee?> byId(String id) => _repository.findById(id);

  /// یافتن همگام (برای فرم‌ها).
  Employee? byIdSync(String id) {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<bool> create(Employee employee) async {
    await _repository.create(employee);
    return true;
  }

  Future<bool> update(Employee employee) async {
    await _repository.update(employee);
    return true;
  }

  Future<void> remove(String id) => _repository.delete(id);

  String nextId() => 'emp-${DateTime.now().millisecondsSinceEpoch}';
}
