import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../appointments/presentation/widgets/appointment_tile.dart';
import '../../../sms/presentation/providers/sms_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_widgets.dart';

/// تقویم شمسی نوبت‌ها با نمای روزانه، هفتگی و ماهانه.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final sms = context.watch<SmsProvider>();
    final pal = context.pal;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    final smsPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: pal.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sms_outlined, size: 13, color: pal.textMuted),
          const SizedBox(width: 4),
          Text(
            'موجودی: ${FaNum.ofInt(sms.stats?.credit ?? 0)} پیامک',
            style: TextStyle(fontSize: 10.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    final controls = AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarHeader(
            title: switch (provider.view) {
              CalendarView.monthly => '${provider.anchor.monthName} ${FaNum.ofInt(provider.anchor.year)}',
              CalendarView.weekly => 'هفته ${provider.weekDays.first.short} تا ${provider.weekDays.last.short}',
              CalendarView.daily => provider.selected.relativeLabel(),
            },
            onPrevious: provider.previous,
            onNext: provider.next,
            onToday: provider.selectToday,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PillToggle(
                options: const ['روزانه', 'هفتگی', 'ماهانه'],
                selectedIndex: provider.view.index,
                onChanged: (i) => provider.setView(CalendarView.values[i]),
                dense: true,
              ),
              if (!isDesktop) smsPill,
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: provider.serviceId,
                    isExpanded: true,
                    isDense: true,
                    dropdownColor: pal.surfaceAlt,
                    style: TextStyle(fontSize: 11.5, color: pal.textPrimary, fontFamily: 'Lalezar'),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: pal.textMuted),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('همه خدمات')),
                      for (final service in provider.services)
                        DropdownMenuItem<String?>(value: service.id, child: Text(service.title)),
                    ],
                    onChanged: provider.setService,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: provider.employeeId,
                    isExpanded: true,
                    isDense: true,
                    dropdownColor: pal.surfaceAlt,
                    style: TextStyle(fontSize: 11.5, color: pal.textPrimary, fontFamily: 'Lalezar'),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: pal.textMuted),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('همه متخصصان')),
                      for (final employee in provider.employees)
                        DropdownMenuItem<String?>(value: employee.id, child: Text(employee.fullName)),
                    ],
                    onChanged: provider.setEmployee,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return PageScaffold(
      title: 'تقویم نوبت‌ها',
      subtitle: 'نمای روزانه، هفتگی و ماهانه',
      icon: Icons.calendar_month_rounded,
      actions: [
        if (isDesktop) smsPill,
        SoftButton(label: 'بازآوری', icon: Icons.refresh_rounded, onTap: provider.load),
        SolidButton(
          label: 'نوبت جدید',
          icon: Icons.add_rounded,
          height: 42,
          onPressed: () => context.push('/appointments/new'),
        ),
      ],
      mobileActions: [
        CircleIconButton(icon: Icons.refresh_rounded, size: 38, onTap: provider.load),
      ],
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) ...[
            Row(
              children: [
                Expanded(
                  child: SolidButton(
                    label: 'نوبت جدید',
                    icon: Icons.add_rounded,
                    gradient: true,
                    height: 52,
                    onPressed: () => context.push('/appointments/new'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: Column(children: [controls, const SizedBox(height: 12), _MonthOrDayView(provider: provider)])),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: _AgendaView(provider: provider)),
              ],
            )
          else
            Column(
              children: [
                controls,
                const SizedBox(height: 12),
                _MonthOrDayView(provider: provider),
                const SizedBox(height: 12),
                _AgendaView(provider: provider),
              ],
            ),
          const SizedBox(height: 12),
          const PublicBookingHint(),
          const SizedBox(height: 6),
          Text(
            'تعطیلات هفتگی: ${context.watch<CalendarProvider>().isHoliday(JalaliDate.today()) ? 'امروز تعطیل است' : 'بر اساس تنظیمات مجموعه'}',
            style: TextStyle(fontSize: 10, color: pal.textMuted),
          ),
        ],
      ),
    );
  }
}

/// نمای ماهانه یا جدول روز (بسته به حالت انتخاب‌شده).
class _MonthOrDayView extends StatelessWidget {
  const _MonthOrDayView({required this.provider});

  final CalendarProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.view == CalendarView.daily) {
      final slots = provider.slotsFor(provider.selected, employee: provider.employeeId);
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'برنامه ${provider.selected.weekdayName}',
              subtitle: provider.selected.long,
            ),
            const SizedBox(height: 12),
            DayTimeline(
              slots: slots,
              onSlotTap: (slot) => context.push('/appointments/new'),
            ),
          ],
        ),
      );
    }
    return AppCard(
      child: JalaliMonthGrid(
        provider: provider,
        onSelect: provider.setSelected,
        compact: MediaQuery.sizeOf(context).width < 400,
      ),
    );
  }
}

/// فهرست کارت‌های روز (نمای هفتگی/روزانه) — مطابق تصویر مرجع.
class _AgendaView extends StatelessWidget {
  const _AgendaView({required this.provider});

  final CalendarProvider provider;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final days = provider.view == CalendarView.weekly
        ? provider.weekDays
        : provider.view == CalendarView.daily
            ? [provider.selected]
            : [for (var i = 0; i < provider.selected.monthLength; i++) JalaliDate(provider.anchor.year, provider.anchor.month, i + 1)];

    final withAppointments = days.where((d) => provider.appointmentsOn(d).isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: provider.view == CalendarView.monthly ? 'نوبت‌های ${provider.anchor.monthName}' : 'نوبت‌های هفته',
          subtitle: '${FaNum.ofInt(provider.appointments.length)} نوبت در بازه نمایش',
          actionLabel: 'نوبت جدید',
          onAction: () => context.push('/appointments/new'),
        ),
        const SizedBox(height: 10),
        if (withAppointments.isEmpty)
          const EmptyState(
            title: 'نوبتی در این بازه ثبت نشده',
            description: 'برای ثبت نوبت جدید از دکمه بالا استفاده کنید.',
            compact: true,
          )
        else
          for (final date in withAppointments) ...[
            CalendarDayCard(
              date: date,
              appointments: provider.appointmentsOn(date),
              onAdd: () => context.push('/appointments/new'),
              onBroadcast: () => AppToast.show(context, 'ارسال پیام همگانی در فاز بعدی فعال می‌شود'),
              onTapAppointment: (appointment) => context.push('/appointments/${appointment.id}'),
            ),
            const SizedBox(height: 10),
          ],
        if (provider.view == CalendarView.monthly)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'نوبت‌های ${provider.selected.long}'),
                const SizedBox(height: 10),
                if (provider.appointmentsOn(provider.selected).isEmpty)
                  Text(
                    'برای این روز نوبتی ثبت نشده است.',
                    style: TextStyle(fontSize: 11.5, color: pal.textMuted),
                  )
                else
                  for (final appointment in provider.appointmentsOn(provider.selected))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppointmentTile(
                        appointment: appointment,
                        dense: true,
                        onTap: () => context.push('/appointments/${appointment.id}'),
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}
