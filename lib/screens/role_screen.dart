import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? _selectedRole; // 'customer' | 'worker'

  void _continue() {
    if (_selectedRole == null) return;
    if (_selectedRole == 'customer') {
      Navigator.pushReplacementNamed(context, '/customer-profile');
    } else {
      Navigator.pushReplacementNamed(context, '/worker-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF465892), Color(0xFF6D5593)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: BrikolikColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _RoleCard(
                          title: 'Je cherche un service',
                          subtitle:
                              'Postez vos besoins et recevez des offres de pros qualifies',
                          emoji: '🏠',
                          features: const [
                            'Trouvez des artisans pres de chez vous',
                            'Comparez les offres et tarifs',
                            'Suivez vos demandes en temps reel',
                          ],
                          value: 'customer',
                          selected: _selectedRole == 'customer',
                          onTap: () => setState(() => _selectedRole = 'customer'),
                        ),
                        const SizedBox(height: 14),
                        _RoleCard(
                          title: 'Je propose mes services',
                          subtitle:
                              'Developpez votre activite et trouvez des clients facilement',
                          emoji: '🔧',
                          features: const [
                            'Gerez vos missions facilement',
                            'Obtenez des avis clients',
                            'Developpez votre reputation',
                          ],
                          value: 'worker',
                          selected: _selectedRole == 'worker',
                          onTap: () => setState(() => _selectedRole = 'worker'),
                        ),
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: _selectedRole != null ? 1 : 0.45,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _selectedRole != null
                                  ? BrikolikColors.brandGradient
                                  : null,
                              color: _selectedRole == null
                                  ? BrikolikColors.surfaceVariant
                                  : null,
                              borderRadius:
                                  BorderRadius.circular(BrikolikRadius.md),
                              boxShadow: _selectedRole != null
                                  ? [
                                      BoxShadow(
                                        color: BrikolikColors.accent.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(BrikolikRadius.md),
                                onTap: _selectedRole != null ? _continue : null,
                                child: Container(
                                  height: 52,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continuer',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedRole != null
                                              ? Colors.white
                                              : BrikolikColors.textHint,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: _selectedRole != null
                                            ? Colors.white
                                            : BrikolikColors.textHint,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(BrikolikRadius.sm),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Comment\nvoulez-vous utiliser\nBrikolik ?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 60),
        Text(
          'Choisissez votre profil pour personnaliser votre experience',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<String> features;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.features,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          border: Border.all(
            color: selected ? BrikolikColors.primary : BrikolikColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: BrikolikColors.primary.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: selected ? BrikolikColors.brandGradient : null,
                color: selected ? null : BrikolikColors.surfaceVariant,
                borderRadius: BorderRadius.circular(BrikolikRadius.md),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: selected ? BrikolikColors.brandGradient : null,
                          color: selected ? null : Colors.transparent,
                          shape: BoxShape.circle,
                          border: selected
                              ? null
                              : Border.all(
                                  color: BrikolikColors.border,
                                  width: 2,
                                ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: selected
                                ? BrikolikColors.primary
                                : BrikolikColors.frostSilver,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? BrikolikColors.textSecondary
                                    : BrikolikColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
