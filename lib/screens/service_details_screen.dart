import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! BrkServiceItem) {
      return Scaffold(
        appBar: const BrikolikAppBar(title: 'Service', showBackButton: true),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Service introuvable',
          subtitle: 'Retournez a l accueil et selectionnez un service valide.',
        ),
      );
    }

    final service = args;
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 262,
            pinned: true,
            backgroundColor: BrikolikColors.surface,
            foregroundColor: BrikolikColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: _ServiceHeaderImage(service: service),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: BrikolikColors.primaryLight,
                      borderRadius: BorderRadius.circular(BrikolikRadius.full),
                    ),
                    child: Text(
                      service.category,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontFamilyFallback: ['Cairo'],
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: BrikolikColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StarRating(
                        rating: service.rating,
                        reviewCount: service.reviewsCount,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${service.jobsCount} jobs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: BrikolikColors.brandGradient,
                          borderRadius: BorderRadius.circular(BrikolikRadius.full),
                        ),
                        child: Text(
                          service.priceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontFamilyFallback: ['Cairo'],
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (service.galleryUrls.length > 1) ...[
                    const SizedBox(height: 16),
                    _GalleryStrip(urls: service.galleryUrls),
                  ],
                  const SizedBox(height: 20),
                  _DetailSectionCard(
                    title: 'Description',
                    child: Text(
                      service.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailSectionCard(
                    title: 'Ce qui est inclus',
                    child: Column(
                      children: service.includes
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: BrikolikColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ProviderCard(service: service),
                  const SizedBox(height: 20),
                  _ReviewsSection(service: service),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            border: const Border(top: BorderSide(color: BrikolikColors.border)),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.priceLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: BrikolikColors.primary,
                          ),
                    ),
                  ),
                  Text(
                    'Reponse rapide',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BrikolikButton(
                label: 'Request Service',
                icon: Icons.assignment_turned_in_rounded,
                onPressed: () => _showRequestIntentSheet(context, service),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRequestIntentSheet(
    BuildContext context,
    BrkServiceItem service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: BrikolikColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demander ce service',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous serez redirige vers le formulaire de demande pour publier votre besoin et recevoir des offres.',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            BrikolikButton(
              label: 'Continuer vers Poster un service',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.pushNamed(
                  context,
                  '/post-job',
                  arguments: {
                    'prefill': {
                      'title': service.title,
                      'category': service.category,
                      'description':
                          'Demande inspiree par le service "${service.title}".\n\nPrecisez ici vos besoins, photos et contraintes.',
                      'location': service.location,
                    },
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            BrikolikButton(
              label: 'Voir toutes les missions',
              outlined: true,
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.pushNamed(context, '/jobs');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHeaderImage extends StatelessWidget {
  const _ServiceHeaderImage({required this.service});

  final BrkServiceItem service;

  @override
  Widget build(BuildContext context) {
    if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            service.imageUrl!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
          _overlay(),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [_fallback(), _overlay()],
    );
  }

  Widget _overlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.45),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4E6CB0), Color(0xFF7D5EA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.home_repair_service_rounded,
          color: Colors.white,
          size: 52,
        ),
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final url = urls[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            child: Image.network(
              url,
              width: 84,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 84,
                color: BrikolikColors.surfaceVariant,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.service});

  final BrkServiceItem service;

  @override
  Widget build(BuildContext context) {
    if (service.providerId.isEmpty) {
      return _ProviderCardContent(
        name: service.providerName,
        imageUrl: service.providerImageUrl,
        rating: service.providerRating,
        jobs: service.providerJobs,
        verified: service.isVerifiedProvider,
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(service.providerId)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final resolvedName = _firstText([
              data['fullName'],
              data['displayName'],
              service.providerName,
            ]) ??
            service.providerName;
        final resolvedImage = _firstText([
          data['photoUrl'],
          data['avatarUrl'],
          data['profileImageUrl'],
          service.providerImageUrl,
        ]);
        final resolvedRating = _firstNum([
              data['ratingAverage'],
              data['rating'],
              service.providerRating,
            ]) ??
            service.providerRating;
        final resolvedJobs = _firstInt([
              data['completedJobs'],
              data['jobsCompleted'],
              data['missionsDone'],
              service.providerJobs,
            ]) ??
            service.providerJobs;
        final verified =
            data['isVerified'] == true || service.isVerifiedProvider == true;

        return _ProviderCardContent(
          name: resolvedName,
          imageUrl: resolvedImage,
          rating: resolvedRating,
          jobs: resolvedJobs,
          verified: verified,
        );
      },
    );
  }
}

class _ProviderCardContent extends StatelessWidget {
  const _ProviderCardContent({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.jobs,
    required this.verified,
  });

  final String name;
  final String? imageUrl;
  final double rating;
  final int jobs;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          BrikolikAvatar(
            name: name,
            imageUrl: imageUrl,
            size: 48,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (verified)
                      const Icon(
                        Icons.verified_rounded,
                        color: BrikolikColors.success,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StarRating(rating: rating, starSize: 12),
                    const SizedBox(width: 8),
                    Text(
                      '$jobs jobs termines',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Prestataire actif sur Brikolik',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrikolikColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.service});

  final BrkServiceItem service;

  @override
  Widget build(BuildContext context) {
    final canQueryRatings = service.providerId.isNotEmpty;
    if (!canQueryRatings) {
      return _ReviewsPreviewList(
        title: 'Avis (${service.reviewsCount})',
        reviews: service.reviewsPreview,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('workerId', isEqualTo: service.providerId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return _ReviewsPreviewList(
            title: 'Avis (${service.reviewsCount})',
            reviews: service.reviewsPreview,
          );
        }

        final mapped = docs.map((doc) {
          final data = doc.data();
          final dateLabel = _formatReviewDate(data['createdAt']);
          return BrkReview(
            author: _firstText([data['customerName'], 'Client Brikolik'])!,
            comment: _firstText([data['comment'], 'Service recommande.'])!,
            rating: _firstNum([data['average'], data['rating'], 4.7])!,
            dateLabel: dateLabel,
            avatarUrl: _firstText([data['customerAvatarUrl']]),
          );
        }).toList();

        return _ReviewsPreviewList(
          title: 'Avis (${docs.length})',
          reviews: mapped,
        );
      },
    );
  }
}

class _ReviewsPreviewList extends StatelessWidget {
  const _ReviewsPreviewList({
    required this.title,
    required this.reviews,
  });

  final String title;
  final List<BrkReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...reviews.map(
          (review) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrikolikColors.surface,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BrikolikAvatar(
                      name: review.author,
                      imageUrl: review.avatarUrl,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.author,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      review.dateLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StarRating(rating: review.rating, starSize: 12),
                const SizedBox(height: 6),
                Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String? _firstText(List<dynamic> values) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String _formatReviewDate(dynamic rawDate) {
  DateTime? date;
  if (rawDate is Timestamp) {
    date = rawDate.toDate();
  } else if (rawDate is DateTime) {
    date = rawDate;
  }
  if (date == null) return 'Recent';

  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0) return "Aujourd'hui";
  if (diff.inDays == 1) return 'Hier';
  if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';

  const months = [
    'janv.',
    'fevr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'aout',
    'sept.',
    'oct.',
    'nov.',
    'dec.',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

double? _firstNum(List<dynamic> values) {
  for (final value in values) {
    if (value is num) return value.toDouble();
  }
  return null;
}

int? _firstInt(List<dynamic> values) {
  for (final value in values) {
    if (value is num) return value.toInt();
  }
  return null;
}
