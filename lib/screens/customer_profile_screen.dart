import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool _isLoading = true;
  bool _isSaving  = false;
  String? _email;

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Charger les donnÃ©es depuis Firestore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        _nameCtrl.text  = data['fullName']  ?? '';
        _phoneCtrl.text = data['phone']     ?? '';
        _cityCtrl.text  = data['city']      ?? '';
        _email          = data['email']     ?? _auth.currentUser?.email ?? '';
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // â”€â”€ Sauvegarder dans Firestore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await _db.collection('users').doc(uid).update({
        'fullName': _nameCtrl.text.trim(),
        'phone':    _phoneCtrl.text.trim(),
        'city':     _cityCtrl.text.trim(),
        'updatedAt': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil enregistre avec succes !'.tr()),
            backgroundColor: BrikolikColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/post-job');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Mon profil client',
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: BrikolikColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header illustration
                  _buildAvatarSection(),
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
                            Expanded(
                              child: Text('Informations personnelles'.tr(),
                                  style: Theme.of(context).textTheme.titleLarge),
                            ),
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
                          label: 'Telephone',
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
                        if (_email != null) ...[
                          const SizedBox(height: 14),
                          // Email en lecture seule
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: BrikolikColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(BrikolikRadius.md),
                              border: Border.all(color: BrikolikColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.email_outlined,
                                    size: 18, color: BrikolikColors.muted),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email'.tr(),
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 11,
                                            color: BrikolikColors.textSecondary,
                                          )),
                                      Text(_email!,
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: BrikolikColors.textPrimary,
                                          )),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.lock_outline_rounded,
                                    size: 14, color: BrikolikColors.muted),
                              ],
                            ),
                          ),
                        ],
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
                            'Votre profil aide les artisans a mieux comprendre vos besoins.'
                                .tr(),
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

                  // Bouton sauvegarder
                  GestureDetector(
                    onTap: _isSaving ? null : _save,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _isSaving ? null : BrikolikColors.brandGradient,
                        color: _isSaving ? BrikolikColors.surfaceVariant : null,
                        borderRadius: BorderRadius.circular(BrikolikRadius.md),
                        boxShadow: _isSaving
                            ? []
                            : [
                                BoxShadow(
                                  color: BrikolikColors.accent.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(BrikolikColors.primary),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Enregistrer et continuer'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // â”€â”€ Avatar section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: _nameCtrl,
      builder: (context, _) {
        final displayName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Client';
        return Center(
          child: Column(
            children: [
              BrikolikAvatar(name: displayName, size: 90),
              const SizedBox(height: 16),
              Text('Completez votre profil'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('Ces informations sont visibles par les artisans.'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

