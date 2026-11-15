import 'dart:math';

import '../../core/utils/jalali.dart';
import '../models/activity_log.dart';
import '../models/appointment.dart';
import '../models/business_settings.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/sms_message.dart';

/// داده‌های نمونه متمرکز؛ همه ماژول‌ها از همین منبع تغذیه می‌شوند.
class MockSeed {
  const MockSeed._();

  static DateTime _at(JalaliDate date, int hour, int minute) =>
      date.toDateTime().add(Duration(hours: hour, minutes: minute));

  static JalaliDate get today => JalaliDate.today();

  // ---------------------------------------------------------------------------
  // خدمات
  // ---------------------------------------------------------------------------
  static List<Service> services() => const [
        Service(
          id: 'srv-gelish',
          title: 'ژلیش ناخن',
          description: 'کاشت و ژلیش ناخن با مواد درجه یک و ماندگاری بالا.',
          price: 550000,
          durationMinutes: 40,
          bufferMinutes: 10,
          prepMinutes: 5,
          category: 'ناخن',
          totalBookings: 38,
          employeeIds: ['emp-shima', 'emp-fateme'],
          order: 1,
        ),
        Service(
          id: 'srv-tarmim',
          title: 'ترمیم ناخن',
          description: 'ترمیم و بازسازی ناخن‌های آسیب‌دیده همراه با تقویت صفحه ناخن.',
          price: 600000,
          durationMinutes: 60,
          bufferMinutes: 10,
          category: 'ناخن',
          totalBookings: 24,
          employeeIds: ['emp-shima', 'emp-fateme'],
          order: 2,
        ),
        Service(
          id: 'srv-keratin',
          title: 'کراتینه و ویتامینه',
          description: 'احیای تخصصی مو با کراتین و ویتامینه، مناسب موهای آسیب‌دیده.',
          price: 1250000,
          durationMinutes: 120,
          bufferMinutes: 15,
          prepMinutes: 10,
          category: 'مو',
          totalBookings: 19,
          employeeIds: ['emp-elham', 'emp-amir'],
          order: 3,
        ),
        Service(
          id: 'srv-style',
          title: 'اصلاح و استایل مو',
          description: 'کوتاهی، اصلاح فرم و استایل حرفه‌ای مو.',
          price: 350000,
          durationMinutes: 45,
          bufferMinutes: 5,
          category: 'مو',
          totalBookings: 46,
          employeeIds: ['emp-elham', 'emp-amir'],
          order: 4,
        ),
        Service(
          id: 'srv-skin',
          title: 'پاکسازی پوست',
          description: 'پاکسازی عمیق پوست با دستگاه و ماسک تخصصی.',
          price: 480000,
          durationMinutes: 60,
          bufferMinutes: 10,
          prepMinutes: 5,
          category: 'پوست',
          totalBookings: 31,
          employeeIds: ['emp-zahra'],
          order: 5,
        ),
        Service(
          id: 'srv-color',
          title: 'رنگ مو',
          description: 'رنگ و مش با متریال حرفه‌ای و مشاوره رنگ تخصصی.',
          price: 900000,
          durationMinutes: 90,
          bufferMinutes: 15,
          category: 'مو',
          totalBookings: 27,
          employeeIds: ['emp-amir', 'emp-elham'],
          order: 6,
        ),
        Service(
          id: 'srv-massage',
          title: 'ماساژ صورت',
          description: 'ماساژ آرامش‌بخش صورت با روغن‌های گیاهی.',
          price: 320000,
          durationMinutes: 30,
          bufferMinutes: 5,
          category: 'پوست',
          totalBookings: 8,
          employeeIds: ['emp-zahra'],
          order: 7,
          isActive: false,
        ),
      ];

  // ---------------------------------------------------------------------------
  // پرسنل
  // ---------------------------------------------------------------------------
  static Map<int, List<Shift>> _fullWeek({int from = 9, int to = 19}) => {
        for (var d = 0; d < 6; d++)
          d: [
            Shift(start: '${from.toString().padLeft(2, '0')}:00', end: '13:30'),
            Shift(start: '15:00', end: '${to.toString().padLeft(2, '0')}:00'),
          ],
      };

  static List<Employee> employees() => [
        Employee(
          id: 'emp-fateme',
          fullName: 'فاطمه رضایی',
          phone: '09121110022',
          title: 'مدیر مجموعه',
          role: StaffRole.owner,
          serviceIds: const ['srv-gelish', 'srv-tarmim'],
          schedule: _fullWeek(from: 10, to: 18),
          colorValue: 0xFF2563EB,
          email: 'fateme@ontime.app',
          startedAt: DateTime(2022, 4, 12),
          bookedCount: 62,
          rating: 4.9,
          permissions: const ['dashboard', 'appointments', 'customers', 'services', 'employees', 'sms', 'reports', 'settings'],
        ),
        Employee(
          id: 'emp-shima',
          fullName: 'شیما کوثری',
          phone: '09315355866',
          title: 'متخصص ناخن',
          role: StaffRole.specialist,
          serviceIds: const ['srv-gelish', 'srv-tarmim'],
          schedule: _fullWeek(),
          colorValue: 0xFF10B981,
          email: 'shima@ontime.app',
          startedAt: DateTime(2023, 1, 20),
          bookedCount: 58,
          rating: 4.8,
          permissions: const ['appointments', 'customers'],
        ),
        Employee(
          id: 'emp-zahra',
          fullName: 'زهرا نوری',
          phone: '09132145698',
          title: 'متخصص پوست',
          role: StaffRole.specialist,
          serviceIds: const ['srv-skin', 'srv-massage'],
          schedule: {
            0: const [Shift(start: '10:00', end: '18:00')],
            1: const [Shift(start: '10:00', end: '18:00')],
            2: const [Shift(start: '10:00', end: '18:00')],
            3: const [Shift(start: '12:00', end: '20:00')],
            4: const [Shift(start: '12:00', end: '20:00')],
          },
          colorValue: 0xFF8B5CF6,
          email: 'zahra@ontime.app',
          startedAt: DateTime(2023, 8, 5),
          bookedCount: 44,
          rating: 4.7,
          permissions: const ['appointments', 'customers'],
        ),
        Employee(
          id: 'emp-elham',
          fullName: 'الهه یاری',
          phone: '09121112335',
          title: 'متخصص مو',
          role: StaffRole.specialist,
          serviceIds: const ['srv-keratin', 'srv-style', 'srv-color'],
          schedule: _fullWeek(from: 9, to: 20),
          colorValue: 0xFFF59E0B,
          email: 'elham@ontime.app',
          startedAt: DateTime(2021, 11, 2),
          bookedCount: 71,
          rating: 4.9,
          permissions: const ['appointments', 'customers', 'reports'],
        ),
        Employee(
          id: 'emp-amir',
          fullName: 'امیر کاظمی',
          phone: '09199887766',
          title: 'آرایشگر',
          role: StaffRole.specialist,
          isActive: false,
          serviceIds: const ['srv-style', 'srv-color', 'srv-keratin'],
          schedule: {
            1: const [Shift(start: '11:00', end: '19:00')],
            3: const [Shift(start: '11:00', end: '19:00')],
            5: const [Shift(start: '11:00', end: '19:00')],
          },
          colorValue: 0xFFEF4444,
          email: 'amir@ontime.app',
          startedAt: DateTime(2024, 2, 15),
          bookedCount: 12,
          rating: 4.4,
          permissions: const ['appointments'],
        ),
      ];

  // ---------------------------------------------------------------------------
  // مشتریان
  // ---------------------------------------------------------------------------
  static List<Customer> customers() {
    final now = DateTime.now();
    Customer c(
      String id,
      String name,
      String phone,
      int visits,
      num spent,
      int daysAgo,
      {int cancel = 0, int noShow = 0, String note = '', List<String> tags = const []}
    ) {
      return Customer(
        id: id,
        fullName: name,
        phone: phone,
        createdAt: now.subtract(Duration(days: daysAgo + 40)),
        lastVisitAt: daysAgo < 400 ? now.subtract(Duration(days: daysAgo)) : null,
        visitCount: visits,
        totalSpent: spent,
        cancelCount: cancel,
        noShowCount: noShow,
        notes: note,
        tags: tags,
      );
    }

    return [
      c('cus-shima', 'شیما کوثری', '09315355866', 1, 550000, 420, tags: ['جدید']),
      c('cus-elham', 'الهه یاری', '09121112335', 1, 600000, 420, tags: ['جدید']),
      c('cus-parivash', 'پریوش نیازی', '09212565222', 0, 0, 900, tags: ['بدون مراجعه']),
      c('cus-zahra', 'زهرا نوری', '09132145698', 3, 1650000, 14, tags: ['وفادار']),
      c('cus-fateme', 'فاطمه احمدی', '09121234567', 1, 350000, 380, tags: ['جدید']),
      c('cus-ali', 'علی محمدی', '09121234501', 9, 5450000, 0,
          note: 'موهای کوتاه، حساسیت پوستی خفیف. همیشه ساعت صبح ترجیح می‌دهد.', tags: ['وفادار']),
      c('cus-reza', 'رضا شریفی', '09123334455', 5, 2400000, 0, cancel: 1),
      c('cus-amin', 'امین حسینی', '09127778899', 7, 6100000, 1, noShow: 1),
      c('cus-maryam', 'مریم رضایی', '09351112233', 2, 1000000, 21, cancel: 1),
      c('cus-sara', 'سارا احمدی', '09194445566', 4, 2350000, 9),
      c('cus-nazanin', 'نازنین کریمی', '09112223344', 6, 3900000, 33),
      c('cus-hanieh', 'هانیه موسوی', '09386667788', 3, 1250000, 47, cancel: 2, noShow: 1,
          note: 'دو بار لغو دیرهنگام ثبت شده است.'),
      c('cus-mahsa', 'مهسا جعفری', '09195556677', 2, 830000, 60),
      c('cus-bahare', 'بهاره صادقی', '09127778811', 1, 480000, 76),
    ];
  }

  // ---------------------------------------------------------------------------
  // نوبت‌ها
  // ---------------------------------------------------------------------------
  static List<Appointment> appointments() {
    final servicesList = services();
    final employeesList = employees();
    final customersList = customers();
    final random = Random(21);
    final result = <Appointment>[];
    var counter = 0;
    final base = today;

    final slots = [
      [9, 0],
      [10, 30],
      [12, 0],
      [13, 30],
      [15, 0],
      [16, 15],
      [18, 0],
    ];

    for (var offset = -24; offset <= 15; offset++) {
      final date = base.addDays(offset);
      // جمعه تعطیل است.
      if (date.weekday == 6) continue;
      final perDay = offset < 0 ? 2 + random.nextInt(3) : 1 + random.nextInt(3);
      final used = <String>{};
      for (var i = 0; i < perDay; i++) {
        final service = servicesList[random.nextInt(servicesList.length - 1)];
        final eligibleEmployees =
            employeesList.where((e) => e.serviceIds.contains(service.id) && e.shiftsFor(date.weekday).isNotEmpty).toList();
        if (eligibleEmployees.isEmpty) continue;
        final employee = eligibleEmployees[random.nextInt(eligibleEmployees.length)];
        final customer = customersList[random.nextInt(customersList.length)];
        final slot = slots[random.nextInt(slots.length)];
        final key = '${employee.id}-${slot[0]}-${slot[1]}';
        if (used.contains(key)) continue;
        used.add(key);

        final status = _statusFor(offset, slot[0], random);
        counter++;
        result.add(
          Appointment(
            id: 'apt-$counter',
            reference: 'OT-${(1450 + counter)}',
            customerId: customer.id,
            customerName: customer.fullName,
            customerPhone: customer.phone,
            serviceIds: [service.id],
            serviceName: service.title,
            employeeId: employee.id,
            employeeName: employee.fullName,
            startAt: _at(date, slot[0], slot[1]),
            durationMinutes: service.durationMinutes,
            status: status,
            price: service.price,
            createdAt: _at(date, slot[0], slot[1]).subtract(Duration(days: 2 + random.nextInt(5))),
            updatedAt: _at(date, slot[0], slot[1]).subtract(Duration(hours: 6)),
            note: random.nextInt(4) == 0 ? 'درخواست مشتری برای رزرو مجدد پس از عید.' : '',
            createdBy: random.nextBool() ? 'پذیرش' : 'صفحه رزرو آنلاین',
            cancelReason: status == AppointmentStatus.cancelled ? 'لغو توسط مشتری' : null,
            rescheduleCount: status == AppointmentStatus.cancelled ? 1 : 0,
          ),
        );
      }
    }

    // نوبت‌های امروز با ساعت‌های مشخص (هم‌راستا با تصویر مرجع).
    final todayDate = base;
    final todayPlan = <Map<String, dynamic>>[
      {'customer': 'cus-ali', 'service': 'srv-style', 'employee': 'emp-elham', 'hour': 9, 'minute': 30, 'status': AppointmentStatus.confirmed},
      {'customer': 'cus-reza', 'service': 'srv-skin', 'employee': 'emp-zahra', 'hour': 11, 'minute': 0, 'status': AppointmentStatus.pending},
      {'customer': 'cus-amin', 'service': 'srv-keratin', 'employee': 'emp-elham', 'hour': 16, 'minute': 15, 'status': AppointmentStatus.confirmed},
    ];
    final tomorrowPlan = <Map<String, dynamic>>[
      {'customer': 'cus-maryam', 'service': 'srv-gelish', 'employee': 'emp-shima', 'hour': 10, 'minute': 0, 'status': AppointmentStatus.confirmed},
      {'customer': 'cus-sara', 'service': 'srv-tarmim', 'employee': 'emp-shima', 'hour': 12, 'minute': 30, 'status': AppointmentStatus.pending},
      {'customer': 'cus-nazanin', 'service': 'srv-color', 'employee': 'emp-elham', 'hour': 15, 'minute': 0, 'status': AppointmentStatus.confirmed},
    ];

    void addPlan(List<Map<String, dynamic>> plan, JalaliDate date, String suffix) {
      for (var i = 0; i < plan.length; i++) {
        final p = plan[i];
        final service = servicesList.firstWhere((s) => s.id == p['service']);
        final employee = employeesList.firstWhere((e) => e.id == p['employee']);
        final customer = customersList.firstWhere((c) => c.id == p['customer']);
        counter++;
        result.add(
          Appointment(
            id: 'apt-fixed-$suffix-$i',
            reference: 'OT-${1480 + counter}',
            customerId: customer.id,
            customerName: customer.fullName,
            customerPhone: customer.phone,
            serviceIds: [service.id],
            serviceName: service.title,
            employeeId: employee.id,
            employeeName: employee.fullName,
            startAt: _at(date, p['hour'] as int, p['minute'] as int),
            durationMinutes: service.durationMinutes,
            status: p['status'] as AppointmentStatus,
            price: service.price,
            createdAt: DateTime.now().subtract(Duration(days: 1 + i)),
            updatedAt: DateTime.now().subtract(Duration(hours: 2 + i)),
            createdBy: 'پذیرش',
          ),
        );
      }
    }

    addPlan(todayPlan, todayDate, 'today');
    addPlan(tomorrowPlan, todayDate.addDays(1), 'tomorrow');

    final unique = <String, Appointment>{};
    for (final a in result) {
      unique[a.id] = a;
    }
    final list = unique.values.toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  static AppointmentStatus _statusFor(int offset, int hour, Random random) {
    if (offset < 0) {
      final r = random.nextInt(100);
      if (r < 78) return AppointmentStatus.completed;
      if (r < 92) return AppointmentStatus.cancelled;
      return AppointmentStatus.noShow;
    }
    if (offset == 0) {
      final now = DateTime.now();
      final isPast = hour < now.hour;
      if (isPast) {
        return random.nextInt(100) < 85 ? AppointmentStatus.completed : AppointmentStatus.noShow;
      }
      return random.nextBool() ? AppointmentStatus.confirmed : AppointmentStatus.pending;
    }
    return random.nextInt(100) < 62 ? AppointmentStatus.confirmed : AppointmentStatus.pending;
  }

  // ---------------------------------------------------------------------------
  // پیامک‌ها
  // ---------------------------------------------------------------------------
  static List<SmsMessage> smsMessages() {
    final random = Random(5);
    final customersList = customers();
    final result = <SmsMessage>[];
    final now = DateTime.now();
    const templates = [
      ['confirmation', 'تأیید نوبت', 'نوبت شما با کد {کد پیگیری} برای {تاریخ نوبت} ساعت {ساعت نوبت} ثبت شد.'],
      ['reminder', 'یادآوری نوبت', 'یادآوری: نوبت شما فردا ساعت {ساعت نوبت} در {نام مجموعه} است.'],
      ['cancellation', 'لغو نوبت', 'نوبت شما در {تاریخ نوبت} لغو شد. برای رزرو مجدد با ما تماس بگیرید.'],
      ['reschedule', 'جابه‌جایی نوبت', 'نوبت شما به {تاریخ نوبت} ساعت {ساعت نوبت} منتقل شد.'],
    ];

    for (var i = 0; i < 46; i++) {
      final customer = customersList[random.nextInt(customersList.length)];
      final template = templates[random.nextInt(templates.length)];
      final createdAt = now.subtract(Duration(hours: 2 + i * 5, minutes: random.nextInt(50)));
      final roll = random.nextInt(100);
      SmsStatus status;
      if (roll < 74) {
        status = SmsStatus.delivered;
      } else if (roll < 84) {
        status = SmsStatus.sent;
      } else if (roll < 92) {
        status = SmsStatus.pending;
      } else {
        status = SmsStatus.failed;
      }
      result.add(
        SmsMessage(
          id: 'sms-${i + 1}',
          recipientName: customer.fullName,
          phone: customer.phone,
          templateKey: template[0],
          templateLabel: template[1],
          content: template[2]
              .replaceAll('{کد پیگیری}', 'OT-${1450 + i}')
              .replaceAll('{تاریخ نوبت}', today.addDays(i % 5 - 2).long)
              .replaceAll('{ساعت نوبت}', '${(9 + i % 8).toString().padLeft(2, '0')}:۳۰')
              .replaceAll('{نام مجموعه}', 'سالن زیبایی اُنتایم'),
          status: status,
          createdAt: createdAt,
          sentAt: status == SmsStatus.pending ? null : createdAt.add(const Duration(seconds: 8)),
          deliveredAt: status == SmsStatus.delivered ? createdAt.add(const Duration(seconds: 24)) : null,
          error: status == SmsStatus.failed
              ? (roll > 96 ? 'شماره نامعتبر است' : 'اعتبار پنل پیامک کافی نیست')
              : null,
          cost: 1,
        ),
      );
    }
    return result;
  }

  static List<SmsTemplate> smsTemplates() => const [
        SmsTemplate(
          key: 'confirmation',
          label: 'تأیید نوبت',
          body: '{نام مشتری} عزیز، نوبت شما برای {نام خدمت} در {تاریخ نوبت} ساعت {ساعت نوبت} با {نام متخصص} ثبت شد. کد پیگیری: {کد پیگیری} — {نام مجموعه}',
        ),
        SmsTemplate(
          key: 'reminder',
          label: 'یادآوری نوبت',
          body: '{نام مشتری} عزیز، یادآوری می‌کنیم نوبت شما فردا ساعت {ساعت نوبت} برای {نام خدمت} در {نام مجموعه} است.',
          hoursBefore: 24,
        ),
        SmsTemplate(
          key: 'reminder-2h',
          label: 'یادآوری دو ساعت قبل',
          body: '{نام مشتری} عزیز، نوبت شما تا ۲ ساعت دیگر ({ساعت نوبت}) آغاز می‌شود. {نام مجموعه}',
          hoursBefore: 2,
        ),
        SmsTemplate(
          key: 'cancellation',
          label: 'لغو نوبت',
          body: '{نام مشتری} عزیز، نوبت شما در {تاریخ نوبت} لغو شد. برای رزرو مجدد به پنل رزرو مراجعه کنید.',
        ),
        SmsTemplate(
          key: 'reschedule',
          label: 'جابه‌جایی نوبت',
          body: '{نام مشتری} عزیز، نوبت شما به {تاریخ نوبت} ساعت {ساعت نوبت} با {نام متخصص} منتقل شد.',
        ),
        SmsTemplate(
          key: 'custom',
          label: 'پیام دلخواه',
          body: '{نام مشتری} عزیز، {نام مجموعه} در خدمت شماست.',
          isEnabled: false,
        ),
      ];

  // ---------------------------------------------------------------------------
  // گزارش فعالیت
  // ---------------------------------------------------------------------------
  static List<ActivityLog> activityLogs() {
    final now = DateTime.now();
    final entries = <List<dynamic>>[
      [ActivityType.appointmentCreated, 'ثبت نوبت جدید', 'نوبت ژلیش ناخن برای شیما کوثری ثبت شد.', 'فاطمه رضایی', 'نوبت', 0.4],
      [ActivityType.smsSent, 'ارسال پیامک تأیید', 'پیامک تأیید نوبت به ۰۹۱۲۱۲۳۴۵۰۱ ارسال شد.', 'سیستم', 'پیامک', 1.2],
      [ActivityType.appointmentUpdated, 'جابه‌جایی نوبت', 'نوبت امین حسینی از ۱۰:۰۰ به ۱۶:۱۵ منتقل شد.', 'فاطمه رضایی', 'نوبت', 2.5],
      [ActivityType.customerRegistered, 'ثبت مشتری جدید', 'فاطمه احمدی با شماره ۰۹۱۲۱۲۳۴۵۶۷ ثبت شد.', 'پذیرش', 'مشتری', 4],
      [ActivityType.appointmentCompleted, 'تکمیل نوبت', 'نوبت کراتینه و ویتامینه تکمیل شد.', 'الهه یاری', 'نوبت', 6],
      [ActivityType.smsFailed, 'ارسال ناموفق پیامک', 'ارسال یادآوری نوبت برای ۰۹۳۸۶۶۶۷۷۸۸ ناموفق بود.', 'سیستم', 'پیامک', 8],
      [ActivityType.serviceModified, 'ویرایش خدمت', 'قیمت رنگ مو به ۹۰۰٬۰۰۰ تومان تغییر کرد.', 'فاطمه رضایی', 'خدمت', 11],
      [ActivityType.employeeAdded, 'افزودن پرسنل', 'امیر کاظمی به تیم اضافه شد.', 'فاطمه رضایی', 'پرسنل', 20],
      [ActivityType.appointmentCancelled, 'لغو نوبت', 'نوبت سارا احمدی به دلیل شرایط مشتری لغو شد.', 'پذیرش', 'نوبت', 26],
      [ActivityType.settingsChanged, 'تغییر تنظیمات', 'ساعت کاری سه‌شنبه‌ها به ۱۲:۰۰ تا ۲۰:۰۰ تغییر کرد.', 'فاطمه رضایی', 'تنظیمات', 33],
      [ActivityType.smsSent, 'ارسال پیامک یادآوری', 'یادآوری ۲۴ ساعته به ۵ مشتری ارسال شد.', 'سیستم', 'پیامک', 46],
      [ActivityType.appointmentCreated, 'ثبت نوبت آنلاین', 'نوبت پاکسازی پوست از صفحه رزرو عمومی ثبت شد.', 'صفحه رزرو', 'نوبت', 52],
      [ActivityType.appointmentCompleted, 'تکمیل نوبت', 'نوبت اصلاح و استایل مو تکمیل شد.', 'الهه یاری', 'نوبت', 61],
      [ActivityType.customerRegistered, 'ثبت مشتری جدید', 'مریم رضایی از صفحه رزرو ثبت شد.', 'صفحه رزرو', 'مشتری', 74],
      [ActivityType.settingsChanged, 'تغییر قواعد رزرو', 'حداکثر جابه‌جایی نوبت روی ۱ بار تنظیم شد.', 'فاطمه رضایی', 'تنظیمات', 90],
      [ActivityType.serviceModified, 'افزودن خدمت', 'خدمت ماساژ صورت غیرفعال شد.', 'فاطمه رضایی', 'خدمت', 110],
      [ActivityType.appointmentUpdated, 'ویرایش نوبت', 'زمان نوبت نازنین کریمی به ۱۵:۰۰ تغییر کرد.', 'پذیرش', 'نوبت', 130],
      [ActivityType.smsFailed, 'ارسال ناموفق پیامک', 'اعتبار پنل پیامک کافی نبود.', 'سیستم', 'پیامک', 150],
    ];
    return [
      for (var i = 0; i < entries.length; i++)
        ActivityLog(
          id: 'log-${i + 1}',
          type: entries[i][0] as ActivityType,
          title: entries[i][1] as String,
          description: entries[i][2] as String,
          actor: entries[i][3] as String,
          entityName: entries[i][4] as String,
          entityId: 'entity-${i + 1}',
          createdAt: now.subtract(Duration(hours: ((entries[i][5] as num) * 2).round())),
        ),
    ];
  }

  // ---------------------------------------------------------------------------
  // تنظیمات مجموعه
  // ---------------------------------------------------------------------------
  static BusinessSettings businessSettings() => BusinessSettings(
        workingHours: {
          for (var d = 0; d < 6; d++)
            d: const [
              Shift(start: '08:30', end: '13:00'),
              Shift(start: '16:00', end: '21:00'),
            ],
        },
        workSchedules: {
          for (var d = 0; d < 6; d++)
            d: const [
              Shift(start: '08:30', end: '13:00'),
              Shift(start: '16:00', end: '21:00'),
            ],
        },
        holidays: const [5, 6],
        smsProvider: const SmsProviderSettings(
          providerName: 'کاوه‌نگار',
          apiKey: 'KNG-2f19c7d8a4e7b1129f0c',
          username: 'ontime_salon',
          password: '••••••••',
          senderNumber: '10004341',
          endpoint: 'https://api.kavenegar.com/v1',
          isEnabled: true,
          status: SmsConnectionStatus.connected,
          credit: 150,
        ),
        notifications: const NotificationSettings(),
        bookingRules: const BookingRules(),
      );
}
