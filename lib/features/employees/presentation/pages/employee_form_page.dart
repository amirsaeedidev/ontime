import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/enums.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../providers/employees_provider.dart';

/// فرم افزودن/ویرایش پرسنل با برنامه هفتگی، تعطیلات و مجوزها.
class EmployeeFormPage extends StatefulWidget {
  const EmployeeFormPage({super.key, this.employeeId});

  final String? employeeId;

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _title = TextEditingController();
  final _email = TextEditingController();

  StaffRole _role = StaffRole.specialist;
  bool _isActive = true;
  List<String> _serviceIds = [];
  List<String> _permissions = ['appointments', 'customers'];
  final Map<int, List<Shift>> _schedule = {};
  bool _saving = false;
  bool _prefilled = false;
  Employee? _existing;

  static const _permissionOptions = {
    'dashboard': 'پیشخوان',
    'appointments': 'نوبت‌ها',
    'customers': 'مشتریان',
    'services': 'خدمات',
    'employees': 'پرسنل',
    'sms': 'پیامک',
    'reports': 'گزارش‌ها',
    'settings': 'تنظیمات',
  };

  @override
  void initState() {
    super.initState();
    for (var day = 0; day < 6; day++) {
      _schedule[day] = [const Shift(start: '09:00', end: '17:00')];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    if (widget.employeeId != null) {
      final employee = context.read<EmployeesProvider>().byIdSync(widget.employeeId!);
      if (employee != null) {
        _existing = employee;
        _name.text = employee.fullName;
        _phone.text = employee.phone;
        _title.text = employee.title;
        _email.text = employee.email;
        _role = employee.role;
        _isActive = employee.isActive;
        _serviceIds = [...employee.serviceIds];
        _permissions = [...employee.permissions];
        _schedule
          ..clear()
          ..addAll(employee.schedule.map((k, v) => MapEntry(k, [...v])));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _title.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<EmployeesProvider>();
    final employee = (_existing ??
            Employee(
              id: provider.nextId(),
              fullName: '',
              phone: '',
              colorValue: 0xFF2563EB,
            ))
        .copyWith(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      title: _title.text.trim(),
      email: _email.text.trim(),
      role: _role,
      isActive: _isActive,
      serviceIds: _serviceIds,
      permissions: _permissions,
      schedule: _schedule,
      startedAt: _existing?.startedAt ?? DateTime.now(),
    );
    if (_existing != null) {
      await provider.update(employee);
    } else {
      await provider.create(employee);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, _existing != null ? 'اطلاعات پرسنل به‌روزرسانی شد' : 'پرسنل جدید اضافه شد');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/employees');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final services = context.watch<ServicesProvider>().items;

    return PageScaffold(
      title: widget.employeeId == null ? 'پرسنل جدید' : 'ویرایش پرسنل',
      subtitle: 'پروفایل، دسترسی و برنامه کاری',
      icon: Icons.badge_rounded,
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'اطلاعات پرسنل'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _name,
                          label: 'نام و نام خانوادگی',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => Validators.required(v, label: 'نام'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _phone,
                          label: 'موبایل',
                          icon: Icons.call_outlined,
                          keyboardType: TextInputType.phone,
                          numericFa: true,
                          validator: Validators.mobile,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _title,
                          label: 'عنوان شغلی',
                          hint: 'متخصص ناخن',
                          icon: Icons.work_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppDropdown<StaffRole>(
                          label: 'نقش',
                          items: StaffRole.values,
                          value: _role,
                          itemLabel: (r) => r.label,
                          onChanged: (r) => setState(() => _role = r ?? _role),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _email,
                    label: 'ایمیل',
                    hint: 'name@ontime.app',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AppSwitchRow(
                    title: 'فعال',
                    description: 'پرسنل غیرفعال در صفحه رزرو نمایش داده نمی‌شود.',
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    icon: Icons.toggle_on_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'خدمات قابل ارائه'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final service in services)
                        FilterChip(
                          label: Text(service.title),
                          selected: _serviceIds.contains(service.id),
                          onSelected: (selected) => setState(() {
                            _serviceIds = selected
                                ? [..._serviceIds, service.id]
                                : _serviceIds.where((id) => id != service.id).toList();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(title: 'مجوزهای دسترسی'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in _permissionOptions.entries)
                        FilterChip(
                          label: Text(entry.value),
                          selected: _permissions.contains(entry.key),
                          onSelected: (selected) => setState(() {
                            _permissions = selected
                                ? [..._permissions, entry.key]
                                : _permissions.where((p) => p != entry.key).toList();
                          }),
                        ),
                    ],
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
                    title: 'برنامه کاری هفتگی',
                    subtitle: 'برای هر روز می‌توانید چند شیفت تعریف کنید',
                    actionLabel: 'تنظیمات پیشرفته',
                    onAction: () => context.push('/settings/hours'),
                  ),
                  const SizedBox(height: 12),
                  for (var day = 0; day < 7; day++) _buildDayRow(context, day),
                  const SizedBox(height: 8),
                  Text(
                    'روز جمعه به‌صورت پیش‌فرض تعطیل است و قابل فعال‌سازی است.',
                    style: TextStyle(fontSize: 10, color: pal.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SolidButton(label: 'ذخیره پرسنل', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SolidButton(
                    label: 'انصراف',
                    outlined: true,
                    onPressed: () => context.canPop() ? context.pop() : context.go('/employees'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, int day) {
    final pal = context.pal;
    final shifts = _schedule[day] ?? const <Shift>[];
    final enabled = shifts.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pal.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: enabled ? pal.primary.withValues(alpha: 0.35) : pal.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 62,
                  child: Text(
                    WeekDay.names[day],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: enabled ? pal.textPrimary : pal.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    enabled ? '${FaNum.ofInt(shifts.length)} شیفت' : 'تعطیل',
                    style: TextStyle(fontSize: 10.5, color: enabled ? pal.textSecondary : pal.danger),
                  ),
                ),
                Switch.adaptive(
                  value: enabled,
                  onChanged: (value) => setState(() {
                    _schedule[day] = value ? [const Shift(start: '09:00', end: '17:00')] : [];
                  }),
                  activeTrackColor: pal.primary,
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
            if (enabled)
              for (var index = 0; index < shifts.length; index++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TimeDropdown(
                          value: shifts[index].start,
                          onChanged: (v) => setState(() {
                            final list = [..._schedule[day]!];
                            list[index] = list[index].copyWith(start: v);
                            _schedule[day] = list;
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('تا', style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
                      ),
                      Expanded(
                        child: TimeDropdown(
                          value: shifts[index].end,
                          onChanged: (v) => setState(() {
                            final list = [..._schedule[day]!];
                            list[index] = list[index].copyWith(end: v);
                            _schedule[day] = list;
                          }),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: shifts.length == 1
                            ? null
                            : () => setState(() {
                                  final list = [..._schedule[day]!]..removeAt(index);
                                  _schedule[day] = list;
                                }),
                        icon: Icon(Icons.close_rounded, size: 15, color: pal.textMuted),
                      ),
                    ],
                  ),
                ),
            if (enabled)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _schedule[day] = [..._schedule[day]!, const Shift(start: '17:00', end: '21:00')];
                  }),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('شیفت جدید', style: TextStyle(fontSize: 10.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
