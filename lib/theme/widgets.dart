import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

// ─────────────────────────────────────────────
//  BRIKOLIK SHARED WIDGETS – Retro Purple & Blues
// ─────────────────────────────────────────────

// ── Primary CTA Button ────────────────────────
class BrikolikButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const BrikolikButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
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
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? BrikolikColors.primary,
            side: BorderSide(
                color: foregroundColor ?? BrikolikColors.primary, width: 1.5),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height ?? 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? BrikolikColors.accent,
          foregroundColor: foregroundColor ?? Colors.white,
        ),
        child: child,
      ),
    );
  }
}

// ── Secondary/Ghost Button ────────────────────
class BrikolikSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? height;

  const BrikolikSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: BrikolikColors.primary,
          side: const BorderSide(color: BrikolikColors.border, width: 1.5),
          backgroundColor: BrikolikColors.surfaceVariant,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
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
            ? Icon(prefixIcon, size: 20, color: BrikolikColors.muted)
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
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: BrikolikColors.accent,
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
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
        gradient: imageUrl == null ? BrikolikColors.brandGradient : null,
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
                  color: Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: BrikolikColors.muted,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Category Chip ─────────────────────────────
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
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: BrikolikColors.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : BrikolikColors.muted,
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: BrikolikColors.heroGradient,
                shape: BoxShape.circle,
                border: Border.all(color: BrikolikColors.border, width: 1),
              ),
              child: Icon(icon, size: 38, color: BrikolikColors.primary),
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

// ── Gradient Brand Logo Box ───────────────────
class BrikolikLogoBox extends StatelessWidget {
  final double size;
  final double iconSize;
  final IconData icon;

  const BrikolikLogoBox({
    super.key,
    this.size = 56,
    this.iconSize = 28,
    this.icon = Icons.build_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: BrikolikColors.brandGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

// ── Global AppBar ─────────────────────────────
class BrikolikAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool transparent;
  final bool useBrandBackground;
  final double? height;
  final bool showDivider;

  const BrikolikAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.transparent = false,
    this.useBrandBackground = true,
    this.height,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBrandBackground = useBrandBackground && !transparent;
    final Color foreground =
        hasBrandBackground || transparent ? Colors.white : BrikolikColors.textPrimary;

    return AppBar(
      systemOverlayStyle:
          hasBrandBackground ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      toolbarHeight: height ?? 72,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: hasBrandBackground ? BrikolikColors.brandGradient : null,
          color: hasBrandBackground
              ? null
              : (transparent ? Colors.transparent : BrikolikColors.surface),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: (transparent || !showDivider)
              ? null
              : Container(
                  height: 1,
                  color: hasBrandBackground
                      ? Colors.white.withOpacity(0.14)
                      : BrikolikColors.border,
                ),
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: foreground,
              ),
              onPressed: onBackPressed ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/welcome');
                }
              },
            )
          : null,
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 20,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/welcome', (route) => false),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Image.asset(
                  'lib/assets/lasgbrik-removebg-preview.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.home_rounded,
                    color: foreground,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight((height ?? 72) + (showDivider ? 1 : 0));
}

// ── Shared Bottom Navigation Bar ──────────────
class BrikolikBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BrikolikBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: BrikolikColors.primary,
          unselectedItemColor: BrikolikColors.textSecondary,
          onTap: (i) {
            if (onTap != null) {
              onTap!(i);
              return;
            }
            // Default navigation behavior
            switch (i) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                break;
              case 1:
                Navigator.pushNamed(context, '/jobs');
                break;
              case 2:
                Navigator.pushNamed(context, '/chat');
                break;
              case 3:
                Navigator.pushNamed(context, '/customer-profile');
                break;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              activeIcon: Icon(Icons.work_rounded),
              label: 'Missions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Layout helper to keep header/footer consistent ──────────────────────────
class BrikolikPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBottomNav;
  final int bottomNavIndex;
  final bool showBackButton;
  final bool useBrandHeader;
  final bool transparentAppBar;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const BrikolikPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBottomNav = false,
    this.bottomNavIndex = 0,
    this.showBackButton = true,
    this.useBrandHeader = true,
    this.transparentAppBar = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: title,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        transparent: transparentAppBar,
        useBrandBackground: useBrandHeader,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar:
          showBottomNav ? BrikolikBottomNav(currentIndex: bottomNavIndex) : null,
    );
  }
}

