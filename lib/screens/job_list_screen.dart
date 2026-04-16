import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  static const List<_CategoryOption> _categories = [
    _CategoryOption(
        label: 'Tous', icon: Icons.grid_view_rounded, values: ['Tous']),
    _CategoryOption(
        label: 'Plomberie',
        icon: Icons.water_drop_outlined,
        values: ['Plomberie']),
    _CategoryOption(
        label: 'Electricite',
        icon: Icons.bolt_outlined,
        values: ['Electricite', 'Électricite', 'Ã‰lectricitÃ©']),
    _CategoryOption(
        label: 'Nettoyage',
        icon: Icons.cleaning_services_outlined,
        values: ['Nettoyage']),
    _CategoryOption(
        label: 'Peinture',
        icon: Icons.format_paint_outlined,
        values: ['Peinture']),
    _CategoryOption(
        label: 'Jardinage', icon: Icons.grass_outlined, values: ['Jardinage']),
    _CategoryOption(
        label: 'Menuiserie',
        icon: Icons.carpenter_outlined,
        values: ['Menuiserie']),
    _CategoryOption(
        label: 'Maconnerie',
        icon: Icons.construction_outlined,
        values: ['Maconnerie', 'Maçonnerie', 'MaÃ§onnerie']),
  ];

  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedCategory = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _jobsQuery() {
    final selected = _categories[_selectedCategory];
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(100);

    if (selected.label == 'Tous') {
      return query;
    }

    if (selected.values.length == 1) {
      return query.where('category', isEqualTo: selected.values.first);
    }

    return query.where('category', whereIn: selected.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: const BrikolikAppBar(
        title: 'Missions',
        showBackButton: false,
        useBrandBackground: false,
        actions: [
          SizedBox(width: 8),
          Icon(Icons.notifications_outlined),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildJobList()),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: BrikolikColors.brandGradient,
          borderRadius: BorderRadius.circular(BrikolikRadius.full),
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.accent.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(BrikolikRadius.full),
            onTap: () => Navigator.pushNamed(context, '/post-job'),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Poster un service'.tr(),
                    style: TextStyle(
                      fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BrikolikBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: BrikolikColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextFormField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: BrikolikColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Chercher un service...'.tr(),
          filled: true,
          fillColor: BrikolikColors.surfaceVariant,
          prefixIcon: const Icon(Icons.search_rounded,
              size: 22, color: BrikolikColors.muted),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: BrikolikColors.brandGradient,
              borderRadius: BorderRadius.circular(BrikolikRadius.sm),
            ),
            child:
                const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            borderSide: const BorderSide(color: BrikolikColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            borderSide: const BorderSide(color: BrikolikColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            borderSide:
                const BorderSide(color: BrikolikColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: BrikolikColors.surface,
      child: Column(
        children: [
          const Divider(height: 1),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryChip(
                  label: category.label,
                  icon: category.icon,
                  selected: _selectedCategory == index,
                  onTap: () => setState(() => _selectedCategory = index),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Connexion requise',
        subtitle:
            'Connectez-vous pour consulter les missions et envoyer des offres.',
        actionLabel: 'Se connecter',
        onAction: () => Navigator.pushNamed(context, '/login'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _jobsQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: BrikolikColors.primary));
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          if (error is FirebaseException && error.code == 'permission-denied') {
            return EmptyState(
              icon: Icons.gpp_bad_outlined,
              title: 'Acces refuse',
              subtitle:
                  'Vos permissions Firestore ne permettent pas de lire les missions. Verifiez les regles de securite.',
              actionLabel: 'Se connecter',
              onAction: () => Navigator.pushNamed(context, '/login'),
            );
          }
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ??
            const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final query = _searchCtrl.text.trim().toLowerCase();
        final filteredDocs = docs.where((doc) {
          if (query.isEmpty) return true;
          final title = (doc.data()['title'] as String?)?.toLowerCase() ?? '';
          return title.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_off_outlined,
            title: 'Aucune mission trouvee',
            subtitle:
                'Essayez une autre recherche ou postez une nouvelle demande.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          cacheExtent: 600,
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data();
            final category = data['category'] as String? ?? 'Autre';

            String timeStr = "A l'instant";
            final createdAt = data['createdAt'] as Timestamp?;
            if (createdAt != null) {
              final diff = DateTime.now().difference(createdAt.toDate());
              if (diff.inMinutes < 60) {
                timeStr = 'Il y a ${diff.inMinutes} min';
              } else if (diff.inHours < 24) {
                timeStr = 'Il y a ${diff.inHours} h';
              } else {
                timeStr = 'Il y a ${diff.inDays} j';
              }
            }

            final jobMap = {
              'status': data['status'] ?? 'open',
              'offers': data['offersCount'] ?? 0,
              'icon': _iconForCategory(category),
              'category': category,
              'time': timeStr,
              'title': data['title'] ?? 'Sans titre',
              'location': data['location'] ?? 'Lieu non specifie',
              'budget': data['budget'] ?? 'Budget non defini',
              'name': data['customerName'] ?? 'Client',
              'rating': (data['rating'] ?? 0.0).toDouble(),
            };

            return JobCard(
              job: jobMap,
              onTap: () => Navigator.pushNamed(
                context,
                '/job-details',
                arguments: filteredDocs[index].id,
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Plomberie':
        return Icons.water_drop_outlined;
      case 'Electricite':
      case 'Électricite':
      case 'Ã‰lectricitÃ©':
        return Icons.bolt_outlined;
      case 'Nettoyage':
        return Icons.cleaning_services_outlined;
      case 'Peinture':
        return Icons.format_paint_outlined;
      case 'Jardinage':
        return Icons.grass_outlined;
      case 'Menuiserie':
        return Icons.carpenter_outlined;
      case 'Maconnerie':
      case 'Maçonnerie':
      case 'MaÃ§onnerie':
        return Icons.construction_outlined;
      default:
        return Icons.work_outline_rounded;
    }
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onTap});

  final Map<String, dynamic> job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOpen = job['status'] == 'open';
    final hasOffers = (job['offers'] as int) > 0;

    return Material(
      color: BrikolikColors.surface,
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: BrikolikColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(BrikolikRadius.sm),
                          ),
                          child: Icon(job['icon'] as IconData,
                              size: 20, color: BrikolikColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['category'],
                                style: const TextStyle(
                                  fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: BrikolikColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(job['time'],
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        isOpen ? StatusBadge.open() : StatusBadge.inProgress(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: BrikolikColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job['location'],
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: BrikolikColors.brandGradient,
                            borderRadius:
                                BorderRadius.circular(BrikolikRadius.full),
                          ),
                          child: Text(
                            job['budget'],
                            style: const TextStyle(
                              fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: BrikolikColors.surfaceVariant,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(BrikolikRadius.lg),
                    bottomRight: Radius.circular(BrikolikRadius.lg),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    BrikolikAvatar(name: job['name'], size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job['name'],
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StarRating(rating: job['rating'], starSize: 12),
                    const SizedBox(width: 8),
                    if (hasOffers)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BrikolikColors.accentLight,
                          borderRadius:
                              BorderRadius.circular(BrikolikRadius.full),
                          border: Border.all(
                              color:
                                  BrikolikColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${job['offers']} offre${job['offers'] > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: BrikolikColors.accent,
                          ),
                        ),
                      )
                    else
                      Text('Aucune offre'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: BrikolikColors.textHint,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.label,
    required this.icon,
    required this.values,
  });

  final String label;
  final IconData icon;
  final List<String> values;
}

