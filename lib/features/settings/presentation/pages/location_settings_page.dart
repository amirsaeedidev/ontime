import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../providers/settings_provider.dart';

/// انتخاب موقعیت مکانی روی نقشه (شبیه‌سازی بدون API واقعی).
class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage> {
  double _lat = 35.7448;
  double _lng = 51.4099;
  final _address = TextEditingController();
  final _postal = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;
  Offset _marker = const Offset(0.5, 0.5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final settings = context.read<SettingsProvider>().settings;
    if (settings == null) return;
    _lat = settings.latitude;
    _lng = settings.longitude;
    _address.text = settings.address;
    _postal.text = settings.postalCode;
  }

  @override
  void dispose() {
    _address.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final provider = context.read<SettingsProvider>();
    final current = provider.settings;
    if (current != null) {
      await provider.saveBusiness(
        current.copyWith(latitude: _lat, longitude: _lng, address: _address.text.trim(), postalCode: _postal.text.trim()),
        logTitle: 'تغییر موقعیت مکانی',
        logDescription: 'مختصات و نشانی مجموعه به‌روزرسانی شد.',
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, 'موقعیت مکانی ذخیره شد');
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return PageScaffold(
      title: 'موقعیت مکانی',
      subtitle: 'انتخاب مختصات روی نقشه',
      icon: Icons.location_on_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final local = details.localPosition;
                        setState(() {
                          _marker = Offset(
                            (local.dx / constraints.maxWidth).clamp(0.02, 0.98),
                            (local.dy / 300).clamp(0.02, 0.98),
                          );
                          _lat = 35.60 + (1 - _marker.dy) * 0.30;
                          _lng = 51.20 + _marker.dx * 0.35;
                        });
                      },
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [pal.surfaceAlt, pal.background],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              CustomPaint(
                                size: Size.infinite,
                                painter: _MapGridPainter(
                                  gridColor: pal.border.withValues(alpha: 0.7),
                                  roadColor: pal.surfaceHigh,
                                  accent: pal.primary,
                                ),
                              ),
                              Positioned(
                                left: _marker.dx * constraints.maxWidth - 22,
                                top: _marker.dy * 300 - 44,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: pal.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: AppShadows.glow(pal.primary, opacity: 0.5, blur: 16),
                                      ),
                                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, color: pal.primary, size: 26),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: pal.backgroundAlt.withValues(alpha: 0.9),
                                    borderRadius: AppRadius.brPill,
                                    border: Border.all(color: pal.border),
                                  ),
                                  child: Text(
                                    'برای انتخاب موقعیت روی نقشه ضربه بزنید',
                                    style: TextStyle(fontSize: 9.5, color: pal.textSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _CoordField(label: 'عرض جغرافیایی', value: _lat.toStringAsFixed(4))),
                    const SizedBox(width: 8),
                    Expanded(child: _CoordField(label: 'طول جغرافیایی', value: _lng.toStringAsFixed(4))),
                    const SizedBox(width: 8),
                    SoftButton(label: 'موقعیت من', icon: Icons.my_location_rounded, dense: true, onTap: () {
                      setState(() {
                        _lat = 35.7448;
                        _lng = 51.4099;
                        _marker = const Offset(0.5, 0.5);
                      });
                    }),
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
                const SectionHeader(title: 'نشانی مجموعه'),
                const SizedBox(height: 12),
                AppTextField(controller: _address, label: 'نشانی کامل', maxLines: 2, icon: Icons.location_on_outlined),
                const SizedBox(height: 12),
                AppTextField(controller: _postal, label: 'کد پستی', numericFa: true, icon: Icons.markunread_mailbox_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatusBadge(
                        label: 'استان: ${context.watch<SettingsProvider>().settings?.province ?? '—'}',
                        color: pal.primaryBright,
                      ),
                    ),
                    Expanded(
                      child: StatusBadge(
                        label: 'شهر: ${context.watch<SettingsProvider>().settings?.city ?? '—'}',
                        color: pal.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'در این فاز نقشه به‌صورت طرح‌واره است و نیازی به کلید API ندارد. مختصات انتخابی ذخیره می‌شود (${FaNum.convert(_lat.toStringAsFixed(4))}، ${FaNum.convert(_lng.toStringAsFixed(4))}).',
                  style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SolidButton(label: 'ذخیره موقعیت', icon: Icons.save_rounded, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

class _CoordField extends StatelessWidget {
  const _CoordField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9.5, color: pal.textMuted)),
          Text(
            FaNum.convert(value),
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pal.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.gridColor, required this.roadColor, required this.accent});

  final Color gridColor;
  final Color roadColor;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i < 8; i++) {
      final dx = size.width * i / 8;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
    for (var i = 1; i < 6; i++) {
      final dy = size.height * i / 6;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
    final roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.32, 0), Offset(size.width * 0.38, size.height), roadPaint);
    final parkPaint = Paint()..color = accent.withValues(alpha: 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.12, size.width * 0.28, size.height * 0.24),
        const Radius.circular(14),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
}
