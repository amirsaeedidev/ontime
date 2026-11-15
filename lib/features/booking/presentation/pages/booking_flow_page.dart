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
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/service.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../sms/presentation/providers/sms_provider.dart';
import '../providers/booking_provider.dart';

/// صفحه رزرو عمومی مشتری (بدون نیاز به نصب اپلیکیشن).
class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({super.key});

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final booking = context.read<BookingProvider>();
    final sms = context.read<SmsProvider>();
    final success = await booking.submit();
    if (!success || !mounted) return;
    final appointment = booking.created;
    if (appointment != null) {
      await sms.sendConfirmation(
        recipient: appointment.customerName,
        phone: appointment.customerPhone,
        content:
            '${appointment.customerName} عزیز، نوبت شما برای ${appointment.serviceName} در ${appointment.jalali.long} ساعت ${Fmt.time(appointment.startAt.hour, appointment.startAt.minute)} ثبت شد. کد پیگیری: ${appointment.reference}',
        appointmentId: appointment.id,
      );
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final settings = context.watch<SettingsProvider>();
    final pal = context.pal;
    final business = settings.settings;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (booking.created != null) {
      return _BookingSuccessView(appointment: booking.created!, onNewBooking: booking.reset);
    }

    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(gradient: pal.primaryGradient, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business?.name ?? 'رزرو آنلاین',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
                            ),
                            Text(
                              'رزرو آنلاین نوبت • بدون نیاز به نصب برنامه',
                              style: TextStyle(fontSize: 10, color: pal.textMuted),
                            ),
                          ],
                        ),
                      ),
                      SoftButton(
                        label: 'پیگیری نوبت',
                        icon: Icons.receipt_long_rounded,
                        dense: true,
                        onTap: () => context.push('/book/manage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StepIndicator(currentStep: booking.step),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: AppDurations.normal,
                    child: switch (booking.step) {
                      0 => _ServiceStep(key: const ValueKey(0), booking: booking, services: context.watch<ServicesProvider>().activeServices),
                      1 => _EmployeeStep(key: const ValueKey(1), booking: booking),
                      2 => _DateTimeStep(key: const ValueKey(2), booking: booking),
                      _ => _InfoStep(key: const ValueKey(3), booking: booking, formKey: _formKey, name: _name, phone: _phone, note: _note, onSubmit: _submit),
                    },
                  ),
                  const SizedBox(height: 14),
                  if (booking.step > 0)
                    Row(
                      children: [
                        Expanded(
                          child: SolidButton(
                            label: 'مرحله قبل',
                            outlined: true,
                            height: 48,
                            onPressed: booking.previousStep,
                          ),
                        ),
                        if (booking.step < 3) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: SolidButton(
                              label: 'ادامه',
                              icon: Icons.arrow_back_rounded,
                              height: 48,
                              onPressed: booking.canProceed ? booking.nextStep : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (booking.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      booking.error!,
                      style: TextStyle(fontSize: 11, color: pal.danger),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppCard(
                    color: pal.surfaceAlt.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: pal.primaryBright),
                            const SizedBox(width: 6),
                            Text(
                              'قواعد رزرو',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• امکان لغو تا ${FaNum.ofInt(business?.bookingRules.minHoursBeforeChange ?? 2)} ساعت قبل از نوبت\n'
                          '• حداکثر ${FaNum.ofInt(business?.bookingRules.maxReschedules ?? 1)} بار جابه‌جایی برای هر نوبت\n'
                          '• رزرو تا ${FaNum.ofInt(business?.bookingRules.maxAdvanceDays ?? 30)} روز آینده امکان‌پذیر است',
                          style: TextStyle(fontSize: 10.5, color: pal.textMuted, height: 1.9),
                        ),
                      ],
                    ),
                  ),
                  if (!isWide) const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = ['خدمت', 'متخصص', 'زمان', 'اطلاعات'];

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= currentStep ? pal.primary : pal.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: i == currentStep ? FontWeight.w700 : FontWeight.w500,
                    color: i <= currentStep ? pal.textPrimary : pal.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (i != _labels.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _ServiceStep extends StatelessWidget {
  const _ServiceStep({super.key, required this.booking, required this.services});

  final BookingProvider booking;
  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'انتخاب خدمت', subtitle: 'خدمت مورد نظر خود را انتخاب کنید'),
          const SizedBox(height: 12),
          if (services.isEmpty)
            const EmptyState(compact: true, title: 'خدمتی برای رزرو فعال نیست')
          else
            for (final service in services)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => booking.selectService(service),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: booking.service?.id == service.id ? pal.primary.withValues(alpha: 0.14) : pal.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: booking.service?.id == service.id ? pal.primary : pal.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconTile(icon: Icons.content_cut_rounded, color: pal.primaryBright, size: 38, radius: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: pal.textPrimary),
                              ),
                              Text(
                                '${Fmt.duration(service.durationMinutes)} • ${service.category}',
                                style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Fmt.money(service.price),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: pal.success),
                            ),
                            Icon(Icons.chevron_left_rounded, size: 16, color: pal.textMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _EmployeeStep extends StatelessWidget {
  const _EmployeeStep({super.key, required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final employees = booking.availableEmployees;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'انتخاب متخصص', subtitle: 'متخصص مورد نظر خود را انتخاب کنید'),
          const SizedBox(height: 12),
          if (employees.isEmpty)
            const EmptyState(compact: true, title: 'متخصصی برای این خدمت ثبت نشده')
          else
            for (final employee in employees)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => booking.selectEmployee(employee),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: booking.employee?.id == employee.id ? pal.primary.withValues(alpha: 0.14) : pal.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: booking.employee?.id == employee.id ? pal.primary : pal.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        AvatarBadge(name: employee.fullName, size: 40, color: Color(employee.colorValue)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.fullName,
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                              ),
                              Text(employee.title, style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
                            ],
                          ),
                        ),
                        Icon(Icons.star_rounded, size: 13, color: pal.warning),
                        Text(
                          FaNum.convert(employee.rating.toStringAsFixed(1)),
                          style: TextStyle(fontSize: 10.5, color: pal.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _DateTimeStep extends StatelessWidget {
  const _DateTimeStep({super.key, required this.booking});

  final BookingProvider booking;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final dates = booking.selectableDates.take(21).toList();
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'انتخاب تاریخ', subtitle: 'تاریخ مورد نظر را انتخاب کنید'),
              const SizedBox(height: 12),
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final enabled = booking.isDateEnabled(date);
                    final selected = booking.date.sameDay(date);
                    return GestureDetector(
                      onTap: enabled ? () => booking.selectDate(date) : null,
                      child: Container(
                        width: 62,
                        decoration: BoxDecoration(
                          color: selected
                              ? pal.primary
                              : (enabled ? pal.surfaceAlt : pal.surfaceAlt.withValues(alpha: 0.35)),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: selected ? pal.primary : pal.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.weekdayName.substring(0, date.weekdayName.length.clamp(0, 4)),
                              style: TextStyle(
                                fontSize: 9.5,
                                color: selected ? Colors.white70 : pal.textMuted,
                              ),
                            ),
                            Text(
                              FaNum.ofInt(date.day),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : (enabled ? pal.textPrimary : pal.textMuted),
                              ),
                            ),
                            Text(
                              date.monthName,
                              style: TextStyle(fontSize: 9, color: selected ? Colors.white70 : pal.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'انتخاب ساعت',
                subtitle: booking.date.long,
              ),
              const SizedBox(height: 12),
              if (booking.loading)
                const LoadingState(compact: true)
              else if (booking.slots.isEmpty)
                const EmptyState(compact: true, title: 'برای این روز زمان آزادی نیست', description: 'روز دیگری را امتحان کنید.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in booking.slots)
                      GestureDetector(
                        onTap: slot.isAvailable ? () => booking.selectSlot(slot) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: booking.slot == slot
                                ? pal.primary
                                : (slot.isAvailable ? pal.surfaceAlt : pal.surfaceAlt.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: booking.slot == slot
                                  ? pal.primary
                                  : (slot.isAvailable ? pal.border : pal.border.withValues(alpha: 0.4)),
                            ),
                          ),
                          child: Text(
                            FaNum.convert(slot.label),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: booking.slot == slot
                                  ? Colors.white
                                  : (slot.isAvailable ? pal.textPrimary : pal.textMuted),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              if (booking.slots.any((s) => !s.isAvailable)) ...[
                const SizedBox(height: 10),
                Text(
                  'خانه‌های زمانی خاکستری رزرو شده یا گذشته هستند.',
                  style: TextStyle(fontSize: 10, color: pal.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({
    super.key,
    required this.booking,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.note,
    required this.onSubmit,
  });

  final BookingProvider booking;
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController note;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final service = booking.service;
    final employee = booking.employee;
    final slot = booking.slot;

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'اطلاعات شما', subtitle: 'نام و شماره تماس برای هماهنگی'),
              const SizedBox(height: 12),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: name,
                      label: 'نام و نام خانوادگی',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => Validators.required(v, label: 'نام'),
                      onChanged: booking.setName,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: phone,
                      label: 'شماره موبایل',
                      hint: '۰۹۱۲۳۴۵۶۷۸۹',
                      icon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                      numericFa: true,
                      validator: Validators.mobile,
                      onChanged: booking.setPhone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: note,
                      label: 'توضیحات (اختیاری)',
                      maxLines: 3,
                      onChanged: booking.setNote,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'بازبینی و تأیید'),
              const SizedBox(height: 10),
              InfoRow(label: 'خدمت', value: service?.title ?? '—', icon: Icons.content_cut_rounded),
              InfoRow(label: 'متخصص', value: employee?.fullName ?? '—', icon: Icons.badge_outlined),
              InfoRow(label: 'تاریخ', value: booking.date.long, icon: Icons.calendar_today_rounded),
              InfoRow(
                label: 'ساعت',
                value: slot == null ? '—' : FaNum.convert(slot.label),
                icon: Icons.access_time_rounded,
              ),
              InfoRow(
                label: 'مبلغ',
                value: service == null ? '—' : Fmt.money(service.price),
                icon: Icons.payments_rounded,
                valueColor: pal.success,
              ),
              const SizedBox(height: 12),
              SolidButton(
                label: 'تأیید و ثبت نوبت',
                icon: Icons.check_circle_rounded,
                gradient: true,
                height: 52,
                loading: booking.submitting,
                onPressed: () => onSubmit(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingSuccessView extends StatelessWidget {
  const _BookingSuccessView({required this.appointment, required this.onNewBooking});

  final dynamic appointment;
  final VoidCallback onNewBooking;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pal.success.withValues(alpha: 0.16),
                        border: Border.all(color: pal.success.withValues(alpha: 0.5)),
                        boxShadow: AppShadows.glow(pal.success, opacity: 0.3, blur: 24),
                      ),
                      child: Icon(Icons.check_rounded, color: pal.success, size: 42),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نوبت شما ثبت شد',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: pal.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'پیامک تأیید برای شما ارسال می‌شود.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: pal.textMuted),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InfoRow(label: 'کد پیگیری', value: FaNum.convert(appointment.reference as String), icon: Icons.receipt_long_rounded),
                        InfoRow(label: 'خدمت', value: appointment.serviceName as String, icon: Icons.content_cut_rounded),
                        InfoRow(label: 'متخصص', value: appointment.employeeName as String, icon: Icons.badge_outlined),
                        InfoRow(label: 'تاریخ', value: (appointment.jalali as JalaliDate).long, icon: Icons.calendar_today_rounded),
                        InfoRow(
                          label: 'ساعت',
                          value: Fmt.clock(appointment.startAt as DateTime),
                          icon: Icons.access_time_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SolidButton(
                    label: 'پیگیری یا تغییر نوبت',
                    icon: Icons.manage_history_rounded,
                    height: 50,
                    onPressed: () => context.push('/book/manage'),
                  ),
                  const SizedBox(height: 10),
                  SolidButton(
                    label: 'رزرو نوبت دیگر',
                    outlined: true,
                    height: 50,
                    onPressed: onNewBooking,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('بازگشت به پنل مدیریت'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
