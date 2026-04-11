import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? _selectedRole;
  bool _isSaving = false;

  Future<void> _handleBack() async {
    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  Future<void> _continue() async {
    if (_selectedRole == null || _isSaving) return;
    setState(() => _isSaving = true);
    var isVerified = false;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final snapshot = await userRef.get();
        isVerified = snapshot.data()?['isVerified'] == true;
        await userRef.update({'role': _selectedRole});
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!mounted) return;
    if (_selectedRole == 'customer') {
      Navigator.pushNamed(context, '/customer-profile');
      return;
    }

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('role.worker_verification_required'.tr())),
      );
      Navigator.pushNamed(context, '/identity-verification');
      return;
    }

    Navigator.pushNamed(context, '/worker-profile');
  }

  @override
  Widget build(BuildContext context) {
    return BrikolikPageScaffold(
      title: '',
      onBackPressed: _handleBack,
      showBackButton: true,
      useBrandHeader: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
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
            top: 160,
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _RoleCard(
                          title: 'looking_for_service'.tr(),
                          subtitle: 'role.looking_for_service_subtitle'.tr(),
                          icon: Icons.home_repair_service_outlined,
                          features: [
                            'role.looking_feature_1'.tr(),
                            'role.looking_feature_2'.tr(),
                            'role.looking_feature_3'.tr(),
                          ],
                          selected: _selectedRole == 'customer',
                          onTap: () =>
                              setState(() => _selectedRole = 'customer'),
                        ),
                        const SizedBox(height: 14),
                        _RoleCard(
                          title: 'offer_services'.tr(),
                          subtitle: 'role.offer_services_subtitle'.tr(),
                          icon: Icons.handyman_outlined,
                          features: [
                            'role.offer_feature_1'.tr(),
                            'role.offer_feature_2'.tr(),
                            'role.offer_feature_3'.tr(),
                          ],
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
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(BrikolikRadius.md),
                                onTap: _selectedRole != null ? _continue : null,
                                child: SizedBox(
                                  height: 52,
                                  child: Center(
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('common.continue'.tr(),
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
                        ),
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
        const SizedBox(height: 18),
        Text('choose_role'.tr(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text('role.subtitle'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          border: Border.all(
            color: selected ? BrikolikColors.primary : BrikolikColors.border,
            width: selected ? 2 : 1,
          ),
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
              child: Icon(
                icon,
                color: selected ? Colors.white : BrikolikColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
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
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: BrikolikColors.textSecondary,
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

