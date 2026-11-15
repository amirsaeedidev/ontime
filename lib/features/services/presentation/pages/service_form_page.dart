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
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/service.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../providers/services_provider.dart';

/// فرم افزودن/ویرایش خدمت با تنظیمات اختصاصی زمان‌بندی و قواعد رزرو.
class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({super.key, this.serviceId});

  final String? serviceId;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController(text: '45');
  final _prep = TextEditingController(text: '0');
  final _buffer = TextEditingController(text: '5');
  final _maxPerDay = TextEditingController();
  final _advanceDays = TextEditingController(text: '30');

  String _category = 'مو';
  bool _isActive = true;
  bool _requiresConfirmation = false;
  List<String> _employeeIds = [];
  bool _saving = false;
  bool _prefilled = false;
  Service? _existing;

  static const _categories = ['مو', 'ناخن', 'پوست', 'ماساژ', 'عمومی'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    if (widget.serviceId != null) {
      final service = context.read<ServicesProvider>().items.where((s) => s.id == widget.serviceId).firstOrNull;
      if (service != null) {
        _existing = service;
        _title.text = service.title;
        _description.text = service.description;
        _price.text = service.price.toString();
        _duration.text = service.durationMinutes.toString();
        _prep.text = service.prepMinutes.toString();
        _buffer.text = service.bufferMinutes.toString();
        _maxPerDay.text = service.maxPerDay?.toString() ?? '';
        _advanceDays.text = service.advanceDays.toString();
        _category = service.category;
        _isActive = service.isActive;
        _requiresConfirmation = service.requiresConfirmation;
        _employeeIds = [...service.employeeIds];
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();
    _prep.dispose();
    _buffer.dispose();
    _maxPerDay.dispose();
    _advanceDays.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ServicesProvider>();
    final service = (_existing ?? Service(id: provider.nextId(), title: '', price: 0, durationMinutes: 45)).copyWith(
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: num.tryParse(FaNum.toLatin(_price.text)) ?? 0,
      durationMinutes: int.tryParse(FaNum.toLatin(_duration.text)) ?? 45,
      prepMinutes: int.tryParse(FaNum.toLatin(_prep.text)) ?? 0,
      bufferMinutes: int.tryParse(FaNum.toLatin(_buffer.text)) ?? 5,
      maxPerDay: int.tryParse(FaNum.toLatin(_maxPerDay.text)),
      advanceDays: int.tryParse(FaNum.toLatin(_advanceDays.text)) ?? 30,
      category: _category,
      isActive: _isActive,
      requiresConfirmation: _requiresConfirmation,
      employeeIds: _employeeIds,
    );
    if (_existing != null) {
      await provider.update(service);
    } else {
      await provider.create(service);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, _existing != null ? 'خدمت به‌روزرسانی شد' : 'خدمت جدید ثبت شد');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/services');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final employees = context.watch<EmployeesProvider>().items;

    return PageScaffold(
      title: widget.serviceId == null ? 'خدمت جدید' : 'ویرایش خدمت',
      subtitle: 'تنظیمات قیمت، زمان و قواعد رزرو',
      icon: Icons.content_cut_rounded,
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final basic = AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'اطلاعات خدمت'),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _title,
                        label: 'عنوان خدمت',
                        hint: 'مثلاً کراتینه و ویتامینه',
                        icon: Icons.content_cut_rounded,
                        validator: (v) => Validators.required(v, label: 'عنوان خدمت'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _description,
                        label: 'توضیحات',
                        hint: 'توضیح کوتاه درباره خدمت...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _price,
                              label: 'قیمت (تومان)',
                              hint: '۵۵۰۰۰۰',
                              icon: Icons.sell_outlined,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                              validator: Validators.price,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'دسته‌بندی',
                              items: _categories,
                              value: _category,
                              onChanged: (v) => setState(() => _category = v ?? _category),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _duration,
                              label: 'مدت (دقیقه)',
                              icon: Icons.timelapse_rounded,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                              validator: (v) => Validators.positiveInt(v, label: 'مدت', min: 5, max: 480),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              controller: _prep,
                              label: 'آماده‌سازی (دقیقه)',
                              icon: Icons.hourglass_top_rounded,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              controller: _buffer,
                              label: 'استراحت (دقیقه)',
                              icon: Icons.pause_circle_outline_rounded,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                final rules = AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'زمان‌بندی و قواعد رزرو'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _advanceDays,
                              label: 'حداکثر روز رزرو جلوتر',
                              icon: Icons.date_range_rounded,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                              helper: 'مشتری تا چند روز آینده می‌تواند رزرو کند',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              controller: _maxPerDay,
                              label: 'حداکثر رزرو روزانه',
                              icon: Icons.filter_9_plus_rounded,
                              keyboardType: TextInputType.number,
                              numericFa: true,
                              helper: 'خالی = بدون محدودیت',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'متخصصان این خدمت',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: pal.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final employee in employees)
                            GestureDetector(
                              onTap: () => setState(() {
                                _employeeIds = _employeeIds.contains(employee.id)
                                    ? _employeeIds.where((id) => id != employee.id).toList()
                                    : [..._employeeIds, employee.id];
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _employeeIds.contains(employee.id)
                                      ? pal.primary.withValues(alpha: 0.18)
                                      : pal.surfaceAlt,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: _employeeIds.contains(employee.id) ? pal.primary : pal.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AvatarBadge(name: employee.fullName, size: 22, color: pal.primaryBright),
                                    const SizedBox(width: 6),
                                    Text(
                                      employee.fullName,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: pal.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppSwitchRow(
                        title: 'خدمت فعال است',
                        description: 'خدمات غیرفعال در صفحه رزرو نمایش داده نمی‌شوند.',
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        icon: Icons.toggle_on_outlined,
                      ),
                      AppSwitchRow(
                        title: 'نیاز به تأیید دستی',
                        description: 'نوبت‌های این خدمت در وضعیت «در انتظار» ثبت می‌شوند.',
                        value: _requiresConfirmation,
                        onChanged: (v) => setState(() => _requiresConfirmation = v),
                        icon: Icons.verified_outlined,
                      ),
                    ],
                  ),
                );

                if (!wide) {
                  return Column(children: [basic, const SizedBox(height: 12), rules]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: basic),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: rules),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SolidButton(label: 'ذخیره خدمت', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SolidButton(
                    label: 'انصراف',
                    outlined: true,
                    onPressed: () => context.canPop() ? context.pop() : context.go('/services'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
