import 'package:flutter/material.dart';

import '../../theme/eb_theme.dart';
import '../../utils/eb_formatters.dart';

/// Gold star + rating + review count, e.g. "★ 4.9 (312)".
class EbRatingBadge extends StatelessWidget {
  const EbRatingBadge({super.key, required this.rating, this.reviewCount, this.compact = false});

  final double rating;
  final int? reviewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: EbColors.gold),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: EbTextStyles.bodyStrong.copyWith(fontSize: compact ? 12 : 13),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: EbTextStyles.label.copyWith(fontSize: compact ? 11 : 12),
          ),
        ],
      ],
    );
  }
}

/// Pill for specialties, amenities, and downtime labels.
class EbPill extends StatelessWidget {
  const EbPill({
    super.key,
    required this.label,
    this.icon,
    this.color = EbColors.onBlush,
    this.background = EbColors.blush,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: EbTextStyles.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Serif overline + title, used to open content sections.
class EbSectionHeader extends StatelessWidget {
  const EbSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 12),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      subtitle!.toUpperCase(),
                      style: EbTextStyles.overline,
                    ),
                  ),
                Text(title, style: EbTextStyles.h3),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Consistent empty state with an illustration dot, message, and CTA.
class EbEmptyState extends StatelessWidget {
  const EbEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: EbColors.blush,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: EbColors.onBlush),
            ),
            const SizedBox(height: 16),
            Text(title, style: EbTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              message,
              style: EbTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card wrapper with consistent radius/shadow used across the app.
class EbCard extends StatelessWidget {
  const EbCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: EbColors.card,
        borderRadius: BorderRadius.circular(EbRadius.card),
        boxShadow: EbShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EbRadius.card),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Horizontal scrollable filter chip row (specialties / districts).
class EbChipScroller extends StatelessWidget {
  const EbChipScroller({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = labels[i];
          final isSel = selected == label;
          return ChoiceChip(
            label: Text(label),
            selected: isSel,
            onSelected: (v) => onSelected(v ? label : null),
            showCheckmark: false,
            labelStyle: EbTextStyles.label.copyWith(
              color: isSel ? Colors.white : EbColors.ink,
            ),
            selectedColor: EbColors.sageDeep,
            backgroundColor: Colors.white,
            side: BorderSide(color: isSel ? EbColors.sageDeep : EbColors.divider),
          );
        },
      ),
    );
  }
}

/// Small summary tile used on confirmation and dashboard.
class EbStatCard extends StatelessWidget {
  const EbStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return EbCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: EbColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: EbColors.onBlush),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: EbTextStyles.h3),
                Text(label, style: EbTextStyles.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Leading icon-in-circle used in list tiles.
class EbIconBadge extends StatelessWidget {
  const EbIconBadge({
    super.key,
    required this.icon,
    this.background = EbColors.blush,
    this.color = EbColors.onBlush,
    this.size = 42,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Formats a treatment's downtime as a pill with matching color.
class EbDowntimePill extends StatelessWidget {
  const EbDowntimePill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EbPill(label: label, icon: Icons.schedule, color: color, background: color.withValues(alpha: 0.14));
  }
}

/// Money text in the standard sage style.
class EbPrice extends StatelessWidget {
  const EbPrice({super.key, required this.amount, this.small = false});

  final int amount;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Text(
      EbFormatters.money(amount),
      style: small
          ? EbTextStyles.price.copyWith(fontSize: 13)
          : EbTextStyles.price,
    );
  }
}
