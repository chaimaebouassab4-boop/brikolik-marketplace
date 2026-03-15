import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(context),
                  const SizedBox(height: 16),
                  _buildTitle(context),
                  const SizedBox(height: 20),
                  _buildInfoGrid(context),
                  const SizedBox(height: 24),
                  _buildDescription(context),
                  const SizedBox(height: 24),
                  _buildClientCard(context),
                  const SizedBox(height: 24),
                  _buildOffersSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: BrikolikColors.surface,
      foregroundColor: BrikolikColors.textPrimary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: BrikolikColors.surface,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            backgroundColor: BrikolikColors.surface,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF0E6), Color(0xFFFFD9B8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: BrikolikColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BrikolikColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.water_drop_outlined,
                      size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Plomberie',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrikolikColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    return Row(
      children: [
        StatusBadge.open(),
        const SizedBox(width: 8),
        const Icon(Icons.access_time_rounded,
            size: 14, color: BrikolikColors.textHint),
        const SizedBox(width: 4),
        Text('Posté il y a 15 min',
            style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        const Icon(Icons.visibility_outlined,
            size: 14, color: BrikolikColors.textHint),
        const SizedBox(width: 4),
        Text('24 vues', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Réparation fuite eau\nsalle de bain',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Row(
        children: [
          _InfoTile(
            icon: Icons.payments_outlined,
            label: 'Budget',
            value: '200–400 MAD',
            color: BrikolikColors.success,
          ),
          _VerticalDivider(),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Lieu',
            value: 'Casablanca',
            color: BrikolikColors.primary,
          ),
          _VerticalDivider(),
          _InfoTile(
            icon: Icons.schedule_rounded,
            label: 'Délai',
            value: 'Urgent',
            color: BrikolikColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text(
          'La robinetterie du lavabo de ma salle de bain fuit depuis quelques jours. '
              'L\'eau goutte constamment même lorsque le robinet est fermé. '
              'J\'ai besoin d\'un plombier qualifié pour diagnostiquer et réparer le problème rapidement.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: BrikolikColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: Row(
            children: [
              const BrikolikAvatar(name: 'Karim Benali', size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Karim Benali',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const StarRating(rating: 4.8, reviewCount: 12),
                        const SizedBox(width: 8),
                        const Icon(Icons.shield_outlined,
                            size: 13, color: BrikolikColors.success),
                        const SizedBox(width: 3),
                        Text('Vérifié',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: BrikolikColors.success,
                            )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('12 missions publiées',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/chat'),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrikolikColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: BrikolikColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '3 offres reçues',
          actionLabel: 'Voir tout',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        _OfferCard(
          name: 'Hamid T.',
          rating: 4.9,
          reviews: 47,
          price: '350 MAD',
          message:
          'Je peux intervenir aujourd\'hui même. Plombier avec 8 ans d\'expérience.',
          isPro: true,
        ),
        const SizedBox(height: 10),
        _OfferCard(
          name: 'Rachid A.',
          rating: 4.5,
          reviews: 23,
          price: '280 MAD',
          message: 'Disponible demain matin, tarif compétitif.',
          isPro: false,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        border: const Border(
            top: BorderSide(color: BrikolikColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BrikolikButton(
              label: 'Faire une offre',
              onPressed: () {},
              icon: Icons.send_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: BrikolikColors.surfaceVariant,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded,
                  color: BrikolikColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: BrikolikColors.textHint,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: BrikolikColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: BrikolikColors.divider,
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviews;
  final String price;
  final String message;
  final bool isPro;

  const _OfferCard({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.message,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(
          color: isPro ? BrikolikColors.primary : BrikolikColors.border,
          width: isPro ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BrikolikAvatar(name: name, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleSmall),
                        if (isPro) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BrikolikColors.primaryLight,
                              borderRadius:
                              BorderRadius.circular(BrikolikRadius.full),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: BrikolikColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    StarRating(rating: rating, reviewCount: reviews),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: BrikolikColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BrikolikButton(
                  label: 'Accepter',
                  onPressed: () {},
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrikolikButton(
                  label: 'Contacter',
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                  outlined: true,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}