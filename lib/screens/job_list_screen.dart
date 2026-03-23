import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../models/app_models.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  int _selectedCategory = 0;
  int _bottomNavIndex   = 0;
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Tous',        'icon': Icons.grid_view_rounded},
    {'label': 'Plomberie',   'icon': Icons.water_drop_outlined},
    {'label': 'Électricité', 'icon': Icons.bolt_outlined},
    {'label': 'Nettoyage',   'icon': Icons.cleaning_services_outlined},
    {'label': 'Peinture',    'icon': Icons.format_paint_outlined},
    {'label': 'Jardinage',   'icon': Icons.grass_outlined},
  ];

  final List<Map<String, dynamic>> _jobs = [
    {
      'title':    'Réparation fuite eau salle de bain',
      'category': 'Plomberie',
      'icon':     Icons.water_drop_outlined,
      'location': 'Casablanca, Maarif',
      'budget':   '200–400 MAD',
      'time':     'Il y a 15 min',
      'status':   'open',
      'offers':   3,
      'name':     'Karim B.',
      'rating':   4.8,
    },
    {
      'title':    'Installation tableau électrique',
      'category': 'Électricité',
      'icon':     Icons.bolt_outlined,
      'location': 'Rabat, Agdal',
      'budget':   '600–900 MAD',
      'time':     'Il y a 1h',
      'status':   'open',
      'offers':   1,
      'name':     'Samira K.',
      'rating':   4.5,
    },
    {
      'title':    'Nettoyage appartement 3 pièces',
      'category': 'Nettoyage',
      'icon':     Icons.cleaning_services_outlined,
      'location': 'Marrakech, Guéliz',
      'budget':   '150–250 MAD',
      'time':     'Il y a 3h',
      'status':   'inprogress',
      'offers':   5,
      'name':     'Fatima A.',
      'rating':   4.9,
    },
    {
      'title':    'Peinture salon et couloir',
      'category': 'Peinture',
      'icon':     Icons.format_paint_outlined,
      'location': 'Fès, Saïss',
      'budget':   '800–1200 MAD',
      'time':     'Il y a 5h',
      'status':   'open',
      'offers':   0,
      'name':     'Youssef M.',
      'rating':   4.6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Poster un service',
                    style: TextStyle(
                      fontFamily: 'Nunito',
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: BrikolikColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour 👋',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: BrikolikColors.muted),
                ),
                Text(
                  'Services disponibles',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: BrikolikColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(BrikolikRadius.md),
                  border: Border.all(color: BrikolikColors.border),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined,
                      size: 22, color: BrikolikColors.textPrimary),
                  padding: EdgeInsets.zero,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: BrikolikColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/customer-profile'),
            child: const BrikolikAvatar(name: 'Karim B.', size: 42),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: BrikolikColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextFormField(
        controller: _searchCtrl,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: BrikolikColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Chercher un service…',
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
            child: const Icon(Icons.tune_rounded,
                size: 16, color: Colors.white),
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
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return CategoryChip(
                  label: cat['label'],
                  icon: cat['icon'],
                  selected: _selectedCategory == i,
                  onTap: () =>
                      setState(() => _selectedCategory = i),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        return JobCard(
          job: _jobs[i],
          onTap: () => Navigator.pushNamed(context, '/job-details'),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            activeIcon: Icon(Icons.work_rounded),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ── Job Card ───────────────────────────────────
class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen   = job['status'] == 'open';
    final hasOffers = (job['offers'] as int) > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
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
                  // Header row
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
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: BrikolikColors.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              job['time'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      isOpen
                          ? StatusBadge.open()
                          : StatusBadge.inProgress(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    job['title'],
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Location + budget
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
                            fontFamily: 'Nunito',
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

            // Footer
            Container(
              decoration: const BoxDecoration(
                color: BrikolikColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(BrikolikRadius.lg),
                  bottomRight: Radius.circular(BrikolikRadius.lg),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  BrikolikAvatar(name: job['name'], size: 28),
                  const SizedBox(width: 8),
                  Text(
                    job['name'],
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 8),
                  StarRating(rating: job['rating'], starSize: 12),
                  const Spacer(),
                  if (hasOffers)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrikolikColors.accentLight,
                        borderRadius:
                            BorderRadius.circular(BrikolikRadius.full),
                        border: Border.all(
                            color: BrikolikColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${job['offers']} offre${job['offers'] > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BrikolikColors.accent,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Aucune offre',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: BrikolikColors.textHint),
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
