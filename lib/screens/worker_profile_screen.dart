import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../widgets/verification_gate.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const List<String> _suggestedServices = [
    'Plomberie',
    'Electricite',
    'Nettoyage',
    'Peinture',
    'Jardinage',
    'Robinetterie',
    'Sanitaires',
    'Carrelage',
    'Menuiserie',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _customServiceCtrl = TextEditingController();

  final List<String> _services = <String>[];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isVerified = false;
  bool _verificationRequested = false;
  String? _email;

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
    _customServiceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _email = _auth.currentUser?.email ?? '';

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || !mounted) {
        return;
      }

      final data = doc.data()!;
      _isVerified = data['isVerified'] == true;
      _verificationRequested = data['verificationRequested'] == true;
      _nameCtrl.text = data['fullName'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _cityCtrl.text = data['city'] ?? '';
      _email = data['email'] ?? _email;

      final savedServices =
          List<String>.from(data['services'] ?? const <String>[]);
      _services
        ..clear()
        ..addAll(savedServices);
    } catch (e) {
      debugPrint('Erreur chargement profil artisan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _addCustomService() {
    final service = _customServiceCtrl.text.trim();
    if (service.isEmpty) return;

    final normalized = service.toLowerCase();
    final exists = _services.any((s) => s.toLowerCase() == normalized);

    if (exists) {
      _showMessage('Ce service existe deja.');
      return;
    }

    setState(() {
      _services.add(service);
      _customServiceCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleService(String service) {
    setState(() {
      if (_services.contains(service)) {
        _services.remove(service);
      } else {
        _services.add(service);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    if (!_isVerified) {
      _showMessage(
        'La verification admin est obligatoire avant de creer un profil artisan.',
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _showMessage('Session invalide. Reconnectez-vous.');
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_services.isEmpty) {
      _showMessage('Ajoutez au moins un service pour continuer.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _db.collection('users').doc(uid).set(
        {
          'fullName': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'bio': _bioCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'services': _services,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      _showMessage('Profil artisan enregistre avec succes.',
          color: BrikolikColors.success);
      Navigator.pushReplacementNamed(context, '/jobs');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: BrikolikColors.background,
        body: Center(
          child: CircularProgressIndicator(color: BrikolikColors.primary),
        ),
      );
    }

    final allServiceOptions = <String>{
      ..._suggestedServices,
      ..._services,
    }.toList();

    if (!_isVerified) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: const BrikolikAppBar(title: 'Mon profil artisan'),
        body: VerificationGate(
          title: 'Profil artisan verrouille',
          message:
              'Votre compte doit etre approuve par un administrateur avant de creer ou modifier votre profil artisan.',
          verificationRequested: _verificationRequested,
        ),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Mon profil artisan',
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text('Terminer'.tr(),
              style: TextStyle(
                fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                fontWeight: FontWeight.w700,
                color:
                    _isSaving ? BrikolikColors.textHint : BrikolikColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHero(
                      nameListenable: _nameCtrl,
                      cityListenable: _cityCtrl,
                      services: _services,
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Informations personnelles',
                      subtitle: 'Ces informations rassurent les clients.',
                      child: Column(
                        children: [
                          BrikolikInput(
                            hint: 'Votre nom complet',
                            label: 'Nom complet',
                            controller: _nameCtrl,
                            prefixIcon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le nom est obligatoire';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          BrikolikInput(
                            hint: '+212 6XX XXX XXX',
                            label: 'Telephone',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le telephone est obligatoire';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          BrikolikInput(
                            hint: 'Ex: Casablanca',
                            label: 'Ville',
                            controller: _cityCtrl,
                            prefixIcon: Icons.location_city_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La ville est obligatoire';
                              }
                              return null;
                            },
                          ),
                          if (_email != null && _email!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ReadOnlyField(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: _email!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.work_outline_rounded,
                      title: 'Presentation',
                      subtitle: 'Mettez en avant votre experience.',
                      child: BrikolikInput(
                        hint:
                            'Ex: Artisan avec 8 ans d experience en plomberie residentielle.',
                        label: 'Bio professionnelle',
                        controller: _bioCtrl,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ajoutez une breve presentation.';
                          }
                          if (value.trim().length < 20) {
                            return 'Ajoutez plus de details (20 caracteres min).';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      icon: Icons.build_circle_outlined,
                      title: 'Services proposes',
                      subtitle: 'Selectionnez vos domaines de specialite.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BrikolikInput(
                                  hint: 'Ajouter un service personnalise',
                                  controller: _customServiceCtrl,
                                  prefixIcon: Icons.add_task_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 106,
                                child: BrikolikButton(
                                  label: 'Ajouter',
                                  height: 48,
                                  onPressed: _addCustomService,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allServiceOptions
                                .map(
                                  (service) => FilterChip(
                                    label: Text(service),
                                    selected: _services.contains(service),
                                    onSelected: (_) => _toggleService(service),
                                    selectedColor: BrikolikColors.primaryLight,
                                    checkmarkColor: BrikolikColors.primary,
                                    labelStyle: TextStyle(
                                      fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                                      fontWeight: FontWeight.w700,
                                      color: _services.contains(service)
                                          ? BrikolikColors.primary
                                          : BrikolikColors.textSecondary,
                                    ),
                                    side: BorderSide(
                                      color: _services.contains(service)
                                          ? BrikolikColors.primary
                                          : BrikolikColors.border,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          if (_services.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Selectionnez au moins un service pour recevoir des missions.'
                                    .tr(),
                                style: TextStyle(
                                  fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BrikolikColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _VerificationCard(),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color: BrikolikColors.surface,
                border:
                    const Border(top: BorderSide(color: BrikolikColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: BrikolikColors.primary.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BrikolikButton(
                label: 'Enregistrer et continuer',
                icon: Icons.save_rounded,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.nameListenable,
    required this.cityListenable,
    required this.services,
  });

  final TextEditingController nameListenable;
  final TextEditingController cityListenable;
  final List<String> services;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([nameListenable, cityListenable]),
      builder: (context, _) {
        final name = nameListenable.text.trim().isEmpty
            ? 'Artisan Brikolik'
            : nameListenable.text.trim();
        final city = cityListenable.text.trim().isEmpty
            ? 'Ville non definie'
            : cityListenable.text.trim();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: BrikolikColors.brandGradient,
            borderRadius: BorderRadius.circular(BrikolikRadius.xl),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              BrikolikAvatar(name: name, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city,
                      style: TextStyle(
                        fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      services.isEmpty
                          ? 'Ajoutez vos specialites pour apparaitre dans les recherches.'
                          : services.take(3).join(' â€¢ '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BrikolikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: BrikolikColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BrikolikColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrikolikColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              size: 14, color: BrikolikColors.muted),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: const Column(
        children: [
          _VerificationRow(
              icon: Icons.email_outlined,
              label: 'Email verifie',
              verified: true),
          Divider(height: 20),
          _VerificationRow(
              icon: Icons.phone_outlined,
              label: 'Telephone verifie',
              verified: false),
          Divider(height: 20),
          _VerificationRow(
              icon: Icons.badge_outlined,
              label: 'Identite verifiee',
              verified: false),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.icon,
    required this.label,
    required this.verified,
  });

  final IconData icon;
  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: BrikolikColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: verified
                ? BrikolikColors.successLight
                : BrikolikColors.surfaceVariant,
            borderRadius: BorderRadius.circular(BrikolikRadius.full),
          ),
          child: Text(
            verified ? 'Verifie' : 'En attente',
            style: TextStyle(
              fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: verified
                  ? BrikolikColors.success
                  : BrikolikColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

