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
      appBar: BrikolikAppBar(title: 'Notifications', showBackButton: true),
      body: uid == null
          ? Center(child: Text('Connexion requise'.tr()))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .limit(50)
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

                final docs = [...snapshot.data?.docs ?? []]..sort((a, b) {
                    final aDate = _timestampToDate(a.data()['createdAt']);
                    final bDate = _timestampToDate(b.data()['createdAt']);
                    return bDate.compareTo(aDate);
                  });

                if (docs.isEmpty) {
                  return _EmptyNotifications();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _NotificationCard(
                      id: doc.id,
                      data: doc.data(),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: docs.length,
                );
              },
            ),
    );
  }

  static DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
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
    final isRead = data['isRead'] == true;
    final jobId = (data['jobId'] as String? ?? '').trim();

    return InkWell(
      borderRadius: BorderRadius.circular(BrikolikRadius.lg),
      onTap: () async {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(id)
            .update({'isRead': true});
        if (context.mounted && jobId.isNotEmpty) {
          Navigator.pushNamed(context, '/job-details', arguments: jobId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? BrikolikColors.surface : BrikolikColors.primaryLight,
          borderRadius: BorderRadius.circular(BrikolikRadius.lg),
          border: Border.all(
            color: isRead
                ? BrikolikColors.border
                : BrikolikColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor(type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(type), color: _typeColor(type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['title'] as String? ?? 'Notification').tr(),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontFamilyFallback: ['Cairo'],
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: BrikolikColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['body'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (!isRead) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nouveau'.tr(),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontFamilyFallback: const ['Cairo'],
                        color: BrikolikColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: BrikolikColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'new_offer':
        return Icons.local_offer_outlined;
      case 'mission_accepted':
        return Icons.task_alt_rounded;
      case 'urgent_activated':
        return Icons.priority_high_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'new_offer':
        return BrikolikColors.primary;
      case 'mission_accepted':
        return BrikolikColors.success;
      case 'urgent_activated':
        return BrikolikColors.error;
      default:
        return BrikolikColors.textSecondary;
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              'Les nouvelles offres, missions acceptees et boosts urgents apparaitront ici.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
