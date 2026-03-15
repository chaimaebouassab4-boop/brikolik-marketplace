import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _RoleCard(
                title: 'Je cherche un service',
                subtitle:
                'Postez vos besoins et recevez des offres de pros qualifiés',
                emoji: '🏠',
                features: const [
                  'Trouvez des artisans près de chez vous',
                  'Comparez les offres et tarifs',
                  'Suivez vos demandes en temps réel',
                ],
                value: 'customer',
                selected: _selectedRole == 'customer',
                onTap: () => setState(() => _selectedRole = 'customer'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Je propose mes services',
                subtitle:
                'Développez votre activité et trouvez des clients facilement',
                emoji: '🔧',
                features: const [
                  'Gérez vos missions facilement',
                  'Obtenez des avis clients',
                  'Développez votre réputation',
                ],
                value: 'worker',
                selected: _selectedRole == 'worker',
                onTap: () => setState(() => _selectedRole = 'worker'),
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _selectedRole != null ? 1 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: BrikolikButton(
                  label: 'Continuer',
                  onPressed: _selectedRole != null ? _continue : null,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: BrikolikColors.primary,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 20),
        Text(
          'Comment\nvoulez-vous utiliser\nBrikolik ?',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez votre profil pour personnaliser votre expérience',
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? BrikolikColors.primaryLight : BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          border: Border.all(
            color: selected ? BrikolikColors.primary : BrikolikColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: BrikolikColors.primary.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected
                    ? BrikolikColors.primary
                    : BrikolikColors.surfaceVariant,
                borderRadius: BorderRadius.circular(BrikolikRadius.md),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
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
                      if (selected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: BrikolikColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BrikolikColors.border,
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ...features.map(
                        (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: selected
                                ? BrikolikColors.primary
                                : BrikolikColors.textHint,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            f,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? BrikolikColors.textPrimary
                                  : BrikolikColors.textSecondary,
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