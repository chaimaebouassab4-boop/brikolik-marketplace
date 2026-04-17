import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../admin_sections.dart';

class AdminCard extends StatelessWidget {
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: BrikolikColors.textPrimary,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BrikolikColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AdminPill extends StatelessWidget {
  const AdminPill({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrikolikRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontFamilyFallback: const ['Cairo'],
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class AdminKpiCard extends StatelessWidget {
  const AdminKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    this.hint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
            ),
            child: Icon(icon, color: BrikolikColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrikolikColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrikolikColors.textHint,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.condensed,
  });

  final List<AdminSection> sections;
  final int selectedIndex;
  final bool condensed;
  final void Function(int index) onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<int>>{};
    for (var i = 0; i < sections.length; i++) {
      groups.putIfAbsent(sections[i].group, () => <int>[]).add(i);
    }

    return Container(
      color: BrikolikColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: condensed ? 12 : 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    borderRadius: BorderRadius.circular(BrikolikRadius.md),
                  ),
                  child: const Icon(
                    Icons.home_repair_service_outlined,
                    color: Colors.white,
                  ),
                ),
                if (!condensed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Brikolik Admin',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: BrikolikColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              children: groups.entries.expand((entry) {
                final title = entry.key;
                final idxs = entry.value;
                return [
                  if (!condensed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: BrikolikColors.textHint,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                      ),
                    ),
                  ...idxs.map((i) {
                    final s = sections[i];
                    final isSelected = i == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: isSelected
                            ? BrikolikColors.primaryLight
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(BrikolikRadius.md),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BrikolikRadius.md),
                          onTap: () => onSelect(i),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: condensed ? 10 : 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  s.icon,
                                  size: 22,
                                  color: isSelected
                                      ? BrikolikColors.primary
                                      : BrikolikColors.textSecondary,
                                ),
                                if (!condensed) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      s.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? BrikolikColors.primaryDark
                                                : BrikolikColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ];
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: BrikolikColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: condensed
                  ? OutlinedButton(
                      onPressed: onLogout,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      child: const Icon(Icons.logout),
                    )
                  : OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Deconnexion'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.title,
    required this.searchController,
    required this.onLogout,
    this.onMenu,
  });

  final String title;
  final TextEditingController searchController;
  final VoidCallback onLogout;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final showSearch = w >= 860;
        final showTitle = w >= 520;
        final searchWidth = w >= 1200 ? 360.0 : 320.0;

        return AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              if (onMenu != null) ...[
                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Row(
                  children: [
                    if (showTitle)
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (showSearch)
                SizedBox(
                  width: searchWidth,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher...',
                      isDense: true,
                      filled: true,
                      fillColor: BrikolikColors.surfaceVariant,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  tooltip: 'Rechercher',
                ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_outlined),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                tooltip: 'Compte',
                onSelected: (value) {
                  if (value == 'logout') onLogout();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Deconnexion'),
                  ),
                ],
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    borderRadius: BorderRadius.circular(BrikolikRadius.full),
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
