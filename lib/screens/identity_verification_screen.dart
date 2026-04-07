import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await _authService.requestIdentityVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre demande a bien ete envoyee a l admin.'),
          backgroundColor: BrikolikColors.success,
        ),
      );
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d envoyer la demande: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _continueAfterApproval() async {
    final role = await _authService.getUserRole();
    if (!mounted) return;

    if (role == 'customer') {
      Navigator.pushReplacementNamed(context, '/customer-profile');
    } else if (role == 'worker') {
      Navigator.pushReplacementNamed(context, '/worker-profile');
    } else {
      Navigator.pushReplacementNamed(context, '/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: const BrikolikAppBar(title: 'Verification d identite'),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.lock_person_outlined,
            title: 'Connexion requise',
            subtitle:
                'Connectez-vous pour envoyer votre demande de verification.',
            actionLabel: 'Aller a la connexion',
            onAction: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: const BrikolikAppBar(title: 'Verification d identite'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrikolikColors.primary),
            );
          }

          final data = snapshot.data?.data() ?? const <String, dynamic>{};
          final isVerified = data['isVerified'] == true;
          final verificationRequested = data['verificationRequested'] == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VerificationHero(
                  isVerified: isVerified,
                  verificationRequested: verificationRequested,
                ),
                const SizedBox(height: 18),
                const _InfoCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Acces protege',
                  body:
                      'Avant de poster une mission ou publier un profil artisan, votre compte doit etre approuve manuellement par un administrateur.',
                ),
                const SizedBox(height: 12),
                const _InfoCard(
                  icon: Icons.schedule_outlined,
                  title: 'Ce qui se passe ensuite',
                  body:
                      'Une fois la demande envoyee, l equipe admin verifiera votre compte. Des que votre profil est approuve, vous pourrez continuer normalement dans l app.',
                ),
                const SizedBox(height: 24),
                if (isVerified)
                  BrikolikButton(
                    label: 'Continuer',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _continueAfterApproval,
                  )
                else if (verificationRequested)
                  const BrikolikButton(
                    label: 'Demande en attente',
                    icon: Icons.hourglass_top_rounded,
                    onPressed: null,
                    backgroundColor: BrikolikColors.textHint,
                  )
                else
                  BrikolikButton(
                    label: 'Verifier mon identite',
                    icon: Icons.verified_outlined,
                    isLoading: _isSubmitting,
                    onPressed: _submitRequest,
                  ),
                const SizedBox(height: 12),
                BrikolikButton(
                  label: 'Retour a l accueil',
                  outlined: true,
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VerificationHero extends StatelessWidget {
  const _VerificationHero({
    required this.isVerified,
    required this.verificationRequested,
  });

  final bool isVerified;
  final bool verificationRequested;

  @override
  Widget build(BuildContext context) {
    final Color accentColor;
    final IconData icon;
    final String title;
    final String subtitle;

    if (isVerified) {
      accentColor = BrikolikColors.success;
      icon = Icons.verified_user_rounded;
      title = 'Compte approuve';
      subtitle =
          'Votre identite a ete validee par l administrateur. Vous pouvez maintenant utiliser toutes les fonctionnalites.';
    } else if (verificationRequested) {
      accentColor = BrikolikColors.warning;
      icon = Icons.pending_actions_rounded;
      title = 'Demande envoyee';
      subtitle =
          'Votre verification est en cours de revue. Revenez ici plus tard ou reconnectez-vous pour verifier le statut.';
    } else {
      accentColor = BrikolikColors.primary;
      icon = Icons.shield_outlined;
      title = 'Verification requise';
      subtitle =
          'Protegez la plateforme et inspirez confiance. Envoyez votre demande pour activer les actions sensibles.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: BrikolikColors.brandGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(BrikolikRadius.full),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Text(
                    'Validation admin',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: BrikolikColors.primaryLight,
              borderRadius: BorderRadius.circular(BrikolikRadius.sm),
            ),
            child: Icon(icon, size: 18, color: BrikolikColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
