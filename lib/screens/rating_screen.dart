import 'package:flutter/material.dart';
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
    'Ponctuel', 'Professionnel', 'Soigné', 'Rapide', 'Bon tarif',
    'Excellent travail', 'Très recommandé',
  ];

  final List<String> _negativeTags = [
    'En retard', 'Travail non soigné', 'Mauvaise communication', 'Cher',
  ];

  List<String> get _availableTags =>
      _rating >= 4 ? _positiveTags : (_rating > 0 ? _negativeTags : []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: AppBar(
        title: const Text('Évaluation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWorkerCard(),
            const SizedBox(height: 28),
            _buildRatingSection(),
            const SizedBox(height: 24),
            if (_rating > 0 && _availableTags.isNotEmpty) ...[
              _buildTagsSection(),
              const SizedBox(height: 24),
            ],
            if (_rating > 0) ...[
              _buildCommentSection(),
              const SizedBox(height: 32),
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
      ),
      child: Column(
        children: [
          const BrikolikAvatar(name: 'Hamid Tazi', size: 72),
          const SizedBox(height: 12),
          Text('Hamid Tazi',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Plombier professionnel',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: BrikolikColors.surfaceVariant,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: BrikolikColors.success),
                const SizedBox(width: 8),
                Text(
                  'Mission terminée',
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
    final labels = ['', 'Mauvais', 'Passable', 'Bien', 'Très bien', 'Excellent'];
    final colors = [
      Colors.transparent,
      BrikolikColors.error,
      BrikolikColors.warning,
      BrikolikColors.warning,
      BrikolikColors.success,
      BrikolikColors.success,
    ];

    return Column(
      children: [
        Text(
          'Comment s\'est passée la mission ?',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Votre avis aide les autres clients à choisir',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedScale(
                  scale: _rating >= starIndex ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _rating >= starIndex
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color: _rating >= starIndex
                        ? BrikolikColors.star
                        : BrikolikColors.border,
                  ),
                ),
              ),
            );
          }),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('En quelques mots',
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
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Commentaire', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(width: 8),
            Text('(optionnel)',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        BrikolikInput(
          hint: 'Partagez votre expérience avec ce prestataire...',
          controller: _commentCtrl,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        BrikolikButton(
          label: 'Publier mon avis',
          onPressed: _submitRating,
          isLoading: _isLoading,
          icon: Icons.rate_review_rounded,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/jobs'),
          child: const Text('Passer pour l\'instant'),
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: BrikolikColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 36, color: BrikolikColors.success),
              ),
              const SizedBox(height: 20),
              Text('Merci !',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Votre avis a été publié. Il aidera d\'autres clients à choisir.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              BrikolikButton(
                label: 'Retour à l\'accueil',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/jobs');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}