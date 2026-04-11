import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _isLoading = false;

  final List<String> _positiveTags = [
    'Ponctuel', 'Professionnel', 'Soigne', 'Rapide', 'Bon tarif',
    'Excellent travail', 'Tres recommande',
  ];

  final List<String> _negativeTags = [
    'En retard', 'Travail non soigne', 'Mauvaise communication', 'Cher',
  ];

  List<String> get _availableTags =>
      _rating >= 4 ? _positiveTags : (_rating > 0 ? _negativeTags : []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Evaluation',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWorkerCard(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 20),
            if (_rating > 0 && _availableTags.isNotEmpty) ...[
              _buildTagsSection(),
              const SizedBox(height: 20),
            ],
            if (_rating > 0) ...[
              _buildCommentSection(),
              const SizedBox(height: 28),
              _buildSubmitButton(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient ring avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: BrikolikColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const BrikolikAvatar(name: 'Hamid Tazi', size: 72),
            ),
          ),
          const SizedBox(height: 14),
          Text('Hamid Tazi',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Plombier professionnel'.tr(),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: BrikolikColors.successLight,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
              border: Border.all(
                  color: BrikolikColors.success.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: BrikolikColors.success),
                SizedBox(width: 8),
                Text('Mission terminee'.tr(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: BrikolikColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final labels = [
      '',
      'Mauvais',
      'Passable',
      'Bien',
      'Tres bien',
      'Excellent',
    ];
    final colors = [
      Colors.transparent,
      BrikolikColors.error,
      BrikolikColors.warning,
      BrikolikColors.warning,
      BrikolikColors.success,
      BrikolikColors.accent,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: BrikolikColors.heroGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        children: [
          Text('Comment s est passee la mission ?'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text('Votre avis aide les autres clients a choisir'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedScale(
                    scale: _rating >= starIndex ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _rating >= starIndex
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: _rating >= starIndex
                          ? BrikolikColors.star
                          : BrikolikColors.frostSilver,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                labels[_rating],
                key: ValueKey(_rating),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors[_rating],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('En quelques mots'.tr(),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final selected = _tags.contains(tag);
              return CategoryChip(
                label: tag,
                selected: selected,
                onTap: () {
                  setState(() {
                    if (selected) {
                      _tags.remove(tag);
                    } else {
                      _tags.add(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('Commentaire'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BrikolikColors.mutedLight,
                  borderRadius:
                      BorderRadius.circular(BrikolikRadius.full),
                ),
                child: Text('optionnel'.tr(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BrikolikColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrikolikInput(
            hint: 'Partagez votre experience avec ce prestataire...',
            controller: _commentCtrl,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _submitRating,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: BrikolikColors.brandGradient,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
              boxShadow: [
                BoxShadow(
                  color: BrikolikColors.accent.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rate_review_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Publier mon avis'.tr(),
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/jobs'),
          child: Text('Passer pour l instant'.tr(),
            style: TextStyle(
              fontFamily: 'Nunito',
              color: BrikolikColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: BrikolikColors.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BrikolikColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text('Merci !'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Votre avis a ete publie. Il aidera d autres clients a choisir.'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/jobs');
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    borderRadius:
                        BorderRadius.circular(BrikolikRadius.md),
                  ),
                  child: Center(
                    child: Text('Retour a l accueil'.tr(),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

