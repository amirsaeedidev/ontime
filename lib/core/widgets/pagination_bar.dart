import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../utils/fa_num.dart';

/// نوار صفحه‌بندی سازگار با موبایل و دسکتاپ.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
    required this.totalItems,
    this.pageSize = 8,
  });

  final int page;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final start = totalItems == 0 ? 0 : (page - 1) * pageSize + 1;
    final end = (page * pageSize).clamp(0, totalItems);

    List<int> pages = [];
    if (totalPages <= 5) {
      pages = [for (var i = 1; i <= totalPages; i++) i];
    } else if (page <= 3) {
      pages = [1, 2, 3, 4, -1, totalPages];
    } else if (page >= totalPages - 2) {
      pages = [1, -1, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
    } else {
      pages = [1, -1, page - 1, page, page + 1, -1, totalPages];
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            totalItems == 0
                ? 'موردی برای نمایش نیست'
                : 'نمایش ${FaNum.ofInt(start)} تا ${FaNum.ofInt(end)} از ${FaNum.ofInt(totalItems)} مورد',
            style: TextStyle(fontSize: 11.5, color: pal.textMuted),
          ),
        ),
        Row(
          children: [
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: page > 1,
              onTap: () => onPageChanged(page - 1),
            ),
            const SizedBox(width: 4),
            for (final p in pages) ...[
              if (p == -1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('…', style: TextStyle(color: pal.textMuted, fontSize: 12)),
                )
              else
                _PageButton(
                  page: p,
                  selected: p == page,
                  onTap: () => onPageChanged(p),
                ),
              const SizedBox(width: 4),
            ],
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: page < totalPages,
              onTap: () => onPageChanged(page + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.page, required this.selected, required this.onTap});

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? pal.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? pal.primary : pal.border),
        ),
        child: Text(
          FaNum.ofInt(page),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : pal.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: pal.border),
        ),
        child: Icon(icon, size: 16, color: enabled ? pal.textSecondary : pal.textMuted.withValues(alpha: 0.4)),
      ),
    );
  }
}

/// سربرگ ساده جدول برای نمایش دسکتاپ.
class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({super.key, required this.cells, this.flex = const []});

  final List<String> cells;
  final List<int> flex;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: pal.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i < flex.length ? flex[i] : 1,
              child: Text(
                cells[i],
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: pal.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
