import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_HomeCategory> _categories = [
    _HomeCategory('Plomberie', Icons.water_drop_outlined),
    _HomeCategory('Electricite', Icons.bolt_outlined),
    _HomeCategory('Nettoyage', Icons.cleaning_services_outlined),
    _HomeCategory('Peinture', Icons.format_paint_outlined),
    _HomeCategory('Jardinage', Icons.grass_outlined),
    _HomeCategory('Menuiserie', Icons.carpenter_outlined),
  ];

  static const List<_WorkerPreview> _workers = [
    _WorkerPreview(
      name: 'Hamid Tazi',
      specialty: 'Plombier certifie',
      city: 'Casablanca',
      rating: 4.9,
      jobs: 126,
    ),
    _WorkerPreview(
      name: 'Souad El Idrissi',
      specialty: 'Electricienne',
      city: 'Rabat',
      rating: 4.8,
      jobs: 97,
    ),
    _WorkerPreview(
      name: 'Youssef Moutaoukil',
      specialty: 'Peintre interieur',
      city: 'Marrakech',
      rating: 4.7,
      jobs: 84,
    ),
  ];

  static const List<_JobPreview> _recentJobs = [
    _JobPreview(
      title: 'Fuite sous evier de cuisine',
      category: 'Plomberie',
      location: 'Casablanca - Maarif',
      budget: '250-450 MAD',
      postedAgo: 'Il y a 28 min',
    ),
    _JobPreview(
      title: 'Nettoyage complet appartement 90m2',
      category: 'Nettoyage',
      location: 'Rabat - Hay Riad',
      budget: '300-600 MAD',
      postedAgo: 'Il y a 54 min',
    ),
    _JobPreview(
      title: 'Installation luminaire salon',
      category: 'Electricite',
      location: 'Mohammedia - Centre',
      budget: '180-300 MAD',
      postedAgo: 'Il y a 1 h',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Accueil',
        showBackButton: false,
        useBrandBackground: false,
        actions: [
          IconButton(
            tooltip: 'Connexion',
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Entrance(
              delayMs: 0,
              child: _HeroSection(width: media.width),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SearchCard(
                onTap: () => Navigator.pushNamed(context, '/jobs'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _SectionTitle(
                title: 'Services populaires',
                actionLabel: 'Voir tout',
                onAction: () => Navigator.pushNamed(context, '/jobs'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _Entrance(
                delayMs: 80,
                child: _CategoryGrid(
                  categories: _categories,
                  onCategoryTap: (_) =>
                      Navigator.pushNamed(context, '/post-job'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _SectionTitle(
                title: 'Artisans recommandes',
                actionLabel: 'Devenir artisan',
                onAction: () => Navigator.pushNamed(context, '/worker-profile'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 202,
              child: _Entrance(
                delayMs: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  itemCount: _workers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _WorkerCard(
                      worker: _workers[index],
                      onTap: () =>
                          Navigator.pushNamed(context, '/worker-profile'),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _SectionTitle(
                title: 'Demandes recentes',
                actionLabel: 'Explorer',
                onAction: () => Navigator.pushNamed(context, '/jobs'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == _recentJobs.length - 1 ? 0 : 12),
                    child: _Entrance(
                      delayMs: 180 + (index * 40),
                      child: _JobCard(
                        data: _recentJobs[index],
                        onTap: () => Navigator.pushNamed(context, '/jobs'),
                      ),
                    ),
                  );
                },
                childCount: _recentJobs.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: _Entrance(
              delayMs: 260,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 26, 20, 0),
                child: _TrustBand(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
              child: BrikolikButton(
                label: 'Poster ma demande gratuitement',
                icon: Icons.add_rounded,
                onPressed: () => Navigator.pushNamed(context, '/post-job'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BrikolikBottomNav(currentIndex: 0),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (width * pixelRatio).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      height: 264,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/deuxherobriko.png',
              fit: BoxFit.cover,
              cacheWidth: cacheWidth,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF101E3A).withValues(alpha: 0.94),
                    const Color(0xFF243C73).withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(BrikolikRadius.full),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined,
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Artisans verifies au Maroc',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Reparez, entretenez, avancez.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 30,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Publiez votre besoin et recevez des offres fiables en quelques minutes.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrikolikColors.surface,
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: BrikolikColors.muted),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chercher un service ou un artisan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BrikolikColors.textSecondary,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: BrikolikColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
  });

  static const List<Color> _accents = [
    Color(0xFF4B6CB7),
    Color(0xFF7A5AA6),
    Color(0xFF2C8F8A),
    Color(0xFF7A8D32),
    Color(0xFFB36A3C),
    Color(0xFF5A7CB8),
  ];

  final List<_HomeCategory> categories;
  final ValueChanged<_HomeCategory> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final width = constraints.maxWidth;
        final columns = switch (width) {
          >= 1200 => 6,
          >= 950 => 5,
          >= 760 => 4,
          >= 520 => 3,
          _ => 2,
        };

        final tileWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < categories.length; i++)
              SizedBox(
                width: tileWidth,
                child: _ServiceTile(
                  item: categories[i],
                  accent: _accents[i % _accents.length],
                  onTap: () => onCategoryTap(categories[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  final _HomeCategory item;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrikolikColors.surface,
      borderRadius: BorderRadius.circular(BrikolikRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        onTap: onTap,
        child: Ink(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            border: Border.all(color: BrikolikColors.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.09),
                BrikolikColors.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(BrikolikRadius.sm),
                    ),
                    child: Icon(item.icon, size: 18, color: accent),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: BrikolikColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: accent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker, required this.onTap});

  final _WorkerPreview worker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 248,
      child: Material(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BrikolikRadius.lg),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BrikolikAvatar(name: worker.name, size: 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: BrikolikColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            worker.specialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrikolikColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: BrikolikColors.textHint),
                    const SizedBox(width: 4),
                    Text(worker.city,
                        style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    StarRating(rating: worker.rating, starSize: 13),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrikolikColors.primaryLight,
                    borderRadius: BorderRadius.circular(BrikolikRadius.full),
                  ),
                  child: Text(
                    '${worker.jobs} missions terminees',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrikolikColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.data, required this.onTap});

  final _JobPreview data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrikolikColors.surface,
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrikolikColors.primaryLight,
                      borderRadius: BorderRadius.circular(BrikolikRadius.full),
                    ),
                    child: Text(
                      data.category,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BrikolikColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(data.postedAgo,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: BrikolikColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: BrikolikColors.brandGradient,
                      borderRadius: BorderRadius.circular(BrikolikRadius.full),
                    ),
                    child: Text(
                      data.budget,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
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
      ),
    );
  }
}

class _TrustBand extends StatelessWidget {
  const _TrustBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrikolikColors.heroGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: _Metric(label: 'Artisans verifies', value: '2 000+')),
          _MiniDivider(),
          Expanded(child: _Metric(label: 'Villes couvertes', value: '26')),
          _MiniDivider(),
          Expanded(child: _Metric(label: 'Satisfaction', value: '4.8/5')),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: BrikolikColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: BrikolikColors.divider,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: BrikolikColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

class _Entrance extends StatefulWidget {
  const _Entrance({
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance> {
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
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.03),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _WorkerPreview {
  const _WorkerPreview({
    required this.name,
    required this.specialty,
    required this.city,
    required this.rating,
    required this.jobs,
  });

  final String name;
  final String specialty;
  final String city;
  final double rating;
  final int jobs;
}

class _JobPreview {
  const _JobPreview({
    required this.title,
    required this.category,
    required this.location,
    required this.budget,
    required this.postedAgo,
  });

  final String title;
  final String category;
  final String location;
  final String budget;
  final String postedAgo;
}
