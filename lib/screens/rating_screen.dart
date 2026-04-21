import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentCtrl = TextEditingController();
  final List<String> _tags = [];
  int _quality = 0;
  int _punctuality = 0;
  int _communication = 0;
  bool _isLoading = false;

  static const _positiveTags = [
    'Ponctuel',
    'Professionnel',
    'Soigne',
    'Rapide',
    'Bon tarif',
    'Tres recommande',
  ];

  bool get _canSubmit =>
      _quality > 0 && _punctuality > 0 && _communication > 0 && !_isLoading;

  double get _average => (_quality + _punctuality + _communication) / 3;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobId = _extractJobId(context);

    if (jobId == null) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: BrikolikAppBar(title: 'Evaluation', showBackButton: true),
        body: Center(child: Text('Mission introuvable'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(title: 'Evaluation', showBackButton: true),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrikolikColors.primary),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Mission introuvable'.tr()));
          }

          final jobData = snapshot.data!.data() ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMissionCard(context, jobData),
                const SizedBox(height: 20),
                _buildRatingSection(context),
                const SizedBox(height: 20),
                _buildTagsSection(context),
                const SizedBox(height: 20),
                _buildCommentSection(context),
                const SizedBox(height: 28),
                BrikolikButton(
                  label: 'Publier mon avis',
                  icon: Icons.rate_review_rounded,
                  isLoading: _isLoading,
                  onPressed:
                      _canSubmit ? () => _submitRating(jobId, jobData) : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre note aide les prochains clients a choisir les bons artisans.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrikolikColors.textHint,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _extractJobId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) return args.trim();
    if (args is Map && args['jobId'] is String) {
      final jobId = (args['jobId'] as String).trim();
      return jobId.isEmpty ? null : jobId;
    }
    return null;
  }

  Widget _buildMissionCard(BuildContext context, Map<String, dynamic> jobData) {
    final workerName =
        (jobData['acceptedWorkerName'] as String? ?? 'Artisan').trim();
    final category = (jobData['category'] as String? ?? 'Service').trim();

    return Container(
      width: double.infinity,
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
          BrikolikAvatar(name: workerName, size: 72),
          const SizedBox(height: 14),
          Text(workerName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(category, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          _StatusPill(
            icon: Icons.check_circle_outline_rounded,
            label: 'Mission terminee',
            color: BrikolikColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: BrikolikColors.heroGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notez cette mission'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Qualite, ponctualite et communication : les 3 criteres qui comptent.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _RatingCriterion(
            label: 'Qualite du travail',
            value: _quality,
            onChanged: (value) => setState(() => _quality = value),
          ),
          const SizedBox(height: 14),
          _RatingCriterion(
            label: 'Ponctualite',
            value: _punctuality,
            onChanged: (value) => setState(() => _punctuality = value),
          ),
          const SizedBox(height: 14),
          _RatingCriterion(
            label: 'Communication',
            value: _communication,
            onChanged: (value) => setState(() => _communication = value),
          ),
          if (_quality > 0 || _punctuality > 0 || _communication > 0) ...[
            const SizedBox(height: 18),
            _StatusPill(
              icon: Icons.star_rounded,
              label: 'Moyenne ${_average.toStringAsFixed(1)}/5',
              color: BrikolikColors.star,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Points forts'.tr(),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _positiveTags.map((tag) {
              final selected = _tags.contains(tag);
              return CategoryChip(
                label: tag,
                selected: selected,
                onTap: () {
                  setState(() {
                    selected ? _tags.remove(tag) : _tags.add(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context) {
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
          Text('Commentaire optionnel'.tr(),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          BrikolikInput(
            hint: 'Partagez votre experience avec cet artisan...',
            controller: _commentCtrl,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating(
    String jobId,
    Map<String, dynamic> jobData,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_canSubmit) return;

    setState(() => _isLoading = true);
    try {
      final workerId = (jobData['acceptedWorkerId'] as String? ?? '').trim();
      final ratingPayload = {
        'jobId': jobId,
        'customerId': user.uid,
        'workerId': workerId,
        'workerName': jobData['acceptedWorkerName'],
        'quality': _quality,
        'punctuality': _punctuality,
        'communication': _communication,
        'average': double.parse(_average.toStringAsFixed(2)),
        'tags': List<String>.from(_tags),
        'comment': _commentCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final ratingRef = FirebaseFirestore.instance
          .collection('ratings')
          .doc('${jobId}_${user.uid}');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(ratingRef, ratingPayload, SetOptions(merge: true));
        transaction.update(
          FirebaseFirestore.instance.collection('jobs').doc(jobId),
          {
            'ratingSubmitted': true,
            'ratedAt': FieldValue.serverTimestamp(),
            'ratedBy': user.uid,
            'ratingForWorkerId': workerId,
            'ratingQuality': _quality,
            'ratingPunctuality': _punctuality,
            'ratingCommunication': _communication,
            'ratingAverage': double.parse(_average.toStringAsFixed(2)),
            'ratingTags': List<String>.from(_tags),
            'ratingComment': _commentCtrl.text.trim(),
          },
        );
      });

      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur evaluation: $e'),
          backgroundColor: BrikolikColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: BrikolikColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text('Merci !'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Votre avis a ete enregistre et lie a cette mission.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              BrikolikButton(
                label: 'Retour aux missions',
                icon: Icons.work_outline_rounded,
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

class _RatingCriterion extends StatelessWidget {
  const _RatingCriterion({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.tr(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: BrikolikColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final star = index + 1;
            final selected = value >= star;
            return GestureDetector(
              onTap: () => onChanged(star),
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  selected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 30,
                  color: selected
                      ? BrikolikColors.star
                      : BrikolikColors.frostSilver,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label.tr(),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: const ['Cairo'],
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
