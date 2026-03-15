import 'package:flutter/material.dart';
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
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Plomberie', 'icon': Icons.water_drop_outlined},
    {'label': 'Électricité', 'icon': Icons.bolt_outlined},
    {'label': 'Nettoyage', 'icon': Icons.cleaning_services_outlined},
    {'label': 'Peinture', 'icon': Icons.format_paint_outlined},
    {'label': 'Jardinage', 'icon': Icons.grass_outlined},
    {'label': 'Menuiserie', 'icon': Icons.carpenter_outlined},
    {'label': 'Maçonnerie', 'icon': Icons.construction_outlined},
    {'label': 'Autre', 'icon': Icons.more_horiz_rounded},
  ];

  final List<Map<String, dynamic>> _urgencies = [
    {'label': 'Urgent (24h)', 'icon': Icons.flash_on_rounded, 'color': BrikolikColors.error},
    {'label': 'Cette semaine', 'icon': Icons.today_rounded, 'color': BrikolikColors.warning},
    {'label': 'Ce mois', 'icon': Icons.calendar_month_outlined, 'color': BrikolikColors.primary},
    {'label': 'Flexible', 'icon': Icons.schedule_rounded, 'color': BrikolikColors.success},
  ];

  final List<String> _steps = ['Catégorie', 'Détails', 'Budget'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: AppBar(
        title: const Text('Poster un service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
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
          final isDone = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? BrikolikColors.primary
                            : isActive
                            ? BrikolikColors.primary
                            : BrikolikColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: isActive && !isDone
                            ? Border.all(
                            color: BrikolikColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
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
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
                      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
                      decoration: BoxDecoration(
                        color: i < _currentStep
                            ? BrikolikColors.primary
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
        Text('Sélectionnez la catégorie qui correspond à votre besoin',
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? BrikolikColors.primaryLight
                      : BrikolikColors.surface,
                  borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                  border: Border.all(
                    color: selected
                        ? BrikolikColors.primary
                        : BrikolikColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'],
                      size: 28,
                      color: selected
                          ? BrikolikColors.primary
                          : BrikolikColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? BrikolikColors.primary
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
        Text('Plus votre description est précise, meilleures seront les offres',
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
        Text('Urgence', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...(_urgencies.map(
              (u) {
            final selected = _selectedUrgency == u['label'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedUrgency = u['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? (u['color'] as Color).withOpacity(0.08)
                      : BrikolikColors.surface,
                  borderRadius: BorderRadius.circular(BrikolikRadius.md),
                  border: Border.all(
                    color: selected ? u['color'] : BrikolikColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(u['icon'], size: 20, color: u['color']),
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
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: u['color']),
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
        Text('Définissez une fourchette de budget pour attirer les bons prestataires',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
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
              Text('Fourchette de prix',
                  style: Theme.of(context).textTheme.titleLarge),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('–',
                        style: Theme.of(context).textTheme.headlineMedium),
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BrikolikColors.primaryLight,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: BrikolikColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Définir un budget clair augmente les chances de recevoir des offres rapidement.',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BrikolikColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Récapitulatif',
            style: Theme.of(context).textTheme.headlineSmall),
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
          _SummaryRow(label: 'Catégorie', value: _selectedCategory ?? '—'),
          const Divider(height: 16),
          _SummaryRow(
              label: 'Titre',
              value: _titleCtrl.text.isEmpty ? '—' : _titleCtrl.text),
          const Divider(height: 16),
          _SummaryRow(
              label: 'Lieu',
              value:
              _locationCtrl.text.isEmpty ? '—' : _locationCtrl.text),
          const Divider(height: 16),
          _SummaryRow(label: 'Urgence', value: _selectedUrgency ?? '—'),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        border:
        const Border(top: BorderSide(color: BrikolikColors.border, width: 1)),
      ),
      child: BrikolikButton(
        label: isLast ? 'Publier ma demande' : 'Continuer',
        onPressed: () {
          if (isLast) {
            Navigator.pushReplacementNamed(context, '/jobs');
          } else {
            setState(() => _currentStep++);
          }
        },
        icon: isLast
            ? Icons.check_rounded
            : Icons.arrow_forward_rounded,
      ),
    );
  }
}

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
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}