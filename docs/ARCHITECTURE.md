# معماری ONTIME

سند مرجع برای ساختار لایه‌ها، جریان داده و نقشه مهاجرت به Supabase.

---

## ۱) لایه‌ها

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation                                                │
│  pages/  widgets/  providers/ (ChangeNotifier)              │
│  • هیچ دسترسی مستقیمی به داده ندارند (بدون AppDatabase)     │
│  • فقط اینترفیس Repository تزریق می‌شود                     │
├─────────────────────────────────────────────────────────────┤
│ Domain                                                      │
│  data/models/*  (immutable, copyWith, toMap/fromMap-ready)   │
│  core/utils/*   (jalali، فرمت‌ها، اعتبارسنجی)               │
├─────────────────────────────────────────────────────────────┤
│ Data                                                        │
│  repositories/*.dart  → interface + MockXxxRepository        │
│  mock/app_database.dart → منبع واحد حافظه + notifyListeners  │
└─────────────────────────────────────────────────────────────┘
```

### `DbBoundProvider`

```dart
class DbBoundProvider extends ChangeNotifier {
  DbBoundProvider(this.db) {
    db.addListener(onDatabaseChanged); // شبیه کانال realtime
  }
  final AppDatabase db;
  @protected
  void onDatabaseChanged() {}
}
```

نتیجه: بعد از هر `create/update/delete` در هر ماژول، فهرست‌ها و آمارها به‌صورت خودکار تازه می‌شوند.

---

## ۲) اینترفیس‌های موجود

| اینترفیس | مسئولیت |
|---|---|
| `AppointmentRepository` | CRUD نوبت، تداخل، تغییر وضعیت، جابه‌جایی، لیست روز/مشتری |
| `CustomerRepository` | CRUD مشتری، جستجو، صفحه‌بندی، آمار |
| `ServiceRepository` | CRUD خدمت، فیلتر فعال |
| `EmployeeRepository` | CRUD پرسنل، تخصص/خدمت، شیفت |
| `SmsRepository` | ارسال ماک، تست اتصال، قالب‌ها، تنظیمات سرویس‌دهنده، اعلان‌ها |
| `SettingsRepository` | اطلاعات کسب‌وکار، ساعات کاری، قواعد، پالت، موقعیت |
| `DashboardRepository` | آمار دوره، سری درآمد ماهانه، درآمد به تفکیک خدمت |
| `ActivityRepository` | ثبت و خواندن لاگ فعالیت |

قرارداد بازگشتی درخواست‌های لیستی: `Future<PageResult<T>>` با فیلدهای `items / total / page / pageSize` و مشتقات `totalPages / hasNext / hasPrevious` — دقیقاً منطبق بر `range(from, to)` و `count` در Supabase.

---

## ۳) نگاشت پیشنهادی Supabase

| Dart | جدول | ستون‌های کلیدی |
|---|---|---|
| `Appointment` | `appointments` | `id uuid pk`, `business_id`, `customer_id fk`, `employee_id fk`, `service_ids uuid[]`, `start_at timestamptz`, `duration_minutes int`, `status enum`, `price numeric`, `reference text unique`, `note text`, `cancel_reason text`, `created_by text` |
| `Customer` | `customers` | `id`, `business_id`, `full_name`, `phone unique`, `tags text[]`, `notes`, `is_blocked bool` |
| `Service` | `services` | `id`, `business_id`, `title`, `price`, `duration_minutes`, `category`, `is_active`, `sort_order` |
| `Employee` | `employees` | `id`, `business_id`, `full_name`, `role`, `phone`, `is_active`, `rating`, `service_ids uuid[]` |
| `Shift` | `employee_shifts` | `id`, `employee_id`, `weekday smallint`, `starts_at time`, `ends_at time` |
| `BusinessSettings` | `businesses` | `id`, `name`, `slug unique`, `owner_name`, `phone`, `address`, `province`, `city`, `postal_code`, `lat`, `lng`, `holidays smallint[]`, `slot_minutes`, `booking_rules jsonb` |
| `SmsProviderSettings` | `sms_providers` | `business_id`, `provider`, `api_key`, `sender_number`, `credit`, `status` |
| `SmsMessage` | `sms_messages` | `id`, `business_id`, `appointment_id`, `customer_phone`, `template_key`, `body`, `status`, `sent_at` |
| `ActivityLog` | `activity_logs` | `id`, `business_id`, `actor`, `module`, `action`, `description`, `created_at` |
| `AppPalette` (انتخاب کاربر) | `user_preferences` | `user_id`, `palette_id`, `locale` |

### نمونه پیاده‌سازی

```dart
class SupabaseAppointmentRepository implements AppointmentRepository {
  SupabaseAppointmentRepository(this._client, this._businessId);
  final SupabaseClient _client;
  final String _businessId;

  @override
  Future<PageResult<Appointment>> fetchAppointments({
    AppointmentFilter filter = const AppointmentFilter(),
    int page = 1,
    int pageSize = 8,
    bool ascending = false,
  }) async {
    final from = (page - 1) * pageSize;
    var query = _client
        .from('appointments')
        .select('*', const FetchOptions(count: CountOption.exact))
        .eq('business_id', _businessId);

    if (filter.status != null) query = query.eq('status', filter.status!.name);
    if (filter.employeeId != null) query = query.eq('employee_id', filter.employeeId!);
    if (filter.query.isNotEmpty) query = query.ilike('customer_name', '%${filter.query}%');

    final rows = await query
        .order('start_at', ascending: ascending)
        .range(from, from + pageSize - 1);

    return PageResult(
      items: rows.map(Appointment.fromMap).toList(),
      total: rows.count ?? rows.length,
      page: page,
      pageSize: pageSize,
    );
  }
  // …
}
```

### سیاست‌های RLS پیشنهادی

```sql
-- نوبت‌ها فقط برای کسب‌وکار خودی
create policy appointments_rw on appointments
  for all using (business_id = auth.jwt() -> 'app_metadata' ->> 'business_id');

-- رزرو عمومی: خواندن اسلات‌های آزاد و درج نوبت بدون احراز هویت
create policy public_booking_insert on appointments
  for insert to anon with check (created_by = 'رزرو آنلاین');
```

جایگزینی در `main.dart`:

```dart
final appointmentRepository = SupabaseAppointmentRepository(supabase, businessId);
final customerRepository = SupabaseCustomerRepository(supabase, businessId);
// …
```

هیچ Provider یا صفحه‌ای تغییر نمی‌کند.

---

## ۴) جریان رزرو عمومی

```
/book  (ویزارد ۴ مرحله)
 ۱. selectService(service) → واکشی متخصصان خدمت
 ۲. selectEmployee(employee) → ساخت اسلات‌ها از ساعات کاری − تعطیلات − نوبت‌های موجود
 ۳. selectDate(jalali) → اسلات‌های آن روز؛ isDateEnabled قواعد تعطیلی و سقف rزرو را اعمال می‌کند
 ۴. setName/setPhone → submit()
      • findConflict() دوباره چک می‌شود (جلوگیری از رزرو همزمان)
      • مشتری با همان شماره استفاده یا ساخته می‌شود
      • Appointment با reference «OT-…» ثبت و پیامک تأیید ارسال می‌شود
/book/manage
      • lookup(phone) / lookupByReference(code)
      • customerCancel / customerReschedule با احترام به cancelBlockReason و rescheduleBlockReason
```

---

## ۵) قواعد رزرو (BookingRules)

| قاعده | پیش‌فرض | محل اعمال |
|---|---|---|
| `maxAdvanceDays` | ۳۰ | `BookingProvider.selectableDates` |
| `minCancelHours` | ۳ | `cancelBlockReason` |
| `maxRescheduleCount` | ۱ | `rescheduleBlockReason` |
| `slotMinutes` | ۱۵ | تولید اسلات‌ها |
| `requireConfirmation` | true | پس از submit |
| `holidays` | پنجشنبه/جمعه | `isDateEnabled` |

---

## ۶) نکات پیاده‌سازی RTL

- `MaterialApp.locale = fa`, `supportedLocales = [fa]`, `Directionality.rtl` سراسری.
- رشته‌های عددی با جداکننده از طریق `Fmt.ltr()` در `U+202A…U+202C` محصور می‌شوند (ساعت، مبلغ، تلفن، درصد).
- تاریخ شمسی: `JalaliDate` (تبدیل با الگوریتم `jalCal`، پشتیبانی کبیسه، `monthLength`, `weekdayName`).
- انتخاب تاریخ: ویجت اختصاصی `showJalaliDatePicker` (بدون وابستگی به پکیج‌های خارجی).
- اعداد فارسی: `FaNum.convert` در تمام ورودی‌های عددی و نمایش‌ها؛ `FaNum.toLatin` برای ذخیره‌سازی.
