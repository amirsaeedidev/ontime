import 'package:flutter_test/flutter_test.dart';
import 'package:ontime/data/mock/app_database.dart';
import 'package:ontime/data/models/customer.dart';
import 'package:ontime/data/models/service.dart';
import 'package:ontime/data/repositories/customer_repository.dart';
import 'package:ontime/data/repositories/service_repository.dart';
import 'package:ontime/features/customers/presentation/providers/customers_provider.dart';
import 'package:ontime/features/services/presentation/providers/services_provider.dart';

void main() {
  group('مشتریان', () {
    late AppDatabase db;
    late CustomersProvider provider;

    setUp(() async {
      db = AppDatabase();
      provider = CustomersProvider(MockCustomerRepository(db), db);
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });

    test('جست‌وجو بر اساس نام و شماره', () async {
      provider.search('مریم');
      await provider.load();
      expect(provider.items.every((c) => c.fullName.contains('مریم')), isTrue);
      expect(provider.items, isNotEmpty);

      provider.search('09121234501');
      await provider.load();
      expect(provider.items.any((c) => c.phone == '09121234501'), isTrue);
    });

    test('افزودن و ویرایش مشتری', () async {
      final before = db.customers.length;
      await provider.create(
        const Customer(id: 'cus-test', fullName: 'نگار سلیمی', phone: '09011112233'),
      );
      expect(db.customers.length, before + 1);

      final created = db.customers.firstWhere((c) => c.id == 'cus-test');
      await provider.update(created.copyWith(fullName: 'نگار س.'));
      expect(db.customers.firstWhere((c) => c.id == 'cus-test').fullName, 'نگار س.');
    });

    test('حذف مشتری از لیست', () async {
      final target = db.customers.first;
      await provider.delete(target.id);
      await provider.load();
      expect(db.customers.any((c) => c.id == target.id), isFalse);
      expect(provider.items.any((c) => c.id == target.id), isFalse);
    });
  });

  group('خدمات', () {
    late AppDatabase db;
    late ServicesProvider provider;

    setUp(() async {
      db = AppDatabase();
      provider = ServicesProvider(MockServiceRepository(db), db);
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });

    test('فیلتر فقط فعال', () async {
      provider.setActiveOnly(true);
      await provider.load();
      expect(provider.items.every((s) => s.isActive), isTrue);
    });

    test('ساخت خدمت جدید با شناسه یکتا', () async {
      final before = db.services.length;
      final id = provider.nextId();
      expect(db.services.any((s) => s.id == id), isFalse);
      await provider.create(
        Service(
          id: id,
          title: 'خدمت آزمایشی',
          price: 100000,
          durationMinutes: 30,
          isActive: true,
          category: 'ناخن',
        ),
      );
      expect(db.services.length, before + 1);
    });
  });
}
