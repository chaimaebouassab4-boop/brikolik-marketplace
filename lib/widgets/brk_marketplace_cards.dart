import 'package:flutter/material.dart';

import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class BrkCategoryCard extends StatelessWidget {
  const BrkCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final BrkCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          gradient: LinearGradient(colors: category.coverGradient),
          boxShadow: [
            BoxShadow(
              color: category.coverGradient.last.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(BrikolikRadius.sm),
                ),
                child: Icon(category.icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontFamilyFallback: ['Cairo'],
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrkFeaturedServiceCard extends StatelessWidget {
  const BrkFeaturedServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  final BrkServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 272,
      child: _PressableCard(
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceImageHeader(service: service, height: 132),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StarRating(
                          rating: service.rating,
                          reviewCount: service.reviewsCount,
                          starSize: 13,
                        ),
                        const Spacer(),
                        _PricePill(priceLabel: service.priceLabel),
                      ],
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

class BrkCompactServiceCard extends StatelessWidget {
  const BrkCompactServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  final BrkServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
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
            _ServiceImageHeader(service: service, height: 92, width: 100),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StarRating(
                        rating: service.rating,
                        reviewCount: service.reviewsCount,
                        starSize: 12,
                      ),
                      const Spacer(),
                      _PricePill(priceLabel: service.priceLabel, compact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.jobsCount} jobs',
                    style: Theme.of(context).textTheme.bodySmall,
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

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ServiceImageHeader extends StatelessWidget {
  const _ServiceImageHeader({
    required this.service,
    required this.height,
    this.width,
  });

  final BrkServiceItem service;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BrikolikRadius.md),
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
              Image.network(
                service.imageUrl!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const _GradientPlaceholder(),
              )
            else
              const _GradientPlaceholder(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.30),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(BrikolikRadius.full),
                ),
                child: Text(
                  service.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                    fontFamilyFallback: ['Cairo'],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4E6CB0), Color(0xFF7D5EA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.handyman_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.priceLabel, this.compact = false});

  final String priceLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        gradient: BrikolikColors.brandGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.full),
      ),
      child: Text(
        priceLabel,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontFamilyFallback: const ['Cairo'],
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
