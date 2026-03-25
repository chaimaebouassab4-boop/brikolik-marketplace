import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl   = TextEditingController();
  final _cityCtrl  = TextEditingController();

  final List<String> _services = [];
  final List<String> _allServices = [
    'Plomberie', 'Électricité', 'Nettoyage', 'Peinture',
    'Jardinage', 'Robinetterie', 'Sanitaires', 'Carrelage', 'Menuiserie',
  ];

  bool _isLoading = true;   // chargement initial
  bool _isSaving  = false;  // sauvegarde en cours
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
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── Charger les données depuis Firestore ──────────────────
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
        _bioCtrl.text   = data['bio']       ?? '';
        _cityCtrl.text  = data['city']      ?? '';
        _email          = data['email']     ?? _auth.currentUser?.email ?? '';
        final savedServices = List<String>.from(data['services'] ?? []);
        _services
          ..clear()
          ..addAll(savedServices);
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Sauvegarder dans Firestore ────────────────────────────
  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await _db.collection('users').doc(uid).update({
        'fullName': _nameCtrl.text.trim(),
        'phone':    _phoneCtrl.text.trim(),
        'bio':      _bioCtrl.text.trim(),
        'city':     _cityCtrl.text.trim(),
        'services': _services,
        'updatedAt': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil enregistré avec succès !'),
            backgroundColor: BrikolikColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/jobs');
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
        title: 'Mon profil artisan',
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Terminer',
              style: TextStyle(
                color: _isSaving ? BrikolikColors.muted : BrikolikColors.accent,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),

      // ── Corps ─────────────────────────────────────────────
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: BrikolikColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 24),

                  // Informations personnelles
                  _buildSectionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Informations personnelles',
                    child: Column(
                      children: [
                        BrikolikInput(
                          hint: 'Votre nom complet',
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
                                      const Text('Email',
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
                  const SizedBox(height: 14),

                  // Bio
                  _buildSectionCard(
                    icon: Icons.work_outline_rounded,
                    title: 'À propos de moi',
                    subtitle: 'Décrivez votre expérience',
                    child: BrikolikInput(
                      hint: 'Ex: Plombier professionnel avec 8 ans d\'expérience...',
                      controller: _bioCtrl,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Services
                  _buildSectionCard(
                    icon: Icons.build_circle_outlined,
                    title: 'Mes services',
                    subtitle: 'Sélectionnez vos domaines d\'expertise',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_services.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              '⚠️ Sélectionnez au moins un service',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: BrikolikColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Wrap(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Vérification
                  _buildSectionCard(
                    icon: Icons.verified_outlined,
                    title: 'Vérification',
                    child: Column(
                      children: [
                        _VerificationRow(
                          icon: Icons.email_outlined,
                          label: 'Email vérifié',
                          verified: _auth.currentUser?.emailVerified ?? false,
                          action: 'Vérifier',
                        ),
                        const Divider(height: 20),
                        const _VerificationRow(
                          icon: Icons.phone_outlined,
                          label: 'Téléphone vérifié',
                          verified: false,
                          action: 'Vérifier',
                        ),
                        const Divider(height: 20),
                        const _VerificationRow(
                          icon: Icons.badge_outlined,
                          label: 'CIN vérifiée',
                          verified: false,
                          action: 'Vérifier',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton sauvegarder
                  _buildSaveButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── Avatar section ────────────────────────────────────────
  Widget _buildAvatarSection() {
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Artisan';
    return AnimatedBuilder(
      animation: _nameCtrl,
      builder: (context, _) {
        final displayName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Artisan';
        return Center(
          child: Column(
            children: [
              Stack(
                children: [
                  BrikolikAvatar(name: displayName, size: 90),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: BrikolikColors.brandGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: BrikolikColors.surface, width: 2.5),
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
                ],
              ),
              const SizedBox(height: 14),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              if (_services.isNotEmpty)
                Text(
                  _services.take(2).join(' · '),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BrikolikColors.primary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Section card ──────────────────────────────────────────
  Widget _buildSectionCard({
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
                child: Icon(icon, size: 16, color: BrikolikColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null)
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Bouton sauvegarder ────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
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
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Enregistrer et continuer',
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
    );
  }
}

// ── Verification Row ──────────────────────────────────────────
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
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (verified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrikolikColors.successLight,
              borderRadius: BorderRadius.circular(BrikolikRadius.full),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 12, color: BrikolikColors.success),
                SizedBox(width: 4),
                Text('Vérifié',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: BrikolikColors.success,
                    )),
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
