import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────
//  BRIKOLIK SHARED WIDGETS
// ─────────────────────────────────────────────

// ── Primary CTA Button ────────────────────────
class BrikolikButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final double? height;

  const BrikolikButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    if (outlined) {
      return SizedBox(
        height: height ?? 52,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height ?? 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

// ── Input Field ───────────────────────────────
class BrikolikInput extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  const BrikolikInput({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixWidget,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: BrikolikColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: BrikolikColors.textHint)
            : null,
        suffixIcon: suffixWidget,
      ),
    );
  }
}

// ── Section Header ────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

// ── Status Badge ──────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusBadge.open() => const StatusBadge(
    label: 'Ouvert',
    color: BrikolikColors.success,
    bgColor: BrikolikColors.successLight,
  );

  factory StatusBadge.inProgress() => const StatusBadge(
    label: 'En cours',
    color: BrikolikColors.warning,
    bgColor: BrikolikColors.warningLight,
  );

  factory StatusBadge.closed() => const StatusBadge(
    label: 'Terminé',
    color: BrikolikColors.textSecondary,
    bgColor: BrikolikColors.surfaceVariant,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrikolikRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Avatar with initials fallback ─────────────
class BrikolikAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const BrikolikAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 44,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BrikolikColors.primaryLight,
        image: imageUrl != null
            ? DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: imageUrl == null
          ? Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
            color: BrikolikColors.primary,
          ),
        ),
      )
          : null,
    );
  }
}

// ── Star Rating Row ───────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;

  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: starSize, color: BrikolikColors.star),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: starSize,
            fontWeight: FontWeight.w700,
            color: BrikolikColors.textPrimary,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: starSize - 1,
              fontWeight: FontWeight.w500,
              color: BrikolikColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Divider with label ────────────────────────
class DividerWithLabel extends StatelessWidget {
  final String label;

  const DividerWithLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Info Chip (category tag) ──────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? BrikolikColors.primary : BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.full),
          border: Border.all(
            color: selected ? BrikolikColors.primary : BrikolikColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : BrikolikColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : BrikolikColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BrikolikColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: BrikolikColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              BrikolikButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}