import 'package:flutter_test/flutter_test.dart';
import 'package:ontime/data/mock/app_database.dart';
import 'package:ontime/data/repositories/appointment_repository.dart';
import 'package:ontime/data/repositories/customer_repository.dart';
import 'package:ontime/data/repositories/employee_repository.dart';
import 'package:ontime/data/repositories/service_repository.dart';
import 'package:ontime/features/booking/presentation/providers/booking_provider.dart';

void main() {
  late AppDatabase db;
  late BookingProvider booking;

  setUp(() async {
    db = AppDatabase();
    booking = BookingProvider(
      MockAppointmentRepository(db),
      MockServiceRepository(db),
      MockEmployeeRepository(db),
      MockCustomerRepository(db),
      db,
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
  });

  test('خدمات فعال برای رزرو بارگذاری می‌شوند', () {
    expect(booking.availableServices, isNotEmpty);
    expect(booking.availableServices.every((s) => s.isActive), isTrue);
  });

  test('مسیر چهار مرحله‌ای رزرو تا ثبت نهایی', () async {
    expect(booking.step, 0);
    expect(booking.canProceed, isFalse);

    await booking.selectService(booking.availableServices.first);
    expect(booking.step, 1);
    expect(booking.availableEmployees, isNotEmpty);

    await booking.selectEmployee(booking.availableEmployees.first);
    expect(booking.step, 2);

    // اولین روز و اولین اسلات آزاد را انتخاب می‌کنیم.
    var found = false;
    for (final date in booking.selectableDates.take(14)) {
      if (!booking.isDateEnabled(date)) continue;
      booking.selectDate(date);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final free = booking.slots.where((s) => s.isAvailable).toList();
      if (free.isEmpty) continue;
      booking.selectSlot(free.first);
      found = true;
      break;
    }
    expect(found, isTrue, reason: 'باید حداقل یک اسلات آزاد وجود داشته باشد');
    expect(booking.canProceed, isTrue);

    booking.goToStep(3);
    booking.setName('سارا احمدی');
    booking.setPhone('09121112233');
    expect(booking.canProceed, isTrue);

    final before = db.appointments.length;
    final ok = await booking.submit();
    expect(ok, isTrue);
    expect(booking.created, isNotNull);
    expect(db.appointments.length, before + 1);
    expect(db.appointments.any((a) => a.customerPhone == '09121112233'), isTrue);
  });

  test('مشتری جدید در صورت نبود شماره ساخته می‌شود', () async {
    await booking.selectService(booking.availableServices.first);
    await booking.selectEmployee(booking.availableEmployees.first);
    for (final date in booking.selectableDates.take(14)) {
      if (!booking.isDateEnabled(date)) continue;
      booking.selectDate(date);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      final free = booking.slots.where((s) => s.isAvailable).toList();
      if (free.isEmpty) continue;
      booking.selectSlot(free.first);
      break;
    }
    booking.goToStep(3);
    booking.setName('مینا کاظمی');
    booking.setPhone('09355556677');
    await booking.submit();
    expect(db.customers.any((c) => c.fullName == 'مینا کاظمی'), isTrue);
  });

  test('جست‌وجوی رزرو با شماره و کد پیگیری', () async {
    final byPhone = await booking.lookup('09121234501');
    expect(byPhone, isNotEmpty);
    final ref = byPhone.first.reference;
    final byRef = await booking.lookupByReference(ref);
    expect(byRef, isNotEmpty);
    expect(byRef.first.reference, ref);
  });

  test('بازنشانی مسیر رزرو', () async {
    await booking.selectService(booking.availableServices.first);
    booking.reset();
    expect(booking.step, 0);
    expect(booking.service, isNull);
  });
}
