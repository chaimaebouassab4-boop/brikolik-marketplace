import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../widgets/verification_gate.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  static const List<_JobCategory> _categories = [
    _JobCategory('Plomberie', Icons.water_drop_outlined),
    _JobCategory('Electricite', Icons.bolt_outlined),
    _JobCategory('Nettoyage', Icons.cleaning_services_outlined),
    _JobCategory('Peinture', Icons.format_paint_outlined),
    _JobCategory('Jardinage', Icons.grass_outlined),
    _JobCategory('Menuiserie', Icons.carpenter_outlined),
    _JobCategory('Maconnerie', Icons.construction_outlined),
    _JobCategory('Autre', Icons.more_horiz_rounded),
  ];

  static const List<_UrgencyOption> _urgencyOptions = [
    _UrgencyOption(
        'Urgent (24h)', Icons.flash_on_rounded, BrikolikColors.error),
    _UrgencyOption(
        'Cette semaine', Icons.today_rounded, BrikolikColors.warning),
    _UrgencyOption(
        'Ce mois', Icons.calendar_month_outlined, BrikolikColors.primary),
    _UrgencyOption('Flexible', Icons.schedule_rounded, BrikolikColors.success),
  ];

  static const List<String> _steps = ['Categorie', 'Details', 'Budget'];

  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _budgetFormKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _budgetMinCtrl = TextEditingController();
  final TextEditingController _budgetMaxCtrl = TextEditingController();

  int _currentStep = 0;
  bool _isAccessLoading = true;
  bool _isSubmitting = false;
  bool _isVerified = false;
  bool _verificationRequested = false;
  String? _selectedCategory;
  String? _selectedUrgency;

  @override
  void initState() {
    super.initState();
    _loadAccessStatus();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccessStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() => _isAccessLoading = false);
      }
      return;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data() ?? const <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _isVerified = data['isVerified'] == true;
        _verificationRequested = data['verificationRequested'] == true;
      });
    } catch (_) {
      // Leave default values and keep the feature locked if user data cannot be read.
    } finally {
      if (mounted) {
        setState(() => _isAccessLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_selectedCategory == null) {
        _showMessage('Selectionnez une categorie pour continuer.');
        return false;
      }
      return true;
    }

    if (_currentStep == 1) {
      final valid = _detailsFormKey.currentState?.validate() ?? false;
      if (!valid) return false;
      if (_selectedUrgency == null) {
        _showMessage('Choisissez un niveau d urgence.');
        return false;
      }
      return true;
    }

    final valid = _budgetFormKey.currentState?.validate() ?? false;
    if (!valid) return false;

    final min = int.tryParse(_budgetMinCtrl.text.trim()) ?? 0;
    final max = int.tryParse(_budgetMaxCtrl.text.trim()) ?? 0;
    if (max < min) {
      _showMessage('Le budget maximum doit etre superieur au minimum.');
      return false;
    }

    return true;
  }

  void _goToNextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep += 1);
    } else {
      _submitJob();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep -= 1);
  }

  Future<void> _submitJob() async {
    if (!_validateCurrentStep()) return;

    if (!_isVerified) {
      _showMessage('Verification admin requise avant de poster une mission.');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showMessage('Veuillez vous authentifier.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userName = userDoc.data()?['fullName'] ?? 'Client';
      final budgetMin = int.tryParse(_budgetMinCtrl.text.trim()) ?? 0;
      final budgetMax = int.tryParse(_budgetMaxCtrl.text.trim()) ?? 0;

      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'location': _locationCtrl.text.trim(),
        'urgency': _selectedUrgency,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'budget': '$budgetMin-$budgetMax MAD',
        'customerId': uid,
        'customerName': userName,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'offersCount': 0,
        'rating': 0.0,
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/jobs');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAccessLoading) {
      return const Scaffold(
        backgroundColor: BrikolikColors.background,
        body: Center(
          child: CircularProgressIndicator(color: BrikolikColors.primary),
        ),
      );
    }

    if (!_isVerified) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: BrikolikAppBar(
          title: 'Poster un service',
          onBackPressed: _goToPreviousStep,
        ),
        body: VerificationGate(
          title: 'Verification necessaire',
          message:
              'Votre compte doit etre valide par un administrateur avant de pouvoir poster une mission.',
          verificationRequested: _verificationRequested,
        ),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Poster un service',
        onBackPressed: _goToPreviousStep,
      ),
      body: Column(
        children: [
          _ProgressHeader(currentStep: _currentStep, steps: _steps),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey<int>(_currentStep),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _buildStepContent(),
              ),
            ),
          ),
          _BottomActions(
            isLast: _currentStep == _steps.length - 1,
            isSubmitting: _isSubmitting,
            onBack: _goToPreviousStep,
            onNext: _goToNextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStep();
      case 1:
        return _buildDetailsStep();
      default:
        return _buildBudgetStep();
    }
  }

  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel service cherchez-vous ?',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Choisissez une categorie pour recevoir des offres plus precises.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GridView.builder(
          itemCount: _categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = _categories[index];
            final selected = _selectedCategory == item.label;

            return Material(
              color: BrikolikColors.surface,
              borderRadius: BorderRadius.circular(BrikolikRadius.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                onTap: () => setState(() => _selectedCategory = item.label),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                    gradient: selected ? BrikolikColors.brandGradient : null,
                    border: Border.all(
                      color:
                          selected ? Colors.transparent : BrikolikColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? BrikolikColors.primary.withValues(alpha: 0.22)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: selected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.2)
                              : BrikolikColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color:
                              selected ? Colors.white : BrikolikColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : BrikolikColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _detailsFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Decrivez votre besoin',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Plus votre demande est claire, plus les offres seront pertinentes.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          BrikolikInput(
            hint: 'Ex: Fuite d eau sous le lavabo',
            label: 'Titre de la demande',
            controller: _titleCtrl,
            prefixIcon: Icons.title_rounded,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le titre est obligatoire';
              }
              if (value.trim().length < 8) {
                return 'Ajoutez plus de details (8 caracteres min).';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          BrikolikInput(
            hint: 'Precisez ce qu il faut faire et le contexte.',
            label: 'Description',
            controller: _descCtrl,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La description est obligatoire';
              }
              if (value.trim().length < 20) {
                return 'Donnez plus de contexte (20 caracteres min).';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          BrikolikInput(
            hint: 'Ex: Casablanca, Maarif',
            label: 'Adresse ou quartier',
            controller: _locationCtrl,
            prefixIcon: Icons.location_on_outlined,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le lieu est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          Text('Delai souhaite',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ..._urgencyOptions.map((option) {
            final selected = _selectedUrgency == option.label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: BrikolikColors.surface,
                borderRadius: BorderRadius.circular(BrikolikRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(BrikolikRadius.md),
                  onTap: () => setState(() => _selectedUrgency = option.label),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BrikolikRadius.md),
                      color: selected
                          ? option.color.withValues(alpha: 0.08)
                          : BrikolikColors.surface,
                      border: Border.all(
                        color: selected ? option.color : BrikolikColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: option.color.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(option.icon, size: 18, color: option.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: BrikolikColors.textPrimary,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded, color: option.color),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBudgetStep() {
    return Form(
      key: _budgetFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Definissez votre budget',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Un budget realiste vous aide a recevoir des offres rapidement.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BrikolikColors.surface,
              borderRadius: BorderRadius.circular(BrikolikRadius.lg),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: BrikolikInput(
                    hint: '150',
                    label: 'Min (MAD)',
                    controller: _budgetMinCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Min invalide';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('-',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                Expanded(
                  child: BrikolikInput(
                    hint: '450',
                    label: 'Max (MAD)',
                    controller: _budgetMaxCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Max invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: BrikolikColors.heroGradient,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_outlined,
                    color: BrikolikColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Astuce: donnez une fourchette pour garder de la flexibilite avec les artisans.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BrikolikColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Recapitulatif',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _SummaryCard(
            category: _selectedCategory ?? '-',
            title:
                _titleCtrl.text.trim().isEmpty ? '-' : _titleCtrl.text.trim(),
            location: _locationCtrl.text.trim().isEmpty
                ? '-'
                : _locationCtrl.text.trim(),
            urgency: _selectedUrgency ?? '-',
            budget:
                '${_budgetMinCtrl.text.trim().isEmpty ? '-' : _budgetMinCtrl.text.trim()} - ${_budgetMaxCtrl.text.trim().isEmpty ? '-' : _budgetMaxCtrl.text.trim()} MAD',
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.currentStep, required this.steps});

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: BrikolikColors.surface,
        border: Border(bottom: BorderSide(color: BrikolikColors.border)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isDone = index < currentStep;
          final isActive = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: (isDone || isActive)
                        ? BrikolikColors.brandGradient
                        : null,
                    color: (isDone || isActive)
                        ? null
                        : BrikolikColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? Colors.white
                                  : BrikolikColors.textHint,
                            ),
                          ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 2,
                      color: isDone
                          ? BrikolikColors.primary
                          : BrikolikColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isLast,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
  });

  final bool isLast;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          border: const Border(top: BorderSide(color: BrikolikColors.border)),
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.primary.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 108,
              child: BrikolikButton(
                label: 'Retour',
                outlined: true,
                onPressed: isSubmitting ? null : onBack,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BrikolikButton(
                label: isLast ? 'Publier ma demande' : 'Continuer',
                icon:
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.category,
    required this.title,
    required this.location,
    required this.urgency,
    required this.budget,
  });

  final String category;
  final String title;
  final String location;
  final String urgency;
  final String budget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Categorie', value: category),
          const Divider(height: 20),
          _SummaryRow(label: 'Titre', value: title),
          const Divider(height: 20),
          _SummaryRow(label: 'Lieu', value: location),
          const Divider(height: 20),
          _SummaryRow(label: 'Urgence', value: urgency),
          const Divider(height: 20),
          _SummaryRow(label: 'Budget', value: budget),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: value == '-'
                      ? BrikolikColors.textHint
                      : BrikolikColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

class _JobCategory {
  const _JobCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _UrgencyOption {
  const _UrgencyOption(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
