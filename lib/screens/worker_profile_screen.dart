import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _nameCtrl  = TextEditingController(text: 'Hamid Tazi');
  final _phoneCtrl = TextEditingController(text: '+212 661 23 45 67');
  final _bioCtrl   = TextEditingController(
      text: 'Plombier professionnel avec 8 ans d\'expérience.');
  final _cityCtrl  = TextEditingController(text: 'Casablanca');

  final List<String> _services    = ['Plomberie', 'Robinetterie', 'Sanitaires'];
  final List<String> _allServices = [
    'Plomberie',
    'Électricité',
    'Nettoyage',
    'Peinture',
    'Jardinage',
    'Robinetterie',
    'Sanitaires',
    'Carrelage',
    'Menuiserie',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: BrikolikColors.surface,
        foregroundColor: BrikolikColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: BrikolikColors.border, height: 1),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/job'),
            child: const Text(
              'Terminer',
              style: TextStyle(
                color: BrikolikColors.accent,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(context),
            const SizedBox(height: 24),
            _buildSectionCard(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Informations personnelles',
              child: Column(
                children: [
                  BrikolikInput(
                    hint: 'Votre nom',
                    label: 'Nom complet',
                    controller: _nameCtrl,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  BrikolikInput(
                    hint: '+212 6XX XXX XXX',
                    label: 'Téléphone',
                    controller: _phoneCtrl,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  BrikolikInput(
                    hint: 'Votre ville',
                    label: 'Ville',
                    controller: _cityCtrl,
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              context,
              icon: Icons.work_outline_rounded,
              title: 'À propos de moi',
              child: BrikolikInput(
                hint: 'Décrivez votre expérience et vos compétences...',
                controller: _bioCtrl,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              context,
              icon: Icons.build_circle_outlined,
              title: 'Mes services',
              subtitle: 'Sélectionnez vos domaines d\'expertise',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allServices.map((s) {
                  final selected = _services.contains(s);
                  return CategoryChip(
                    label: s,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _services.remove(s);
                        } else {
                          _services.add(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              context,
              icon: Icons.verified_outlined,
              title: 'Vérification',
              child: Column(
                children: [
                  _VerificationRow(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone vérifié',
                    verified: true,
                  ),
                  const Divider(height: 20),
                  _VerificationRow(
                    icon: Icons.badge_outlined,
                    label: 'CIN vérifiée',
                    verified: false,
                    action: 'Vérifier',
                  ),
                  const Divider(height: 20),
                  _VerificationRow(
                    icon: Icons.star_border_rounded,
                    label: 'Compétences certifiées',
                    verified: false,
                    action: 'Ajouter',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              'Enregistrer et continuer',
              () => Navigator.pushReplacementNamed(context, '/jobs'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const BrikolikAvatar(name: 'Hamid Tazi', size: 90),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: BrikolikColors.brandGradient,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: BrikolikColors.surface, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: BrikolikColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Hamid Tazi',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              StarRating(rating: 4.9, reviewCount: 47),
              SizedBox(width: 12),
              Icon(Icons.shield_rounded,
                  size: 14, color: BrikolikColors.success),
              SizedBox(width: 4),
              Text(
                'Profil vérifié',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: BrikolikColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BrikolikColors.primaryLight,
                  borderRadius: BorderRadius.circular(BrikolikRadius.sm),
                ),
                child:
                    Icon(icon, size: 16, color: BrikolikColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: BrikolikColors.brandGradient,
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.accent.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Verification Row ──────────────────────────
class _VerificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool verified;
  final String? action;

  const _VerificationRow({
    required this.icon,
    required this.label,
    required this.verified,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: BrikolikColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.titleSmall),
        ),
        if (verified)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrikolikColors.successLight,
              borderRadius:
                  BorderRadius.circular(BrikolikRadius.full),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded,
                    size: 12, color: BrikolikColors.success),
                SizedBox(width: 4),
                Text(
                  'Vérifié',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BrikolikColors.success,
                  ),
                ),
              ],
            ),
          )
        else if (action != null)
          Container(
            decoration: BoxDecoration(
              color: BrikolikColors.accentLight,
              borderRadius: BorderRadius.circular(BrikolikRadius.sm),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: BrikolikColors.accent,
              ),
              child: Text(
                action!,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
