import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../widgets/contact_actions.dart';
import '../widgets/verification_gate.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  static const int _maxPortfolioPhotos = 8;
  static const Duration _saveTimeout = Duration(seconds: 35);
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
  final List<String> _portfolioPhotoUrls = <String>[];
  final List<String> _originalPortfolioPhotoUrls = <String>[];
  final List<_LocalPortfolioPhoto> _newPortfolioPhotos =
      <_LocalPortfolioPhoto>[];
  final ImagePicker _picker = ImagePicker();

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

      final savedPortfolio =
          List<String>.from(data['portfolioPhotoUrls'] ?? const <String>[]);
      _portfolioPhotoUrls
        ..clear()
        ..addAll(savedPortfolio);
      _originalPortfolioPhotoUrls
        ..clear()
        ..addAll(savedPortfolio);
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

  Future<T> _withSaveTimeout<T>(Future<T> future, String action) {
    return future.timeout(
      _saveTimeout,
      onTimeout: () => throw TimeoutException(action, _saveTimeout),
    );
  }

  String _saveErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Enregistrement trop long pendant: ${error.message}. Verifiez Firebase Storage et votre connexion.';
    }
    if (error is FirebaseException) {
      if (error.plugin == 'firebase_storage') {
        return 'Upload photo impossible: ${error.message ?? error.code}. Verifiez que Firebase Storage est active et que les regles sont deployees.';
      }
      return 'Erreur Firebase: ${error.message ?? error.code}';
    }
    return 'Erreur: $error';
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'Le telephone est obligatoire';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Numero de telephone invalide';
    return null;
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

  Future<void> _pickPortfolioPhotos() async {
    final remaining = _maxPortfolioPhotos -
        _portfolioPhotoUrls.length -
        _newPortfolioPhotos.length;
    if (remaining <= 0) {
      _showMessage('Limite de 8 photos portfolio maximum.');
      return;
    }

    final picked = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1800,
    );
    if (picked.isEmpty) return;

    final limited = picked.take(remaining).toList();
    final files = <_LocalPortfolioPhoto>[];
    for (final item in limited) {
      final bytes = await item.readAsBytes();
      files.add(
        _LocalPortfolioPhoto(
          id: '${DateTime.now().millisecondsSinceEpoch}-${item.name}',
          bytes: bytes,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _newPortfolioPhotos.addAll(files));

    if (picked.length > remaining) {
      _showMessage('Limite de 8 photos portfolio maximum.');
    }
  }

  void _removeSavedPortfolioPhoto(String url) {
    setState(() => _portfolioPhotoUrls.remove(url));
  }

  void _removeNewPortfolioPhoto(String id) {
    setState(() => _newPortfolioPhotos.removeWhere((photo) => photo.id == id));
  }

  Future<List<String>> _uploadPortfolioPhotos(String uid) async {
    if (_newPortfolioPhotos.isEmpty) return <String>[];

    final urls = <String>[];
    for (var i = 0; i < _newPortfolioPhotos.length; i++) {
      final photo = _newPortfolioPhotos[i];
      final ref = FirebaseStorage.instance
          .ref()
          .child(
            'users/$uid/portfolio/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );

      await _withSaveTimeout(
        ref.putData(
          photo.bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: const <String, String>{
              'type': 'portfolio',
            },
          ),
        ),
        'upload photo portfolio',
      );
      urls.add(
        await _withSaveTimeout(
          ref.getDownloadURL(),
          'recuperation URL photo',
        ),
      );
    }
    return urls;
  }

  Future<void> _deletePortfolioUrls(List<String> urls) async {
    for (final url in urls) {
      try {
        await _withSaveTimeout(
          FirebaseStorage.instance.refFromURL(url).delete(),
          'suppression photo portfolio',
        );
      } catch (e) {
        debugPrint('Suppression portfolio ignoree: $e');
      }
    }
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
      final removedPortfolioUrls = _originalPortfolioPhotoUrls
          .where((url) => !_portfolioPhotoUrls.contains(url))
          .toList();
      final uploadedPortfolioUrls = await _uploadPortfolioPhotos(uid);
      final mergedPortfolioUrls = <String>[
        ..._portfolioPhotoUrls,
        ...uploadedPortfolioUrls,
      ];

      await _withSaveTimeout(
        _db.collection('users').doc(uid).set(
          {
            'fullName': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'bio': _bioCtrl.text.trim(),
            'city': _cityCtrl.text.trim(),
            'services': _services,
            'portfolioPhotoUrls': mergedPortfolioUrls,
            'portfolioPhotosCount': mergedPortfolioUrls.length,
            'portfolioUpdatedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        ),
        'sauvegarde profil',
      );

      await _deletePortfolioUrls(removedPortfolioUrls);

      _portfolioPhotoUrls
        ..clear()
        ..addAll(mergedPortfolioUrls);
      _originalPortfolioPhotoUrls
        ..clear()
        ..addAll(mergedPortfolioUrls);
      _newPortfolioPhotos.clear();

      if (!mounted) return;
      _showMessage('Profil artisan enregistre avec succes.',
          color: BrikolikColors.success);
      Navigator.pushReplacementNamed(context, '/jobs');
    } catch (e) {
      if (!mounted) return;
      _showMessage(_saveErrorMessage(e));
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
                            label: 'Telephone obligatoire',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              return _validatePhone(value);
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
                    ContactActions(
                      phone: _phoneCtrl.text,
                      title: 'Contact artisan',
                      subtitle:
                          'Ajoutez votre numero pour activer WhatsApp et appel.',
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
                    _SectionCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Galerie portfolio',
                      subtitle:
                          'Ajoutez vos realisations, avant/apres et photos de chantiers.',
                      child: _PortfolioGalleryCard(
                        maxPhotos: _maxPortfolioPhotos,
                        savedUrls: _portfolioPhotoUrls,
                        localPhotos: _newPortfolioPhotos,
                        onAddPhotos: _pickPortfolioPhotos,
                        onRemoveSaved: _removeSavedPortfolioPhoto,
                        onRemoveLocal: _removeNewPortfolioPhoto,
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

class _PortfolioGalleryCard extends StatelessWidget {
  const _PortfolioGalleryCard({
    required this.maxPhotos,
    required this.savedUrls,
    required this.localPhotos,
    required this.onAddPhotos,
    required this.onRemoveSaved,
    required this.onRemoveLocal,
  });

  final int maxPhotos;
  final List<String> savedUrls;
  final List<_LocalPortfolioPhoto> localPhotos;
  final VoidCallback onAddPhotos;
  final void Function(String url) onRemoveSaved;
  final void Function(String id) onRemoveLocal;

  @override
  Widget build(BuildContext context) {
    final total = savedUrls.length + localPhotos.length;
    final canAddMore = total < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BrikolikColors.surfaceVariant,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          child: Text(
            'Ajoutez jusqu a $maxPhotos photos. Elles seront sauvegardees dans Firebase Storage et les URLs seront liees a votre document utilisateur.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final url in savedUrls)
              _PortfolioTile.network(
                url: url,
                onRemove: () => onRemoveSaved(url),
              ),
            for (final photo in localPhotos)
              _PortfolioTile.memory(
                bytes: photo.bytes,
                onRemove: () => onRemoveLocal(photo.id),
              ),
            if (canAddMore)
              GestureDetector(
                onTap: onAddPhotos,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: BrikolikColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(BrikolikRadius.md),
                    border: Border.all(color: BrikolikColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: BrikolikColors.primary,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontFamilyFallback: ['Cairo'],
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: BrikolikColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Ajoutez quelques photos pour renforcer la confiance et augmenter vos conversions.'
                  .tr(),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontFamilyFallback: ['Cairo'],
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: BrikolikColors.warning,
              ),
            ),
          ),
      ],
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile.network({
    required this.url,
    required this.onRemove,
  })  : bytes = null,
        isNetwork = true;

  const _PortfolioTile.memory({
    required this.bytes,
    required this.onRemove,
  })  : url = null,
        isNetwork = false;

  final String? url;
  final Uint8List? bytes;
  final VoidCallback onRemove;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          child: isNetwork
              ? Image.network(
                  url!,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                )
              : Image.memory(
                  bytes!,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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

class _LocalPortfolioPhoto {
  const _LocalPortfolioPhoto({
    required this.id,
    required this.bytes,
  });

  final String id;
  final Uint8List bytes;
}

