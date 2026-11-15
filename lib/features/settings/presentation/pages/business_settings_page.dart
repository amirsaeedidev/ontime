import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../providers/settings_provider.dart';

/// اطلاعات مجموعه: نام، تماس، آدرس و شبکه‌های اجتماعی.
class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _slogan = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _postal = TextEditingController();
  final _instagram = TextEditingController();
  final _telegram = TextEditingController();
  final _whatsapp = TextEditingController();
  final _website = TextEditingController();
  final _slug = TextEditingController();

  String _province = 'تهران';
  String _city = 'تهران';
  bool _saving = false;
  bool _prefilled = false;

  static const _provinces = ['تهران', 'البرز', 'اصفهان', 'فارس', 'خراسان رضوی', 'آذربایجان شرقی', 'گیلان', 'یزد'];
  static const _cities = ['تهران', 'کرج', 'اصفهان', 'شیراز', 'مشهد', 'تبریز', 'رشت', 'یزد'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final settings = context.read<SettingsProvider>().settings;
    if (settings == null) return;
    _name.text = settings.name;
    _slogan.text = settings.slogan;
    _description.text = settings.description;
    _phone.text = settings.phone;
    _mobile.text = settings.mobile;
    _email.text = settings.email;
    _address.text = settings.address;
    _postal.text = settings.postalCode;
    _instagram.text = settings.instagram;
    _telegram.text = settings.telegram;
    _whatsapp.text = settings.whatsapp;
    _website.text = settings.website;
    _slug.text = settings.publicSlug;
    _province = settings.province;
    _city = settings.city;
  }

  @override
  void dispose() {
    for (final controller in [
      _name, _slogan, _description, _phone, _mobile, _email,
      _address, _postal, _instagram, _telegram, _whatsapp, _website, _slug,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<SettingsProvider>();
    final current = provider.settings;
    if (current == null) return;
    await provider.saveBusiness(
      current.copyWith(
        name: _name.text.trim(),
        slogan: _slogan.text.trim(),
        description: _description.text.trim(),
        phone: _phone.text.trim(),
        mobile: _mobile.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        postalCode: _postal.text.trim(),
        province: _province,
        city: _city,
        instagram: _instagram.text.trim(),
        telegram: _telegram.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        website: _website.text.trim(),
        publicSlug: _slug.text.trim(),
        logoText: _name.text.trim().isEmpty ? 'OT' : _name.text.trim().substring(0, 2),
      ),
      logTitle: 'ویرایش اطلاعات مجموعه',
      logDescription: 'اطلاعات پایه مجموعه به‌روزرسانی شد.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, 'اطلاعات مجموعه ذخیره شد');
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return PageScaffold(
      title: 'اطلاعات مجموعه',
      subtitle: 'پروفایل عمومی و اطلاعات تماس',
      icon: Icons.storefront_rounded,
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
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: pal.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _name.text.isEmpty ? 'OT' : _name.text.substring(0, _name.text.length > 1 ? 2 : 1),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لوگوی مجموعه',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                            Text(
                              'در این فاز حروف اول نام به‌عنوان لوگو نمایش داده می‌شود (آماده Supabase Storage).',
                              style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      SoftButton(label: 'تغییر', icon: Icons.upload_rounded, dense: true, onTap: () => AppToast.show(context, 'بارگذاری تصویر در فاز بعدی')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _name,
                    label: 'نام مجموعه',
                    icon: Icons.storefront_outlined,
                    validator: (v) => Validators.required(v, label: 'نام مجموعه'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: _slogan, label: 'شعار', icon: Icons.campaign_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: _description, label: 'توضیحات', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'اطلاعات تماس و نشانی'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _phone,
                          label: 'تلفن ثابت',
                          icon: Icons.call_outlined,
                          numericFa: true,
                          validator: (v) => Validators.required(v, label: 'تلفن'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _mobile,
                          label: 'موبایل',
                          icon: Icons.phone_iphone_rounded,
                          numericFa: true,
                          validator: Validators.mobile,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: _email, label: 'ایمیل', icon: Icons.mail_outline_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'استان',
                          items: _provinces,
                          value: _province,
                          onChanged: (v) => setState(() => _province = v ?? _province),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'شهر',
                          items: _cities,
                          value: _city,
                          onChanged: (v) => setState(() => _city = v ?? _city),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: _address, label: 'نشانی', icon: Icons.location_on_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _postal,
                    label: 'کد پستی',
                    icon: Icons.markunread_mailbox_outlined,
                    numericFa: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'شبکه‌های اجتماعی و لینک عمومی'),
                  const SizedBox(height: 14),
                  AppTextField(controller: _instagram, label: 'اینستاگرام', icon: Icons.camera_alt_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: _telegram, label: 'تلگرام', icon: Icons.send_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: _whatsapp, label: 'واتس‌اپ', icon: Icons.chat_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: _website, label: 'وب‌سایت', icon: Icons.language_rounded),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _slug,
                    label: 'شناسه صفحه رزرو (slug)',
                    icon: Icons.link_rounded,
                    helper: 'مثال: ontime.app/book/ontime-salon',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SolidButton(label: 'ذخیره تغییرات', icon: Icons.save_rounded, loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
