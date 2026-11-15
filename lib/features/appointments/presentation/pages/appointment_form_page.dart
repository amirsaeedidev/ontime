import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/jalali_picker.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/customer.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/service.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../sms/presentation/providers/sms_provider.dart';
import '../providers/appointments_provider.dart';

/// فرم ثبت/ویرایش نوبت — بازسازی صفحه «ثبت نوبت جدید» تصویر مرجع.
class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({super.key, this.appointmentId});

  final String? appointmentId;

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  Customer? _customer;
  List<Service> _services = const [];
  Employee? _employee;
  JalaliDate _date = JalaliDate.today();
  TimeOfDayLite? _time;
  bool _sendSms = true;
  bool _saving = false;
  bool _prefilled = false;
  Appointment? _existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final id = widget.appointmentId;
    if (id != null) {
      final appointment = context.read<AppointmentsProvider>().appointmentById(id);
      if (appointment != null) {
        _existing = appointment;
        _nameController.text = appointment.customerName;
        _phoneController.text = appointment.customerPhone;
        _noteController.text = appointment.note;
        _date = appointment.jalali;
        _time = TimeOfDayLite(appointment.startAt.hour, appointment.startAt.minute);
        _customer = context.read<CustomersProvider>().findById(appointment.customerId);
        final services = context.read<ServicesProvider>().items;
        _services = services.where((s) => appointment.serviceIds.contains(s.id)).toList();
        _employee = context.read<EmployeesProvider>().byIdSync(appointment.employeeId);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  num get _totalPrice => _services.fold<num>(0, (sum, s) => sum + s.price);
  int get _totalDuration => _services.fold<int>(0, (sum, s) => sum + s.totalMinutes);

  Future<void> _pickCustomer() async {
    final customers = context.read<CustomersProvider>().all;
    final selected = await showAppSheet<Customer>(
      context,
      title: 'انتخاب از مشتریان',
      child: _CustomerPickerList(customers: customers),
    );
    if (selected != null) {
      setState(() {
        _customer = selected;
        _nameController.text = selected.fullName;
        _phoneController.text = selected.phone;
      });
    }
  }

  Future<void> _pickServices() async {
    final all = context.read<ServicesProvider>().items.where((s) => s.isActive).toList();
    final selected = await showAppSheet<List<Service>>(
      context,
      title: 'انتخاب خدمات',
      child: _ServicePickerList(services: all, initial: _services),
    );
    if (selected != null) {
      setState(() {
        _services = selected;
        if (_employee != null && !_employee!.serviceIds.any((id) => selected.map((s) => s.id).contains(id))) {
          _employee = null;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showJalaliDatePicker(
      context,
      initial: _date,
      minDate: JalaliDate.today().addDays(-365),
      maxDate: JalaliDate.today().addDays(120),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePickerSheet(context, initial: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_services.isEmpty) {
      AppToast.show(context, 'حداقل یک خدمت انتخاب کنید', success: false);
      return;
    }
    if (_time == null) {
      AppToast.show(context, 'ساعت نوبت را انتخاب کنید', success: false);
      return;
    }
    final employees = context.read<EmployeesProvider>().items;
    final employee = _employee ??
        employees.firstWhere(
          (e) => e.isActive && e.serviceIds.any((id) => _services.map((s) => s.id).contains(id)),
          orElse: () => employees.first,
        );

    setState(() => _saving = true);
    final provider = context.read<AppointmentsProvider>();
    final start = _date.toDateTime().add(Duration(hours: _time!.hour, minutes: _time!.minute));

    final conflict = await provider.checkConflict(
      employeeId: employee.id,
      startAt: start,
      durationMinutes: _totalDuration,
      ignoreId: _existing?.id,
    );
    if (conflict != null) {
      if (!mounted) return;
      setState(() => _saving = false);
      await showConfirmDialog(
        context,
        title: 'تداخل زمانی',
        message:
            'برای ${employee.fullName} در این بازه نوبت دیگری ثبت شده است (${Fmt.time(conflict.startAt.hour, conflict.startAt.minute)} - ${conflict.customerName}). لطفاً زمان دیگری انتخاب کنید.',
        confirmLabel: 'متوجه شدم',
        cancelLabel: 'بستن',
        destructive: true,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (!mounted) return;

    // ثبت مشتری جدید در صورت نبود در فهرست.
    final customers = context.read<CustomersProvider>();
    var customer = _customer ?? customers.findByPhone(_phoneController.text.trim());
    if (customer == null) {
      customer = Customer(
        id: 'cus-${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        createdAt: DateTime.now(),
        tags: const ['ثبت توسط پذیرش'],
      );
      await customers.create(customer);
    }

    final appointment = Appointment(
      id: _existing?.id ?? 'apt-${DateTime.now().millisecondsSinceEpoch}',
      reference: _existing?.reference ?? 'OT-${1510 + DateTime.now().second}',
      customerId: customer.id,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      serviceIds: _services.map((s) => s.id).toList(),
      serviceName: _services.map((s) => s.title).join('، '),
      employeeId: employee.id,
      employeeName: employee.fullName,
      startAt: start,
      durationMinutes: _totalDuration,
      status: _existing?.status ?? AppointmentStatus.confirmed,
      note: _noteController.text.trim(),
      price: _totalPrice,
      createdAt: _existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'پذیرش',
    );

    if (_existing != null) {
      await provider.update(appointment);
    } else {
      await provider.create(appointment);
    }

    if (!mounted) return;
    final smsProvider = context.read<SmsProvider>();
    if (_sendSms) {
      await smsProvider.sendConfirmation(
            recipient: appointment.customerName,
            phone: appointment.customerPhone,
            content:
                '${appointment.customerName} عزیز، نوبت شما برای ${appointment.serviceName} در ${appointment.jalali.long} ساعت ${Fmt.time(start.hour, start.minute)} ثبت شد. کد پیگیری: ${appointment.reference}',
            appointmentId: appointment.id,
          );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, _existing != null ? 'نوبت با موفقیت ویرایش شد' : 'نوبت با موفقیت ثبت شد');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final employees = context.watch<EmployeesProvider>().items.where((e) => e.isActive).toList();
    final eligible = _services.isEmpty
        ? employees
        : employees.where((e) => e.serviceIds.any((id) => _services.map((s) => s.id).contains(id))).toList();

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 19,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameController,
                      hint: 'نام و نام خانوادگی',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => Validators.required(v, label: 'نام مشتری'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _phoneController,
                      hint: '۰۹۱۲۳۴۵۶۷۸۹',
                      icon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                      numericFa: true,
                      validator: Validators.mobile,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 10,
                child: _CustomerPickerCard(customer: _customer, onTap: _pickCustomer),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text('تاریخ',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: pal.textSecondary)),
              ),
              Expanded(
                child: Text('ساعت',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: pal.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PickerField(
                  value: _date.long,
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerField(
                  value: _time == null ? 'انتخاب ساعت' : Fmt.time(_time!.hour, _time!.minute),
                  icon: Icons.access_time_rounded,
                  muted: _time == null,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppDropdown<Employee>(
            label: 'متخصص',
            items: eligible,
            value: eligible.contains(_employee) ? _employee : null,
            hint: 'انتخاب متخصص',
            icon: Icons.badge_outlined,
            itemLabel: (e) => '${e.fullName} — ${e.title}',
            onChanged: (e) => setState(() => _employee = e),
          ),
          const SizedBox(height: 18),
          SolidButton(
            label: _services.isEmpty ? 'انتخاب خدمات' : 'خدمات انتخاب‌شده (${FaNum.ofInt(_services.length)})',
            icon: Icons.content_cut_rounded,
            gradient: true,
            height: 62,
            onPressed: _pickServices,
          ),
          if (_services.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final service in _services)
                  StatusBadge(label: service.title, color: pal.primaryBright, icon: Icons.check_rounded),
              ],
            ),
          ],
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('توضیحات (اختیاری)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _noteController,
            hint: 'هر نکته‌ای که لازم است پرسنل بدانند...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                IconTile(icon: Icons.sms_outlined, color: pal.success, size: 34, radius: 11),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('ارسال پیامک تایید', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                Switch.adaptive(
                  value: _sendSms,
                  onChanged: (v) => setState(() => _sendSms = v),
                  activeTrackColor: pal.primary,
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SolidButton(
                  label: _existing == null ? 'ثبت نوبت' : 'ذخیره تغییرات',
                  icon: Icons.check_rounded,
                  loading: _saving,
                  height: 52,
                  onPressed: _save,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SolidButton(
                  label: 'انصراف',
                  outlined: true,
                  height: 52,
                  onPressed: () => context.canPop() ? context.pop() : context.go('/appointments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return PageScaffold(
      title: _existing == null ? 'ثبت نوبت جدید' : 'ویرایش نوبت',
      subtitle: _existing == null ? 'ثبت سریع نوبت برای مشتری' : 'کد پیگیری ${FaNum.convert(_existing!.reference)}',
      icon: Icons.event_available_rounded,
      showBackButton: true,
      headerActionLabel: isDesktop ? null : 'قواعد',
      onHeaderAction: () => context.push('/settings/rules'),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: AppCard(child: form)),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _SummaryCard(
                        services: _services,
                        price: _totalPrice,
                        duration: _totalDuration,
                        date: _date,
                        time: _time,
                        onRemove: (service) => setState(() => _services = _services.where((s) => s.id != service.id).toList()),
                      ),
                      const SizedBox(height: 12),
                      const _RulesHintCard(),
                    ],
                  ),
                ),
              ],
            )
          : AppCard(
              padding: const EdgeInsets.all(14),
              child: form,
            ),
    );
  }
}

/// کارت انتخاب مشتری از فهرست (سمت چپ فرم).
class _CustomerPickerCard extends StatelessWidget {
  const _CustomerPickerCard({this.customer, required this.onTap});

  final Customer? customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          height: 108,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: pal.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: pal.primary.withValues(alpha: 0.55), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTile(icon: Icons.person_search_rounded, color: pal.primary, size: 40, radius: 12),
              const SizedBox(height: 6),
              Text(
                customer == null ? 'انتخاب از مشتریان' : customer!.fullName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5, height: 1.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.icon,
    required this.onTap,
    this.muted = false,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: pal.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: pal.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: muted ? pal.textMuted : pal.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 18, color: pal.primary),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.services,
    required this.price,
    required this.duration,
    required this.date,
    required this.time,
    required this.onRemove,
  });

  final List<Service> services;
  final num price;
  final int duration;
  final JalaliDate date;
  final TimeOfDayLite? time;
  final ValueChanged<Service> onRemove;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'خلاصه نوبت'),
          const SizedBox(height: 12),
          InfoRow(label: 'تاریخ', value: date.long, icon: Icons.calendar_today_rounded),
          InfoRow(
            label: 'ساعت',
            value: time == null ? 'انتخاب نشده' : Fmt.time(time!.hour, time!.minute),
            icon: Icons.access_time_rounded,
          ),
          InfoRow(label: 'مدت', value: Fmt.duration(duration), icon: Icons.timelapse_rounded),
          const Divider(height: 22),
          if (services.isEmpty)
            Text('خدمتی انتخاب نشده است', style: TextStyle(fontSize: 11.5, color: pal.textMuted))
          else
            for (final service in services)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.content_cut_rounded, size: 13, color: pal.primaryBright),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        service.title,
                        style: TextStyle(fontSize: 11.5, color: pal.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      Fmt.money(service.price, withUnit: false),
                      style: TextStyle(fontSize: 11, color: pal.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onRemove(service),
                      icon: Icon(Icons.close_rounded, size: 14, color: pal.textMuted),
                    ),
                  ],
                ),
              ),
          const Divider(height: 18),
          Row(
            children: [
              Text('مبلغ کل', style: TextStyle(fontSize: 12, color: pal.textMuted)),
              const Spacer(),
              Text(
                Fmt.money(price),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: pal.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RulesHintCard extends StatelessWidget {
  const _RulesHintCard();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      color: pal.surfaceAlt.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: pal.primaryBright),
              const SizedBox(width: 6),
              const Text('قواعد رزرو', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• امکان لغو تا ۲ ساعت قبل از نوبت\n• حداکثر ۱ بار جابه‌جایی برای هر نوبت\n• تداخل زمانی برای هر متخصص بررسی می‌شود',
            style: TextStyle(fontSize: 10.5, color: pal.textMuted, height: 1.9),
          ),
        ],
      ),
    );
  }
}

class _CustomerPickerList extends StatefulWidget {
  const _CustomerPickerList({required this.customers});

  final List<Customer> customers;

  @override
  State<_CustomerPickerList> createState() => _CustomerPickerListState();
}

class _CustomerPickerListState extends State<_CustomerPickerList> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final filtered = widget.customers
        .where((c) => _query.isEmpty || c.fullName.contains(_query) || c.phone.contains(FaNum.toLatin(_query)))
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchField(
          controller: _controller,
          hint: 'جست‌وجوی نام یا شماره...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const EmptyState(compact: true, title: 'مشتری یافت نشد')
        else
          for (final customer in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => Navigator.of(context).pop(customer),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: pal.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: pal.border),
                  ),
                  child: Row(
                    children: [
                      AvatarBadge(name: customer.fullName, size: 36, color: pal.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.fullName,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                            Text(Fmt.phone(customer.phone), style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
                          ],
                        ),
                      ),
                      Text(
                        '${FaNum.ofInt(customer.visitCount)} مراجعه',
                        style: TextStyle(fontSize: 10, color: pal.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ServicePickerList extends StatefulWidget {
  const _ServicePickerList({required this.services, required this.initial});

  final List<Service> services;
  final List<Service> initial;

  @override
  State<_ServicePickerList> createState() => _ServicePickerListState();
}

class _ServicePickerListState extends State<_ServicePickerList> {
  late List<Service> _selected = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final total = _selected.fold<num>(0, (sum, s) => sum + s.price);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final service in widget.services)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () {
                setState(() {
                  final exists = _selected.any((s) => s.id == service.id);
                  _selected = exists
                      ? _selected.where((s) => s.id != service.id).toList()
                      : [..._selected, service];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _selected.any((s) => s.id == service.id)
                      ? pal.primary.withValues(alpha: 0.12)
                      : pal.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _selected.any((s) => s.id == service.id) ? pal.primary : pal.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selected.any((s) => s.id == service.id)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: _selected.any((s) => s.id == service.id) ? pal.primaryBright : pal.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                          ),
                          Text(
                            '${Fmt.duration(service.durationMinutes)} • ${service.category}',
                            style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Fmt.money(service.price),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pal.success),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _selected.isEmpty ? null : () => Navigator.of(context).pop(_selected),
            child: Text('تأیید (${Fmt.money(total)})'),
          ),
        ),
      ],
    );
  }
}
