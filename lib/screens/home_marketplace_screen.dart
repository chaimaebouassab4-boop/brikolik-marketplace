import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../widgets/brk_marketplace_cards.dart';

class HomeMarketplaceScreen extends StatefulWidget {
  const HomeMarketplaceScreen({super.key});

  @override
  State<HomeMarketplaceScreen> createState() => _HomeMarketplaceScreenState();
}

class _HomeMarketplaceScreenState extends State<HomeMarketplaceScreen> {
  static const List<BrkCategory> _categories = [
    BrkCategory(
      key: 'Plomberie',
      label: 'Plomberie',
      icon: Icons.water_drop_outlined,
      coverGradient: [Color(0xFF3178C6), Color(0xFF27478D)],
    ),
    BrkCategory(
      key: 'Electricite',
      label: 'Electricite',
      icon: Icons.bolt_outlined,
      coverGradient: [Color(0xFF7A5AF8), Color(0xFF5A3CC6)],
    ),
    BrkCategory(
      key: 'Nettoyage',
      label: 'Nettoyage',
      icon: Icons.cleaning_services_outlined,
      coverGradient: [Color(0xFF2E9D8F), Color(0xFF1E6F66)],
    ),
    BrkCategory(
      key: 'Peinture',
      label: 'Peinture',
      icon: Icons.format_paint_outlined,
      coverGradient: [Color(0xFFEE7A3B), Color(0xFFB45624)],
    ),
  ];

  static const List<BrkServiceItem> _mockFallback = [
    BrkServiceItem(
      id: 'mock-1',
      title: 'Reparation plomberie express',
      category: 'Plomberie',
      description: 'Depannage rapide pour fuites, robinets et evacuations.',
      priceLabel: 'A partir de 180 MAD',
      rating: 4.9,
      reviewsCount: 84,
      jobsCount: 220,
      location: 'Casablanca',
      providerId: 'mock-provider-1',
      providerName: 'Atelier Hamza',
      providerRating: 4.8,
      providerJobs: 320,
      includes: ['Diagnostic', 'Main d oeuvre', 'Finition propre'],
      reviewsPreview: [
        BrkReview(
          author: 'Yassine',
          comment: 'Intervention en moins d une heure, tres pro.',
          rating: 5,
          dateLabel: '12 mars',
        ),
      ],
      isVerifiedProvider: true,
    ),
    BrkServiceItem(
      id: 'mock-2',
      title: 'Installation et maintenance electrique',
      category: 'Electricite',
      description: 'Pose luminaires, prises, tableaux et verification securite.',
      priceLabel: 'A partir de 250 MAD',
      rating: 4.7,
      reviewsCount: 55,
      jobsCount: 148,
      location: 'Rabat',
      providerId: 'mock-provider-2',
      providerName: 'Noura Elec',
      providerRating: 4.7,
      providerJobs: 180,
      includes: ['Visite', 'Installation', 'Test final'],
      reviewsPreview: [
        BrkReview(
          author: 'Salma',
          comment: 'Travail propre et ponctuel.',
          rating: 4.7,
          dateLabel: '05 fev',
        ),
      ],
    ),
  ];

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Accueil',
        showBackButton: false,
        useBrandBackground: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          final services = _buildServices(snapshot);
          final query = _searchCtrl.text.trim().toLowerCase();
          final filtered = services.where((s) {
            if (query.isEmpty) return true;
            return s.title.toLowerCase().contains(query) ||
                s.category.toLowerCase().contains(query);
          }).toList();
          final featured = filtered.take(6).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _FadeSlideIn(
                    delayMs: 0,
                    child: Column(
                    children: [
                      const _MarketplaceIntroCard(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                    ],
                  ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SectionHeaderPremium(
                    title: 'Categories',
                    actionLabel: 'Voir tout',
                    onAction: () => Navigator.pushNamed(context, '/jobs'),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _categories[index];
                      return BrkCategoryCard(
                        category: category,
                        onTap: () => Navigator.pushNamed(context, '/jobs'),
                      );
                    },
                    childCount: _categories.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.52,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _SectionHeaderPremium(
                    title: 'Featured services',
                    actionLabel: 'Explorer',
                    onAction: () => Navigator.pushNamed(context, '/jobs'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 232,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: ListView.separated(
                    key: ValueKey<int>(featured.length),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    itemCount: featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final service = featured[index];
                      return BrkFeaturedServiceCard(
                        service: service,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/service-details',
                          arguments: service,
                        ),
                      );
                    },
                  ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: _SectionHeaderPremium(
                    title: 'Popular services',
                    actionLabel: 'Voir tout',
                    onAction: () => Navigator.pushNamed(context, '/jobs'),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 110),
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Aucun service trouve',
                      subtitle: 'Essayez une autre recherche ou explorez les categories.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = filtered[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == filtered.length - 1 ? 0 : 10,
                          ),
                          child: BrkCompactServiceCard(
                            service: service,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/service-details',
                              arguments: service,
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BrikolikBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Chercher un service',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: const Icon(Icons.tune_rounded),
          filled: true,
          fillColor: BrikolikColors.surface,
        ),
      ),
    );
  }

  List<BrkServiceItem> _buildServices(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    final docs = snapshot.data?.docs ?? const [];
    if (docs.isEmpty) return _mockFallback;
    return docs
        .map((doc) => BrkServiceItem.fromJobMap(id: doc.id, data: doc.data()))
        .toList();
  }
}

class _MarketplaceIntroCard extends StatelessWidget {
  const _MarketplaceIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrikolikColors.brandGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketplace Brikolik',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Decouvrez des services fiables, compares par prix, notes et disponibilite.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderPremium extends StatelessWidget {
  const _SectionHeaderPremium({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: BrikolikColors.brandGradient,
            borderRadius: BorderRadius.circular(BrikolikRadius.full),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 1),
              Text(
                _subtitleForTitle(title),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BrikolikColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }

  String _subtitleForTitle(String title) {
    switch (title) {
      case 'Categories':
        return 'Choisissez votre besoin principal';
      case 'Featured services':
        return 'Selection premium selon la demande';
      case 'Popular services':
        return 'Services les plus consultes';
      default:
        return '';
    }
  }
}

class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        offset: _visible ? Offset.zero : const Offset(0, 0.02),
        child: widget.child,
      ),
    );
  }
}
