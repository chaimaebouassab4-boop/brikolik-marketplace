import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class VerificationGate extends StatelessWidget {
  const VerificationGate({
    super.key,
    required this.title,
    required this.message,
    required this.verificationRequested,
  });

  final String title;
  final String message;
  final bool verificationRequested;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(BrikolikRadius.xl),
            border: Border.all(color: BrikolikColors.border),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: BrikolikColors.brandGradient,
                  borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: BrikolikColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BrikolikColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (verificationRequested)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: BrikolikColors.warningLight,
                    borderRadius: BorderRadius.circular(BrikolikRadius.full),
                  ),
                  child: const Text(
                    'Demande deja envoyee a l admin',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: BrikolikColors.warning,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              BrikolikButton(
                label: verificationRequested
                    ? 'Voir le statut'
                    : 'Verifier mon identite',
                icon: verificationRequested
                    ? Icons.visibility_outlined
                    : Icons.verified_outlined,
                onPressed: () =>
                    Navigator.pushNamed(context, '/identity-verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
