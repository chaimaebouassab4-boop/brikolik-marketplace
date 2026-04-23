import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: const BrikolikAppBar(
        title: 'Notifications',
        showBackButton: false,
        useBrandBackground: false,
      ),
      body: uid == null
          ? EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Connexion requise',
              subtitle:
                  'Connectez-vous pour suivre vos offres, demandes et validations.',
              actionLabel: 'Connexion',
              onAction: () => Navigator.pushNamed(context, '/login'),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .limit(80)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: BrikolikColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Erreur notifications: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
                  ...?snapshot.data?.docs,
                ]..sort((a, b) {
                    final aDate = _timestampToDate(a.data()['createdAt']);
                    final bDate = _timestampToDate(b.data()['createdAt']);
                    return bDate.compareTo(aDate);
                  });

                if (docs.isEmpty) {
                  return const _EmptyNotifications();
                }

                final unreadCount =
                    docs.where((doc) => doc.data()['isRead'] != true).length;

                return Column(
                  children: [
                    _NotificationsHeader(
                      totalCount: docs.length,
                      unreadCount: unreadCount,
                      onMarkAllRead:
                          unreadCount == 0 ? null : () => _markAllRead(docs),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return _NotificationCard(
                            id: doc.id,
                            data: doc.data(),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: docs.length,
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar:
          uid == null ? null : const BrikolikBottomNav(currentIndex: 2),
    );
  }

  static DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Future<void> _markAllRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final unreadDocs = docs.where((doc) => doc.data()['isRead'] != true);
    await Future.wait(
      unreadDocs.map(
        (doc) => doc.reference.update({'isRead': true}),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.totalCount,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  final int totalCount;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: BrikolikColors.surface,
        border: Border(bottom: BorderSide(color: BrikolikColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: unreadCount > 0
                  ? BrikolikColors.primaryLight
                  : BrikolikColors.surfaceVariant,
              borderRadius: BorderRadius.circular(BrikolikRadius.md),
            ),
            child: Icon(
              unreadCount > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: unreadCount > 0
                  ? BrikolikColors.primary
                  : BrikolikColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unreadCount == 0
                      ? 'Tout est a jour'.tr()
                      : '$unreadCount ${'nouvelle(s) notification(s)'.tr()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalCount ${'evenement(s) recent(s)'.tr()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onMarkAllRead,
            child: Text('Tout lire'.tr()),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final type = (data['type'] as String? ?? '').trim();
    final meta = _NotificationMeta.fromType(type);
    final isRead = data['isRead'] == true;
    final createdAt = NotificationsScreen._timestampToDate(data['createdAt']);
    final destination = _destinationRoute(type, data);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        onTap: () => _handleTap(context, destination),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                isRead ? BrikolikColors.surface : BrikolikColors.primaryLight,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
            border: Border.all(
              color: isRead
                  ? BrikolikColors.border
                  : BrikolikColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(BrikolikRadius.md),
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 22),
                  ),
                  if (!isRead)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: BrikolikColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BrikolikColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (data['title'] as String? ?? 'Notification').tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontFamilyFallback: ['Cairo'],
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: BrikolikColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TypePill(meta: meta),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      (data['body'] as String? ?? '').trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _timeAgo(createdAt).tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                destination == null
                    ? Icons.done_rounded
                    : Icons.chevron_right_rounded,
                color: BrikolikColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    _NotificationDestination? destination,
  ) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});

    if (!context.mounted || destination == null) return;
    Navigator.pushNamed(context, destination.route,
        arguments: destination.args);
  }

  _NotificationDestination? _destinationRoute(
    String type,
    Map<String, dynamic> data,
  ) {
    final jobId = (data['jobId'] as String? ?? '').trim();
    if (jobId.isNotEmpty) {
      return _NotificationDestination('/job-details', jobId);
    }
    if (type == 'worker_profile_approved') {
      return const _NotificationDestination('/worker-profile');
    }
    return null;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (date.millisecondsSinceEpoch == 0 || diff.inMinutes < 1) {
      return 'A l instant';
    }
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.meta});

  final _NotificationMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BrikolikRadius.full),
      ),
      child: Text(
        meta.label.tr(),
        style: TextStyle(
          fontFamily: 'Nunito',
          fontFamilyFallback: const ['Cairo'],
          color: meta.color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    const examples = [
      ('Offres', Icons.local_offer_outlined),
      ('Acceptations', Icons.task_alt_rounded),
      ('Urgent', Icons.priority_high_rounded),
      ('Demandes proches', Icons.travel_explore_rounded),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: BrikolikColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: BrikolikColors.border),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: BrikolikColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune notification'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Les offres, validations, demandes urgentes et nouvelles missions proches apparaitront ici.'
                  .tr(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final example in examples)
                  Chip(
                    avatar: Icon(example.$2, size: 16),
                    label: Text(example.$1.tr()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationMeta {
  const _NotificationMeta({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  static _NotificationMeta fromType(String type) {
    switch (type) {
      case 'new_offer':
        return const _NotificationMeta(
          icon: Icons.local_offer_outlined,
          color: BrikolikColors.primary,
          label: 'Offre',
        );
      case 'mission_accepted':
        return const _NotificationMeta(
          icon: Icons.task_alt_rounded,
          color: BrikolikColors.success,
          label: 'Acceptee',
        );
      case 'request_updated':
        return const _NotificationMeta(
          icon: Icons.edit_note_rounded,
          color: BrikolikColors.secondary,
          label: 'Mise a jour',
        );
      case 'urgent_activated':
        return const _NotificationMeta(
          icon: Icons.priority_high_rounded,
          color: BrikolikColors.error,
          label: 'Urgent',
        );
      case 'worker_profile_approved':
        return const _NotificationMeta(
          icon: Icons.verified_user_outlined,
          color: BrikolikColors.success,
          label: 'Profil',
        );
      case 'nearby_request':
        return const _NotificationMeta(
          icon: Icons.travel_explore_rounded,
          color: BrikolikColors.warning,
          label: 'Proche',
        );
      default:
        return const _NotificationMeta(
          icon: Icons.notifications_none_rounded,
          color: BrikolikColors.textSecondary,
          label: 'Info',
        );
    }
  }
}

class _NotificationDestination {
  const _NotificationDestination(this.route, [this.args]);

  final String route;
  final Object? args;
}
