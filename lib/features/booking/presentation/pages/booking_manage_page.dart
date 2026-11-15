import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/jalali_picker.dart';
import '../../../../data/models/appointment.dart';
import '../providers/booking_provider.dart';

/// پیگیری، لغو و جابه‌جایی نوبت توسط مشتری.
class BookingManagePage extends StatefulWidget {
  const BookingManagePage({super.key});

  @override
  State<BookingManagePage> createState() => _BookingManagePageState();
}

class _BookingManagePageState extends State<BookingManagePage> {
  final _phone = TextEditingController(text: '09121234501');
  final _reference = TextEditingController();
  List<Appointment> _results = const [];
  bool _searched = false;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    final booking = context.read<BookingProvider>();
    List<Appointment> results;
    if (_reference.text.trim().isNotEmpty) {
      results = await booking.lookupByReference(_reference.text);
      if (results.isEmpty) {
        results = await booking.lookup(_phone.text.trim());
      }
    } else {
      results = await booking.lookup(_phone.text.trim());
    }
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  Future<void> _cancel(Appointment appointment) async {
    final booking = context.read<BookingProvider>();
    final block = booking.cancelBlockReason(appointment);
    if (block != null) {
      AppToast.show(context, block, success: false);
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'لغو نوبت',
      message: 'آیا از لغو نوبت ${appointment.jalali.long} مطمئن هستید؟',
      confirmLabel: 'لغو نوبت',
      destructive: true,
      icon: Icons.event_busy_rounded,
    );
    if (!confirmed) return;
    await booking.customerCancel(appointment);
    if (!mounted) return;
    AppToast.show(context, 'نوبت شما لغو شد', success: false);
    await _search();
  }

  Future<void> _reschedule(Appointment appointment) async {
    final booking = context.read<BookingProvider>();
    final block = booking.rescheduleBlockReason(appointment);
    if (block != null) {
      AppToast.show(context, block, success: false);
      return;
    }
    final date = await showJalaliDatePicker(
      context,
      initial: appointment.jalali,
      minDate: JalaliDate.today(),
      maxDate: JalaliDate.today().addDays(30),
      title: 'تاریخ جدید را انتخاب کنید',
    );
    if (date == null || !mounted) return;
    final time = await showTimePickerSheet(context, initial: TimeOfDayLite.fromDate(appointment.startAt));
    if (time == null || !mounted) return;
    final newStart = date.toDateTime().add(Duration(hours: time.hour, minutes: time.minute));
    final ok = await booking.customerReschedule(appointment, newStart);
    if (!mounted) return;
    AppToast.show(
      context,
      ok ? 'نوبت شما جابه‌جا شد' : (booking.error ?? 'خطا در جابه‌جایی'),
      success: ok,
    );
    if (ok) await _search();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      backgroundColor: pal.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_forward_rounded,
                        size: 40,
                        onTap: () => context.canPop() ? context.pop() : context.go('/book'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'پیگیری نوبت',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pal.textPrimary),
                            ),
                            Text(
                              'با شماره موبایل یا کد پیگیری',
                              style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _phone,
                          label: 'شماره موبایل',
                          icon: Icons.call_outlined,
                          keyboardType: TextInputType.phone,
                          numericFa: true,
                          validator: Validators.mobile,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _reference,
                          label: 'کد پیگیری (اختیاری)',
                          hint: 'OT-1452',
                          icon: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(height: 14),
                        SolidButton(
                          label: 'جست‌وجوی نوبت',
                          icon: Icons.search_rounded,
                          loading: _loading,
                          onPressed: _search,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_searched && !_loading)
                    if (_results.isEmpty)
                      const EmptyState(
                        title: 'نوبتی یافت نشد',
                        description: 'شماره موبایل یا کد پیگیری را بررسی کنید.',
                        icon: Icons.search_off_rounded,
                      )
                    else
                      for (final appointment in _results) ...[
                        _ManagedAppointmentCard(
                          appointment: appointment,
                          onCancel: () => _cancel(appointment),
                          onReschedule: () => _reschedule(appointment),
                          cancelBlock: context.read<BookingProvider>().cancelBlockReason(appointment),
                          rescheduleBlock: context.read<BookingProvider>().rescheduleBlockReason(appointment),
                        ),
                        const SizedBox(height: 10),
                      ],
                  const SizedBox(height: 8),
                  AppCard(
                    color: pal.surfaceAlt.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.support_agent_rounded, size: 15, color: pal.primaryBright),
                            const SizedBox(width: 6),
                            Text(
                              'نیاز به راهنمایی دارید؟',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'برای تغییر نوبت خارج از قواعد، با مجموعه تماس بگیرید.',
                          style: TextStyle(fontSize: 10.5, color: pal.textMuted, height: 1.8),
                        ),
                      ],
                    ),
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

class _ManagedAppointmentCard extends StatelessWidget {
  const _ManagedAppointmentCard({
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
    this.cancelBlock,
    this.rescheduleBlock,
  });

  final Appointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final String? cancelBlock;
  final String? rescheduleBlock;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final active = appointment.status.isActive;
    return AppCard(
      accentColor: appointment.status.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusBadge.appointment(appointment.status),
              const Spacer(),
              Text(
                'کد پیگیری ${FaNum.convert(appointment.reference)}',
                style: TextStyle(fontSize: 10, color: pal.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            appointment.serviceName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
          ),
          Text(
            '${appointment.employeeName} • ${appointment.jalali.long} • ${Fmt.clock(appointment.startAt)}',
            style: TextStyle(fontSize: 11, color: pal.textSecondary),
          ),
          if (appointment.rescheduleCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'تعداد جابه‌جایی: ${FaNum.ofInt(appointment.rescheduleCount)}',
                style: TextStyle(fontSize: 10, color: pal.warning),
              ),
            ),
          if (active) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SoftButton(
                    label: 'جابه‌جایی',
                    icon: Icons.swap_horiz_rounded,
                    onTap: onReschedule,
                    color: rescheduleBlock == null ? pal.primaryBright : pal.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SoftButton(
                    label: 'لغو نوبت',
                    icon: Icons.event_busy_rounded,
                    onTap: onCancel,
                    color: cancelBlock == null ? pal.danger : pal.textMuted,
                  ),
                ),
              ],
            ),
            if (cancelBlock != null || rescheduleBlock != null) ...[
              const SizedBox(height: 8),
              Text(
                cancelBlock ?? rescheduleBlock!,
                style: TextStyle(fontSize: 10, color: pal.warning, height: 1.7),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
