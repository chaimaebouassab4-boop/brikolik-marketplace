import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_components.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdminPageHeader(
          title: 'Analytics',
          subtitle: 'Indicateurs clefs et tendances (basees sur Firestore).',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: BrikolikColors.primary),
                );
              }
              if (snapshot.hasError) {
                return AdminCard(child: Text('Erreur: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? const [];

              var open = 0;
              var inprogress = 0;
              var done = 0;
              var offersSum = 0;
              final categories = <String, int>{};

              for (final d in docs) {
                final data = d.data();
                final status = (data['status'] as String?)?.trim() ?? 'open';
                final offers = (data['offersCount'] as num?)?.toInt() ?? 0;
                final category = (data['category'] as String?)?.trim() ?? '';
                offersSum += offers;
                if (category.isNotEmpty) {
                  categories[category] = (categories[category] ?? 0) + 1;
                }
                switch (status) {
                  case 'done':
                    done++;
                    break;
                  case 'inprogress':
                    inprogress++;
                    break;
                  default:
                    open++;
                }
              }

              final avgOffers =
                  docs.isEmpty ? 0.0 : (offersSum / docs.length.toDouble());
              final topCats = categories.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final top = topCats.take(8).toList();
              final barValues = top.map((e) => e.value.toDouble()).toList();

              final trendValues = _jobsTrend14Days(docs);

              return ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Repartition par statut',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontFamilyFallback: ['Cairo'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  AdminPill(
                                    label: 'Ouvert: $open',
                                    color: BrikolikColors.success,
                                    bgColor: BrikolikColors.successLight,
                                  ),
                                  AdminPill(
                                    label: 'En cours: $inprogress',
                                    color: BrikolikColors.warning,
                                    bgColor: BrikolikColors.warningLight,
                                  ),
                                  AdminPill(
                                    label: 'Termine: $done',
                                    color: BrikolikColors.textSecondary,
                                    bgColor: BrikolikColors.surfaceVariant,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Moyenne offres/demande: ${avgOffers.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: BrikolikColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AdminCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Demandes / jour (14 jours)',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontFamilyFallback: ['Cairo'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AdminMiniLineChart(values: trendValues),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdminCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top categories (8 max)',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontFamilyFallback: ['Cairo'],
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AdminMiniBarChart(values: barValues),
                        const SizedBox(height: 10),
                        if (top.isEmpty)
                          const Text(
                            'Aucune categorie trouvee.',
                            style: TextStyle(color: BrikolikColors.textSecondary),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: top
                                .map((e) => AdminPill(
                                      label: '${e.key}: ${e.value}',
                                      color: BrikolikColors.accentDark,
                                      bgColor: BrikolikColors.accentLight,
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static List<double> _jobsTrend14Days(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 13));
    final buckets = List<int>.filled(14, 0);

    for (final d in docs) {
      final createdAt = d.data()['createdAt'];
      if (createdAt is! Timestamp) continue;
      final dt = createdAt.toDate();
      if (dt.isBefore(start)) continue;
      final diff = DateTime(dt.year, dt.month, dt.day).difference(start);
      final idx = diff.inDays;
      if (idx >= 0 && idx < buckets.length) buckets[idx]++;
    }

    return buckets.map((e) => e.toDouble()).toList();
  }
}

