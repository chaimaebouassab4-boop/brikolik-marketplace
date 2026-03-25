import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Removed hardcoded _jobs list

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
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false),
            child: Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: BrikolikColors.primaryLight,
                border: Border.all(color: BrikolikColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'lib/assets/lasgbrik-removebg-preview.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.home_rounded,
                    color: BrikolikColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
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
        onChanged: (_) => setState(() {}),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: BrikolikColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final catFilter = _categories[_selectedCategory]['label'];
        
        // Filter locally by category
        final docs = snapshot.data?.docs.where((doc) {
          if (catFilter == 'Tous') return true;
          final d = doc.data() as Map<String, dynamic>;
          return d['category'] == catFilter;
        }).toList() ?? [];

        // Appliquer aussi le filtre de recherche simple (sur le titre)
        final query = _searchCtrl.text.trim().toLowerCase();
        final filteredDocs = docs.where((doc) {
          if (query.isEmpty) return true;
          final d = doc.data() as Map<String, dynamic>;
          final title = (d['title'] as String?)?.toLowerCase() ?? '';
          return title.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_off_outlined,
            title: 'Aucune mission trouvée',
            subtitle: 'Soyez le premier à poster une demande dans cette catégorie !',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: filteredDocs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final data = filteredDocs[i].data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? 'Autre';
            
            IconData icon = Icons.work_outline_rounded;
            switch(category) {
              case 'Plomberie': icon = Icons.water_drop_outlined; break;
              case 'Électricité': icon = Icons.bolt_outlined; break;
              case 'Nettoyage': icon = Icons.cleaning_services_outlined; break;
              case 'Peinture': icon = Icons.format_paint_outlined; break;
              case 'Jardinage': icon = Icons.grass_outlined; break;
              case 'Menuiserie': icon = Icons.carpenter_outlined; break;
              case 'Maçonnerie': icon = Icons.construction_outlined; break;
            }

            String timeStr = "À l'instant";
            final createdAt = data['createdAt'] as Timestamp?;
            if (createdAt != null) {
               final diff = DateTime.now().difference(createdAt.toDate());
               if (diff.inMinutes < 60) timeStr = 'Il y a ${diff.inMinutes} min';
               else if (diff.inHours < 24) timeStr = 'Il y a ${diff.inHours} h';
               else timeStr = 'Il y a ${diff.inDays} j';
            }

            final jobMap = {
              'status': data['status'] ?? 'open',
              'offers': data['offersCount'] ?? 0,
              'icon': icon,
              'category': category,
              'time': timeStr,
              'title': data['title'] ?? 'Sans titre',
              'location': data['location'] ?? '📍 Non spécifié',
              'budget': data['budget'] ?? '???',
              'name': data['customerName'] ?? 'Client',
              'rating': (data['rating'] ?? 0.0).toDouble(),
            };

            return JobCard(
              job: jobMap,
              onTap: () => Navigator.pushNamed(context, '/job-details'),
            );
          },
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
