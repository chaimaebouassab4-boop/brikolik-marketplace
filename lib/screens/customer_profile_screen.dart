import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl  = TextEditingController();

  void _save() {
    Navigator.pushReplacementNamed(context, '/post-job');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: AppBar(
        title: const Text('Mon profil client'),
        backgroundColor: BrikolikColors.surface,
        foregroundColor: BrikolikColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: BrikolikColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header illustration
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: BrikolikColors.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BrikolikColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Complétez votre profil',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ces informations sont visibles par les artisans.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BrikolikColors.surface,
                borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                border: Border.all(color: BrikolikColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                          borderRadius:
                              BorderRadius.circular(BrikolikRadius.sm),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            size: 16, color: BrikolikColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('Informations personnelles',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BrikolikInput(
                    hint: 'Ex: Ahmed El Alami',
                    label: 'Nom complet',
                    controller: _nameCtrl,
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  BrikolikInput(
                    hint: '06 XX XX XX XX',
                    label: 'Téléphone',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 14),
                  BrikolikInput(
                    hint: 'Ex: Casablanca',
                    label: 'Ville',
                    controller: _cityCtrl,
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BrikolikColors.primaryLight,
                borderRadius: BorderRadius.circular(BrikolikRadius.md),
                border: Border.all(color: BrikolikColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: BrikolikColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Votre profil aide les artisans à mieux comprendre vos besoins.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BrikolikColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildGradientButton('Continuer', _save),
            const SizedBox(height: 24),
          ],
        ),
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
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

