import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/enums.dart';
import '../providers/appointments_provider.dart';

/// منوی اقدامات سریع نوبت (تأیید، تکمیل، لغو، حذف).
Future<void> showAppointmentActions(BuildContext context, Appointment appointment) async {
  final pal = context.pal;
  final provider = context.read<AppointmentsProvider>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: pal.backgroundAlt,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: pal.borderStrong, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.verified_rounded, color: pal.success, size: 20),
            title: const Text('تأیید نوبت'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await provider.changeStatus(appointment, AppointmentStatus.confirmed);
              if (context.mounted) AppToast.show(context, 'نوبت تأیید شد');
            },
          ),
          ListTile(
            leading: Icon(Icons.task_alt_rounded, color: pal.accentGlow, size: 20),
            title: const Text('تکمیل نوبت'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await provider.changeStatus(appointment, AppointmentStatus.completed);
              if (context.mounted) AppToast.show(context, 'نوبت تکمیل شد');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_off_rounded, color: pal.warning, size: 20),
            title: const Text('ثبت عدم حضور'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await provider.changeStatus(appointment, AppointmentStatus.noShow);
              if (context.mounted) AppToast.show(context, 'عدم حضور ثبت شد', success: false);
            },
          ),
          ListTile(
            leading: Icon(Icons.event_busy_rounded, color: pal.danger, size: 20),
            title: const Text('لغو نوبت'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final confirmed = await showConfirmDialog(
                context,
                title: 'لغو نوبت',
                message: 'آیا از لغو نوبت ${appointment.customerName} مطمئن هستید؟ این اقدام در گزارش فعالیت ثبت می‌شود.',
                confirmLabel: 'لغو نوبت',
                destructive: true,
                icon: Icons.event_busy_rounded,
              );
              if (confirmed) {
                await provider.changeStatus(appointment, AppointmentStatus.cancelled, reason: 'لغو توسط پرسنل');
                if (context.mounted) AppToast.show(context, 'نوبت لغو شد', success: false);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
