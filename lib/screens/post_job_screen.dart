import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  int _currentStep = 0;
  String? _selectedCategory;
  String? _selectedUrgency;
  final _titleCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _budgetMinCtrl  = TextEditingController();
  final _budgetMaxCtrl  = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Plomberie',   'icon': Icons.water_drop_outlined},
    {'label': 'Électricité', 'icon': Icons.bolt_outlined},
    {'label': 'Nettoyage',   'icon': Icons.cleaning_services_outlined},
    {'label': 'Peinture',    'icon': Icons.format_paint_outlined},
    {'label': 'Jardinage',   'icon': Icons.grass_outlined},
    {'label': 'Menuiserie',  'icon': Icons.carpenter_outlined},
    {'label': 'Maçonnerie',  'icon': Icons.construction_outlined},
    {'label': 'Autre',       'icon': Icons.more_horiz_rounded},
  ];

  final List<Map<String, dynamic>> _urgencies = [
    {
      'label': 'Urgent (24h)',
      'icon': Icons.flash_on_rounded,
      'color': BrikolikColors.error
    },
    {
      'label': 'Cette semaine',
      'icon': Icons.today_rounded,
      'color': BrikolikColors.warning
    },
    {
      'label': 'Ce mois',
      'icon': Icons.calendar_month_outlined,
      'color': BrikolikColors.primary
    },
    {
      'label': 'Flexible',
      'icon': Icons.schedule_rounded,
      'color': BrikolikColors.success
    },
  ];

  final List<String> _steps = ['Catégorie', 'Détails', 'Budget'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Poster un service',
        onBackPressed: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ][_currentStep],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: BrikolikColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone   = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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
                        boxShadow: (isDone || isActive)
                            ? [
                                BoxShadow(
                                  color: BrikolikColors.primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Colors.white)
                            : Text(
                                '${i + 1}',
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
                    const SizedBox(height: 4),
                    Text(
                      _steps[i],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? BrikolikColors.primary
                            : BrikolikColors.textHint,
                      ),
                    ),
                  ],
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 4, right: 4),
                      decoration: BoxDecoration(
                        gradient: i < _currentStep
                            ? BrikolikColors.brandGradient
                            : null,
                        color: i < _currentStep
                            ? null
                            : BrikolikColors.border,
                        borderRadius:
                            BorderRadius.circular(BrikolikRadius.full),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel type de service\navez-vous besoin ?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
            'Sélectionnez la catégorie qui correspond à votre besoin',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: _categories.map((cat) {
            final selected = _selectedCategory == cat['label'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedCategory = cat['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: selected
                      ? BrikolikColors.brandGradient
                      : null,
                  color: selected ? null : BrikolikColors.surface,
                  borderRadius:
                      BorderRadius.circular(BrikolikRadius.lg),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : BrikolikColors.border,
                    width: 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: BrikolikColors.primary
                                .withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
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
                        cat['icon'],
                        size: 22,
                        color: selected
                            ? Colors.white
                            : BrikolikColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : BrikolikColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Décrivez votre besoin',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
            'Plus votre description est précise, meilleures seront les offres',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        BrikolikInput(
          hint: 'Ex : Fuite d\'eau sous le lavabo, besoin de remplacement...',
          label: 'Titre de votre demande',
          controller: _titleCtrl,
          prefixIcon: Icons.title_rounded,
        ),
        const SizedBox(height: 16),
        BrikolikInput(
          hint: 'Décrivez le problème en détail...',
          label: 'Description',
          controller: _descCtrl,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        BrikolikInput(
          hint: 'Ex : Casablanca, Maarif',
          label: 'Adresse ou quartier',
          controller: _locationCtrl,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BrikolikColors.primaryLight,
                borderRadius: BorderRadius.circular(BrikolikRadius.sm),
              ),
              child: const Icon(Icons.schedule_rounded,
                  size: 16, color: BrikolikColors.primary),
            ),
            const SizedBox(width: 10),
            Text('Urgence',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        ...(_urgencies.map(
          (u) {
            final selected = _selectedUrgency == u['label'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedUrgency = u['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? (u['color'] as Color).withValues(alpha: 0.07)
                      : BrikolikColors.surface,
                  borderRadius:
                      BorderRadius.circular(BrikolikRadius.md),
                  border: Border.all(
                    color: selected
                        ? u['color'] as Color
                        : BrikolikColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (u['color'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(u['icon'] as IconData,
                          size: 18, color: u['color'] as Color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      u['label'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? BrikolikColors.textPrimary
                            : BrikolikColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: u['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white),
                      ),
                  ],
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel est votre budget ?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
            'Définissez une fourchette de budget pour attirer les bons prestataires',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
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
                    child: const Icon(Icons.payments_outlined,
                        size: 16, color: BrikolikColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Fourchette de prix',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: BrikolikInput(
                      hint: '100',
                      label: 'Minimum (MAD)',
                      controller: _budgetMinCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('–',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium),
                  ),
                  Expanded(
                    child: BrikolikInput(
                      hint: '500',
                      label: 'Maximum (MAD)',
                      controller: _budgetMaxCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tip banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: BrikolikColors.heroGradient,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BrikolikColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: BrikolikColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Définir un budget clair augmente les chances de recevoir des offres rapidement.',
                  style: const TextStyle(
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
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BrikolikColors.primaryLight,
                borderRadius: BorderRadius.circular(BrikolikRadius.sm),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 16, color: BrikolikColors.primary),
            ),
            const SizedBox(width: 10),
            Text('Récapitulatif',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Catégorie',
              value: _selectedCategory ?? '—'),
          const Divider(height: 20),
          _SummaryRow(
              label: 'Titre',
              value: _titleCtrl.text.isEmpty
                  ? '—'
                  : _titleCtrl.text),
          const Divider(height: 20),
          _SummaryRow(
              label: 'Lieu',
              value: _locationCtrl.text.isEmpty
                  ? '—'
                  : _locationCtrl.text),
          const Divider(height: 20),
          _SummaryRow(
              label: 'Urgence',
              value: _selectedUrgency ?? '—'),
        ],
      ),
    );
  }

  bool _isSubmitting = false;

  Future<void> _submitJob() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous authentifier.')),
      );
      return;
    }

    if (_titleCtrl.text.trim().isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le titre et la catégorie.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userName = userDoc.data()?['fullName'] ?? 'Client';

      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'location': _locationCtrl.text.trim(),
        'urgency': _selectedUrgency,
        'budget': '${_budgetMinCtrl.text}–${_budgetMaxCtrl.text} MAD',
        'customerId': uid,
        'customerName': userName,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'offersCount': 0,
        'rating': 0.0,
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/jobs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildBottomBar() {
    final isLast = _currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        border: const Border(
            top: BorderSide(color: BrikolikColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (_isSubmitting) return;
          if (isLast) {
            _submitJob();
          } else {
            setState(() => _currentStep++);
          }
        },
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _isSubmitting ? null : BrikolikColors.brandGradient,
            color: _isSubmitting ? BrikolikColors.surfaceVariant : null,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            boxShadow: _isSubmitting ? [] : [
              BoxShadow(
                color: BrikolikColors.accent.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: BrikolikColors.primary, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLast) ...[
                        const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isLast ? 'Publier ma demande' : 'Continuer',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: value == '—'
                      ? BrikolikColors.textHint
                      : BrikolikColors.textPrimary,
                )),
      ],
    );
  }
}
