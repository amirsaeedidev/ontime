import 'package:flutter_test/flutter_test.dart';
import 'package:ontime/core/utils/jalali.dart';
import 'package:ontime/data/mock/app_database.dart';
import 'package:ontime/data/models/appointment.dart';
import 'package:ontime/data/models/enums.dart';
import 'package:ontime/data/repositories/appointment_repository.dart';
import 'package:ontime/features/appointments/presentation/providers/appointments_provider.dart';

void main() {
  late AppDatabase db;
  late AppointmentsProvider provider;

  setUp(() async {
    db = AppDatabase();
    provider = AppointmentsProvider(MockAppointmentRepository(db), db);
    await provider.load();
  });

  test('داده‌های نمونه بارگذاری می‌شوند', () {
    expect(db.appointments, isNotEmpty);
    expect(provider.items, isNotEmpty);
    expect(provider.page.total, greaterThan(provider.items.length));
  });

  test('ایجاد، ویرایش و حذف نوبت', () async {
    final before = db.appointments.length;
    final start = DateTime.now().add(const Duration(days: 3)).copyWith(hour: 9, minute: 0);

    final appointment = Appointment(
      id: 'apt-test-1',
      reference: 'OT-9001',
      customerId: 'cus-ali',
      customerName: 'علی رضایی',
      customerPhone: '09121234501',
      serviceIds: const ['srv-gelish'],
      serviceName: 'ژلیش ناخن',
      employeeId: 'emp-shima',
      employeeName: 'شیما کوه‌ساری',
      startAt: start,
      durationMinutes: 40,
      price: 550000,
    );

    expect(await provider.create(appointment), isTrue);
    expect(db.appointments.length, before + 1);
    expect(db.appointmentById('apt-test-1'), isNotNull);

    final updated = db.appointmentById('apt-test-1')!.copyWith(status: AppointmentStatus.confirmed);
    await provider.update(updated);
    expect(db.appointmentById('apt-test-1')!.status, AppointmentStatus.confirmed);

    await provider.delete('apt-test-1');
    expect(db.appointmentById('apt-test-1'), isNull);
    expect(db.appointments.length, before);
  });

  test('تداخل زمانی تشخیص داده می‌شود', () async {
    final existing = db.appointments.first;
    final conflict = await provider.checkConflict(
      employeeId: existing.employeeId,
      startAt: existing.startAt.add(const Duration(minutes: 5)),
      durationMinutes: existing.durationMinutes,
    );
    expect(conflict, isNotNull);
    expect(conflict!.id, existing.id);

    final free = await provider.checkConflict(
      employeeId: existing.employeeId,
      startAt: existing.startAt.add(const Duration(hours: 30)),
      durationMinutes: 15,
      ignoreId: existing.id,
    );
    expect(free, isNull);
  });

  test('فیلتر وضعیت و جستجو', () async {
    provider.setStatus(AppointmentStatus.completed);
    await provider.load();
    expect(provider.items.every((a) => a.status == AppointmentStatus.completed), isTrue);
  });

  test('لغو نوبت دلیل را ثبت می‌کند', () async {
    final target = db.appointments.first;
    await provider.changeStatus(target, AppointmentStatus.cancelled, reason: 'درخواست مشتری');
    final after = db.appointmentById(target.id)!;
    expect(after.status, AppointmentStatus.cancelled);
    expect(after.cancelReason, 'درخواست مشتری');
  });

  test('صفحه‌بندی نوبت‌ها', () async {
    final total = provider.page.total;
    expect(provider.page.totalPages, greaterThan(1));
    provider.goToPage(2);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(provider.pageNumber, 2);
    expect(provider.page.total, total);
  });

  test('لیست روزانه بر اساس تاریخ فیلتر می‌شود', () async {
    final today = JalaliDate.today();
    final items = await provider.forDay(today.toDateTime());
    expect(items.every((a) => a.jalali.day == today.day), isTrue);
  });
}
