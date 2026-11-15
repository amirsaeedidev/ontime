# ONTIME — سامانه مدیریت نوبت‌دهی و رزرو آنلاین

اپلیکیشن کامل مدیریت نوبت برای سالن‌های زیبایی/کلینیک‌ها، با رابط کاربری **فارسی و راست‌به‌چپ**، تقویم شمسی، معماری تمیز Provider + GoRouter، و آمادگی مهاجرت به Supabase.

- **فریم‌ورک:** Flutter 3.35 (Material 3)
- **مدیریت وضعیت:** Provider (`ChangeNotifierProvider` + `DbBoundProvider`)
- **مسیریابی:** GoRouter 14 (ShellRoute + مسیرهای مستقل)
- **داده:** Repository Pattern با پیاده‌سازی Mock درون‌حافظه‌ای (بدون بک‌اند/فایربیس)
- **فونت:** Lalezar (لاله‌زار) — تنها قلم برنامه، بسته‌بندی‌شده در `assets/fonts/Lalezar-Regular.ttf`
- **خروجی وب:** PWA کامل (manifest، آیکون‌ها، اسپلش، عنوان فارسی)

---

## ۱) اجرای پروژه

```bash
# پیش‌نیاز: Flutter 3.35+
flutter pub get

# اجرا روی وب (پیشنهادی برای پیش‌نمایش)
flutter run -d chrome

# اجرا روی موبایل
flutter run

# ساخت نسخه وب (منابع موتور از همان دامنه سرو می‌شوند)
flutter build web --release --no-tree-shake-icons --no-web-resources-cdn --no-wasm-dry-run

# تست‌ها
flutter test

# تحلیل کد
dart analyze lib
```

برای سرو کردن خروجی وب:

```bash
cd build/web && python3 -m http.server 8080
# سپس http://localhost:8080
```

> مسیرهای عمیق (deep link) روی سرورهای استاتیک ساده نیاز به fallback به `index.html` دارند؛ در محیط توسعه `flutter run -d chrome` این مشکل وجود ندارد.

### ⚠️ نکته مهم دربارهٔ راه‌اندازی وب (رفع «صفحه بارگذاری بی‌پایان»)

نسخهٔ وب به‌صورت پیش‌فرض موتور رندر (CanvasKit) را از دامنهٔ گوگل (`www.gstatic.com`) بارگذاری می‌کند. در شبکه‌هایی که این دامنه فیلتر/کند است، موتور هرگز راه نمی‌افتد و اسپلش بارگذاری روی صفحه می‌ماند. دو اقدام انجام شده:

1. ساخت با پرچم `--no-web-resources-cdn` تا `canvaskit` از خود سرور خوانده شود.
2. `web/flutter_bootstrap.js` سفارشی که `canvasKitBaseUrl: 'canvaskit/'` را تثبیت می‌کند، اسپلش را **دقیقاً پس از اجرای `runApp`** برمی‌دارد (بدون تایمر) و در صورت شکست موتور، پیام فارسی با دکمهٔ «تلاش دوباره» نشان می‌دهد — نه اسپینر ابدی.

اسکریپت آماده سرو: `./tool/serve_web.sh 8080` (اگر build نبود، خودش با همین پرچم‌ها می‌سازد).

---

## ۲) ورودی‌های اصلی برنامه

| مسیر | صفحه |
|---|---|
| `/dashboard` | پیشخوان (آمار، نمودار عملکرد هفته، نوبت‌های جدید) |
| `/appointments` | لیست نوبت‌ها (جستجو، فیلتر، صفحه‌بندی) |
| `/appointments/new` · `/appointments/:id` · `/appointments/:id/edit` | ثبت/جزئیات/ویرایش نوبت |
| `/calendar` | تقویم شمسی روزانه/هفتگی/ماهانه |
| `/customers` · `/customers/new` · `/customers/:id` · `/customers/:id/edit` | مشتریان و CRM |
| `/services` · `/services/new` · `/services/:id/edit` | مدیریت خدمات |
| `/employees` · `/employees/new` · `/employees/:id` · `/employees/:id/edit` | پرسنل و شیفت‌ها |
| `/sms` · `/sms/settings` · `/sms/templates` | پنل پیامک، تنظیمات سرویس‌دهنده و قالب‌ها |
| `/reports` | گزارش‌ها و تحلیل مالی |
| `/activity` | گزارش فعالیت‌ها (Activity Log) |
| `/settings` | مرکز تنظیمات با ۱۲ میان‌بر |
| `/settings/business` · `/hours` · `/rules` · `/location` · `/appearance` · `/permissions` · `/notifications` · `/link` | زیرشاخه‌های تنظیمات |
| `/book` | **فرم عمومی رزرو مشتری** (بدون پوسته پنل) |
| `/book/manage` | پیگیری/لغو/جابه‌جایی نوبت توسط مشتری |

لینک عمومی نمونه: `ontime.app/book/ontime-salon`

---

## ۳) معماری

```
lib/
├── main.dart                 # bootstrap، ثبت ۸ ریپازیتوری و ۱۱ Provider
├── app/
│   ├── app.dart              # MaterialApp.router + تم Material 3 + لوکال فارسی
│   ├── router/app_router.dart# همه مسیرها، ShellRoute، errorBuilder
│   └── theme/
│       ├── app_palette.dart  # ۳ پالت (navy، emerald، light) + دسترسی context.pal
│       └── app_tokens.dart   # فاصله‌ها، شعاع‌ها، سایه‌ها، انیمیشن‌ها، Breakpoints
├── core/
│   ├── models/page_result.dart   # صفحه‌بندی سازگار با Supabase (range/limit)
│   ├── responsive/               # AppShell، AppSidebar، BottomNav، NavDestinations
│   ├── utils/                    # jalali، fa_num، formatters، validators
│   └── widgets/                  # کیت UI: کارت، دکمه، ورودی، بج، بازخورد، تقویم، جدول
├── data/
│   ├── models/               # ۹ مدل دامنه (Appointment, Customer, Service, Employee, …)
│   ├── mock/                 # mock_seed.dart + app_database.dart (منبع واحد داده)
│   └── repositories/         # ۸ اینترفیس + پیاده‌سازی Mock
└── features/<module>/
    ├── presentation/providers/
    ├── presentation/pages/
    └── presentation/widgets/
```

### لایه داده و آمادگی Supabase

هر ماژول یک **اینترفیس** دارد و UI فقط به اینترفیس وابسته است:

```dart
abstract class AppointmentRepository {
  Future<PageResult<Appointment>> fetchAppointments({filter, page, pageSize, ascending});
  Future<Appointment?> findById(String id);
  Future<Appointment?> findConflict({required String employeeId, required DateTime startAt, ...});
  Future<void> create(Appointment appointment);
  Future<void> update(Appointment appointment);
  Future<void> changeStatus(Appointment appointment, AppointmentStatus status, {String? reason});
  Future<void> reschedule(Appointment appointment, DateTime newStart, {bool byCustomer = false});
  Future<void> delete(String id);
}
```

برای اتصال به Supabase کافی است یک پیاده‌سازی `SupabaseAppointmentRepository implements AppointmentRepository` نوشته و در `main.dart` جایگزین `MockAppointmentRepository` شود؛ هیچ تغییری در Providerها و صفحات لازم نیست.
نگاشت پیشنهادی جدول‌ها، سیاست‌های RLS و نمونه کد در [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) آمده است.

### جریان داده

```
Page  →  Provider (ChangeNotifier)  →  Repository (Interface)  →  AppDatabase (mock)
   ←──────── notifyListeners() ←──────── Future<…> ←──────────────┘
```

`DbBoundProvider` یک `ChangeNotifier` مشترک روی `AppDatabase` ثبت می‌کند تا هر تغییری در داده، همه لیست‌ها/آمارها را به‌روز کند (شبیه realtime در Supabase).

---

## ۴) طراحی و پیکسل-فیت بودن

پالت پیش‌فرض از تصویر مرجع پیشخوان استخراج شده است:

| توکن | مقدار |
|---|---|
| background | `#0A1227` |
| surface / surfaceAlt | `#111A2B` / `#16203A` |
| border / borderStrong | `#1E2A47` / `#2A3A5F` |
| primary / primaryBright | `#2563EB` / `#38BDF8` |
| accentGlow | `#00E5FF` |
| success / warning / danger / purple | `#10B981` / `#F59E0B` / `#EF4444` / `#8B5CF6` |
| text | `#FFFFFF` / `#9FB0C9` / `#6B7C99` |

پالت دوم (**گرافیتی زمردی** — برگرفته از تصاویر مرجع ثبت نوبت/مشتریان/خدمات/تنظیمات پیشرفته): `#1E222B` پس‌زمینه، `#1A1E27` سطح، `#31343B` مرز، `#00B175` / `#10D68E` سبز اصلی، `#A21CFA` بنفش. هر سه پالت از مسیر `/settings/appearance` قابل تعویض زنده هستند.

### تایپوگرافی (Lalezar)

- تنها خانوادهٔ فونت ثبت‌شده در `pubspec.yaml`، **Lalezar** است؛ قلم‌های قبلی حذف شده‌اند تا هیچ متنی به Roboto برنگردد.
- `AppTheme.fontFamily = 'Lalezar'` و همان مقدار روی `fontFamily`، `textTheme`، `primaryTextTheme` و تمام تم‌های کامپوننت‌ها (AppBar، Dialog، SnackBar، Tooltip، Chip، Input، NavigationBar، BottomNavigationBar، DataTable، PopupMenu، ListTile) اعمال شده است.
- `MaterialApp.builder` یک `DefaultTextStyle` سراسری با Lalezar می‌سازد تا حتی `Text`های بدون استایل هم با همین قلم رندر شوند؛ نقاشی‌های `CustomPaint` (نمودارها) هم `fontFamily` را صریح می‌گیرند.
- لاله‌زار قدبلندتر از قلم قبلی است؛ ارتفاع خط‌ها (۱٫۶ تا ۱٫۸۵) و در چند نقطه پدینگ/اندازهٔ برچسب‌ها برای جلوگیری از بریدگی تنظیم شد (بدون تغییر در ساختار یا تم آبی).

### نکات RTL و ارقام فارسی
- تمام رشته‌های عددی حاوی جداکننده (ساعت، مبلغ، تلفن) با `Fmt.ltr()` در نشانگر `U+202A…U+202C` محصور می‌شوند تا ترتیب ارقام در متن راست‌به‌چپ به‌هم نریزد.
- تاریخ‌ها با `JalaliDate` و نام ماه/روز فارسی نمایش داده می‌شوند (تبدیل شمسی↔میلادی داخلی، بدون وابستگی خارجی).
- اعداد با `FaNum.convert` به ارقام فارسی تبدیل می‌شوند.

### ریسپانسیو
- موبایل (`< 600`): TopBar + BottomNavigationBar با FAB مرکزی
- تبلت/دسکتاپ (`≥ 900`): سایدبار ثابت راست + هدر دسکتاپ
- ویوپورت‌های تست‌شده: **390×844، 430×932، 768×1024، 1366×768، 1920×1080**

اسکرین‌شات‌های تأییدشده در [`docs/screenshots`](docs/screenshots) و گزارش QA در [`docs/QA-REPORT.md`](docs/QA-REPORT.md).

---

## ۵) قابلیت‌های پیاده‌سازی‌شده

- **پیشخوان:** آمار دوره (هفتگی/ماهانه)، درآمد تخمینی، نرخ تکمیل با روند، نمودار میله‌ای+خطی عملکرد هفته، CTA ثبت سریع، لیست نوبت‌های جدید، دسترسی سریع (دسکتاپ).
- **نوبت‌ها:** CRUD کامل، تشخیص تداخل زمانی، تغییر وضعیت (تأیید/انجام‌شده/لغو/عدم‌حضور)، جابه‌جایی، دلیل لغو، کد پیگیری، فیلتر وضعیت/خدمت/متخصص/بازه تاریخ، صفحه‌بندی، جستجو.
- **تقویم:** نمایش ماهانه شمسی با نقاط وضعیت، نماهای روزانه/هفتگی، فیلتر متخصص/خدمت، لیست نوبت‌های روز، انتخاب تاریخ با `showJalaliDatePicker`.
- **مشتریان (CRM):** پروفایل، تاریخچه نوبت‌ها، آمار مراجعه/درآمد/لغو، برچسب‌ها، یادداشت، مسدودسازی، جستجو و صفحه‌بندی.
- **خدمات:** قیمت، مدت، دسته، فعال/غیرفعال، ترتیب نمایش.
- **پرسنل:** نقش‌ها، تخصص‌ها، امتیاز، شیفت هفتگی چندبخشی، روزهای تعطیل، لین‌های کاری.
- **پیامک:** آمار پنل و اعتبار، لیست پیامک‌ها با وضعیت تحویل، تست اتصال، تنظیمات سرویس‌دهنده (کاوه‌نگار/فراز/…)، قالب‌های یادآوری، یادآوری خودکار (۲۴ ساعت و ۲ ساعت قبل)، ارسال پیامک تأیید هنگام ثبت نوبت.
- **گزارش‌ها:** درآمد دوره، بهترین ماه، میانگین ماهانه، نمودار درآمد ۶ ماه، درآمد به تفکیک خدمت، روند رشد.
- **فعالیت‌ها:** لاگ عملیات با فیلتر نوع و کاربر.
- **تنظیمات:** اطلاعات کسب‌وکار، ساعات کاری (شیفت چندبخشی به تفکیک روز + تعطیلات هفتگی)، قواعد رزرو و لغو، موقعیت مکانی (نقشه ماک با انتخاب نقطه)، ظاهر و پالت، دسترسی‌ها (ماتریس نقش×ماژول)، اعلان‌ها، لینک عمومی.
- **رزرو عمومی:** ویزارد ۴ مرحله‌ای (خدمت → متخصص → تاریخ/ساعت → اطلاعات) با اسلات‌های زمانی واقعی، جلوگیری از تداخل، ساخت خودکار مشتری، ارسال پیامک تأیید، و صفحه مدیریت رزرو (جستجو با شماره/کد، لغو و جابه‌جایی با اعمال قواعد).

---

## ۶) تست‌ها

```bash
flutter test
```

پوشش فعلی (۱۰۷ تست):

| فایل | موضوع |
|---|---|
| `test/jalali_test.dart` | تبدیل شمسی↔میلادی، کبیسه، طول ماه، جمع/تفریق روز و ماه |
| `test/formatters_test.dart` | ارقام فارسی، مبلغ/مبلغ کوتاه، ساعت LTR-safe، قالب موبایل |
| `test/appointments_flow_test.dart` | CRUD نوبت، تداخل زمانی، فیلتر وضعیت، لغو با دلیل، صفحه‌بندی، لیست روزانه |
| `test/customers_services_test.dart` | جستجوی مشتری، افزودن/ویرایش/حذف، فیلتر خدمات، شناسه یکتا |
| `test/booking_flow_test.dart` | مسیر ۴ مرحله‌ای رزرو، ساخت مشتری جدید، جستجوی کد پیگیری، reset |
| `test/app_smoke_test.dart` | بالا آمدن کامل اپ با ۱۱ Provider و رندر پیشخوان |
| `test/layout_test.dart` | ۲۶ مسیر × ۳ ویوپورت (۳۹۰/۷۶۸/۱۳۶۶) بدون سرریز چیدمان + تأیید قلم Lalezar |

---

## ۷) داده‌های نمونه

- ۷ خدمت (`srv-gelish`, `srv-tarmim`, `srv-keratin`, `srv-style`, `srv-skin`, `srv-color`, `srv-massage` غیرفعال)
- ۵ متخصص (`emp-fateme` مدیر، `emp-shima`, `emp-zahra`, `emp-elham`, `emp-amir` غیرفعال)
- ۱۴ مشتری (`cus-ali`, `cus-reza`, `cus-amin`, `cus-maryam`, `cus-sara`, `cus-nazanin`, `cus-hanieh`, …)
- کسب‌وکار «سالن زیبایی اُن‌تایم»، اسلاگ `ontime-salon`، استان تهران / کرج
- پنل پیامک کاوه‌نگار (شماره فرستنده ۱۰۰۰۴۳۴۱، اعتبار ۱۵۰)، یادآوری ۲۴h و ۲h
- تعطیلات هفتگی: پنجشنبه و جمعه، طول اسلات ۱۵ دقیقه

همه داده‌ها در `lib/data/mock/mock_seed.dart` و `app_database.dart` متمرکز شده‌اند.

---

## ۸) پایداری راه‌اندازی

- `main()` هیچ عملیات ناهمگام مسدودکننده‌ای پیش از `runApp` ندارد: `SharedPreferences` به‌صورت تنبل و با `try/catch` در `SettingsProvider` خوانده می‌شود و تنظیم جهت صفحه «بدون انتظار» انجام می‌شود.
- کل راه‌اندازی در `runZonedGuarded` است؛ `FlutterError.onError`، `PlatformDispatcher.instance.onError` و `ErrorWidget.builder` به پیام فارسی تبدیل می‌شوند (نه صفحهٔ قرمز/خالی).
- همهٔ `load()`ها در Providerها `try/catch/finally` دارند؛ پس `loading` همیشه ریست می‌شود و «اسپینر بی‌پایان» در هیچ صفحه‌ای رخ نمی‌دهد.
- روتر با `initialLocation: '/dashboard'` و بدون `redirect` است (بدون امکان حلقهٔ ریدایرکت)؛ کلید `GlobalKey` ناوبری برای هر نمونه مستقل ساخته می‌شود.

## ۹) وضعیت کیفیت کد

```
dart analyze        →  No issues found!  (0 error / 0 warning / 0 info)
flutter test        →  107 tests, all passing
flutter build web   →  ✓ Built build/web (با --no-web-resources-cdn)
```
