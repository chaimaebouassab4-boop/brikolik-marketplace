import 'package:flutter/material.dart';

class BrkCategory {
  const BrkCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.coverGradient,
  });

  final String key;
  final String label;
  final IconData icon;
  final List<Color> coverGradient;
}

class BrkReview {
  const BrkReview({
    required this.author,
    required this.comment,
    required this.rating,
    required this.dateLabel,
    this.avatarUrl,
  });

  final String author;
  final String comment;
  final double rating;
  final String dateLabel;
  final String? avatarUrl;
}

class BrkServiceItem {
  const BrkServiceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.priceLabel,
    required this.rating,
    required this.reviewsCount,
    required this.jobsCount,
    required this.location,
    required this.providerId,
    required this.providerName,
    required this.providerRating,
    required this.providerJobs,
    required this.includes,
    required this.reviewsPreview,
    this.imageUrl,
    this.galleryUrls = const <String>[],
    this.providerImageUrl,
    this.isVerifiedProvider = false,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String priceLabel;
  final double rating;
  final int reviewsCount;
  final int jobsCount;
  final String location;
  final String providerId;
  final String providerName;
  final double providerRating;
  final int providerJobs;
  final List<String> includes;
  final List<BrkReview> reviewsPreview;
  final String? imageUrl;
  final List<String> galleryUrls;
  final String? providerImageUrl;
  final bool isVerifiedProvider;

  static BrkServiceItem fromJobMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final budget = (data['budget'] as String?)?.trim();
    final min = data['budgetMin'];
    final max = data['budgetMax'];
    final gallery = _extractImageUrls(data['gallery']);
    final problemPhotos = _extractImageUrls(data['problemPhotoUrls']);
    final completionPhotos = _extractImageUrls(data['completionPhotoUrls']);
    final allGallery = <String>[
      ...gallery,
      ...problemPhotos,
      ...completionPhotos,
    ];
    final cover = _firstNonEmptyString([
      data['image'],
      data['imageUrl'],
      data['serviceImage'],
      data['serviceImageUrl'],
      data['coverImage'],
      data['coverImageUrl'],
      if (allGallery.isNotEmpty) allGallery.first,
    ]);
    final providerId = _firstNonEmptyString([
      data['acceptedWorkerId'],
      data['workerId'],
      data['providerId'],
      data['customerId'],
    ]);
    final providerName = _firstNonEmptyString([
      data['acceptedWorkerName'],
      data['workerName'],
      data['providerName'],
      data['customerName'],
    ]);
    final providerRating = _firstNum([
      data['providerRating'],
      data['workerRating'],
      data['ratingAverage'],
      data['rating'],
    ]);
    final providerJobs = _firstInt([
      data['completedJobs'],
      data['workerCompletedJobs'],
      data['jobsCompleted'],
      data['offersCount'],
    ]);

    final generatedBudget = (min is num && max is num)
        ? 'MAD ${min.toInt()} - ${max.toInt()}'
        : 'Budget sur demande';

    return BrkServiceItem(
      id: id,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : 'Service sans titre',
      category: ((data['category'] as String?)?.trim().isNotEmpty == true)
          ? (data['category'] as String).trim()
          : 'Autre',
      description: (data['description'] as String?)?.trim().isNotEmpty == true
          ? (data['description'] as String).trim()
          : 'Details du service a confirmer avec le prestataire.',
      priceLabel:
          (budget != null && budget.isNotEmpty) ? budget : generatedBudget,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 4.7,
      reviewsCount: (data['reviewsCount'] is num)
          ? (data['reviewsCount'] as num).toInt()
          : 0,
      jobsCount:
          (data['offersCount'] is num) ? (data['offersCount'] as num).toInt() : 0,
      location: (data['location'] as String?)?.trim().isNotEmpty == true
          ? (data['location'] as String).trim()
          : 'Maroc',
      providerId: providerId ?? '',
      providerName: providerName ?? 'Prestataire Brikolik',
      providerRating: providerRating ?? 4.8,
      providerJobs: providerJobs ?? 18,
      includes: const [
        'Diagnostic initial sur place',
        'Main d oeuvre professionnelle',
        'Nettoyage rapide apres intervention',
      ],
      reviewsPreview: const [
        BrkReview(
          author: 'Client Brikolik',
          comment: 'Intervention propre et tres rapide.',
          rating: 4.8,
          dateLabel: 'Recent',
        ),
      ],
      imageUrl: cover,
      galleryUrls: allGallery,
      providerImageUrl: _firstNonEmptyString([
        data['providerImageUrl'],
        data['workerPhotoUrl'],
        data['workerAvatarUrl'],
        data['photoUrl'],
      ]),
      isVerifiedProvider: data['isVerifiedProvider'] == true ||
          data['workerVerified'] == true ||
          data['isVerified'] == true,
    );
  }
}

String? _firstNonEmptyString(List<dynamic> values) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
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

List<String> _extractImageUrls(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
