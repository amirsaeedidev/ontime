import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/customer.dart';
import '../providers/customers_provider.dart';

/// فرم افزودن/ویرایش مشتری.
class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.customerId});

  final String? customerId;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  List<String> _tags = [];
  bool _saving = false;
  bool _prefilled = false;

  static const _tagOptions = ['وفادار', 'جدید', 'حساسیت پوستی', 'پیگیری', 'معرفی دوستان', 'بدون مراجعه'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    if (widget.customerId != null) {
      final customer = context.read<CustomersProvider>().findById(widget.customerId!);
      if (customer != null) {
        _nameController.text = customer.fullName;
        _phoneController.text = customer.phone;
        _noteController.text = customer.notes;
        _tags = [...customer.tags];
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<CustomersProvider>();
    final existing = widget.customerId == null ? null : provider.findById(widget.customerId!);
    final customer = (existing ?? Customer(
      id: 'cus-${DateTime.now().millisecondsSinceEpoch}',
      fullName: '',
      phone: '',
    )).copyWith(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _noteController.text.trim(),
      tags: _tags,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    if (existing != null) {
      await provider.update(customer);
    } else {
      await provider.create(customer);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, existing != null ? 'اطلاعات مشتری به‌روزرسانی شد' : 'مشتری جدید ثبت شد');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return PageScaffold(
      title: widget.customerId == null ? 'افزودن مشتری' : 'ویرایش مشتری',
      subtitle: 'اطلاعات پایه و یادداشت‌های داخلی',
      icon: Icons.person_add_alt_1_rounded,
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
                  AppTextField(
                    controller: _nameController,
                    label: 'نام و نام خانوادگی',
                    hint: 'مثلاً فاطمه احمدی',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => Validators.required(v, label: 'نام مشتری'),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _phoneController,
                    label: 'شماره موبایل',
                    hint: '۰۹۱۲۳۴۵۶۷۸۹',
                    icon: Icons.call_outlined,
                    keyboardType: TextInputType.phone,
                    numericFa: true,
                    validator: Validators.mobile,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _noteController,
                    label: 'یادداشت داخلی',
                    hint: 'نکات مهم درباره مشتری...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'برچسب‌ها',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: pal.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _tagOptions.length; i++)
                        FilterChip(
                          label: Text(_tagOptions[i]),
                          selected: _tags.contains(_tagOptions[i]),
                          onSelected: (selected) {
                            setState(() {
                              _tags = selected
                                  ? [..._tags, _tagOptions[i]]
                                  : _tags.where((t) => t != _tagOptions[i]).toList();
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SolidButton(
                    label: 'ذخیره',
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SolidButton(
                    label: 'انصراف',
                    outlined: true,
                    onPressed: () => context.canPop() ? context.pop() : context.go('/customers'),
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
