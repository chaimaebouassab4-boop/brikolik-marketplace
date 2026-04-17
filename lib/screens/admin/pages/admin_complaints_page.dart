import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminComplaintsPage extends StatefulWidget {
  const AdminComplaintsPage({super.key});

  @override
  State<AdminComplaintsPage> createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  String _filter = 'open';
  static const _filters = <String>['open', 'resolved', 'all'];
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageHeader(
          title: 'Reclamations',
          subtitle:
              "Traitement des plaintes (collection Firestore 'complaints').",
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _filter,
                items: _filters
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(_label(f)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _filter = v ?? 'open'),
              ),
              const SizedBox(width: 10),
              if (_isUpdating)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('complaints').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: BrikolikColors.primary),
                );
              }
              if (snapshot.hasError) {
                return AdminCard(
                  child: Text(
                    "Aucune donnee ou permissions manquantes.\nErreur: ${snapshot.error}",
                  ),
                );
              }

              final rows = (snapshot.data?.docs ?? const []).map((d) {
                final data = d.data();
                final status = (data['status'] as String?)?.trim() ?? 'open';
                return <String, dynamic>{...data, 'id': d.id, '_status': status};
              }).where((c) {
                if (_filter == 'all') return true;
                return (c['_status'] as String?) == _filter;
              }).toList();

              rows.sort((a, b) => _compareTsDesc(a['createdAt'], b['createdAt']));

              if (rows.isEmpty) {
                return const AdminCard(
                  child: Center(
                    child: Text(
                      'Aucune reclamation pour ce filtre.',
                      style: TextStyle(color: BrikolikColors.textSecondary),
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = rows[index];
                  final id = (c['id'] as String?) ?? '';
                  final title = (c['title'] as String?)?.trim();
                  final desc = (c['description'] as String?)?.trim();
                  final status = (c['_status'] as String?) ?? 'open';
                  final createdAt = c['createdAt'] as Timestamp?;
                  final jobId = (c['jobId'] as String?)?.trim();
                  final reporterId = (c['reporterId'] as String?)?.trim();
                  final targetUserId = (c['targetUserId'] as String?)?.trim();

                  return AdminCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title?.isNotEmpty == true
                                    ? title!
                                    : 'Reclamation',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            _statusPill(status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc?.isNotEmpty == true
                              ? desc!
                              : 'Aucune description.',
                          style: const TextStyle(
                            color: BrikolikColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _meta('Cree', _fmt(createdAt)),
                            if (jobId?.isNotEmpty == true) _meta('Job', jobId!),
                            if (reporterId?.isNotEmpty == true)
                              _meta('Reporter', reporterId!),
                            if (targetUserId?.isNotEmpty == true)
                              _meta('Cible', targetUserId!),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (jobId?.isNotEmpty == true)
                              OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/job-details',
                                  arguments: jobId,
                                ),
                                child: const Text('Voir demande'),
                              ),
                            const Spacer(),
                            if (status == 'open')
                              ElevatedButton.icon(
                                onPressed:
                                    _isUpdating ? null : () => _resolve(id),
                                icon: const Icon(Icons.task_alt_outlined),
                                label: const Text('Marquer resolu'),
                              )
                            else
                              OutlinedButton(
                                onPressed:
                                    _isUpdating ? null : () => _reopen(id),
                                child: const Text('Reouvrir'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _resolve(String id) async {
    if (id.isEmpty) return;
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(id).set({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _reopen(String id) async {
    if (id.isEmpty) return;
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(id).set({
        'status': 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  static String _label(String f) {
    switch (f) {
      case 'resolved':
        return 'Resolues';
      case 'open':
        return 'Ouvertes';
      default:
        return 'Toutes';
    }
  }

  static Widget _statusPill(String status) {
    switch (status) {
      case 'resolved':
        return const AdminPill(
          label: 'Resolu',
          color: BrikolikColors.textSecondary,
          bgColor: BrikolikColors.surfaceVariant,
        );
      default:
        return const AdminPill(
          label: 'Ouvert',
          color: BrikolikColors.warning,
          bgColor: BrikolikColors.warningLight,
        );
    }
  }

  static Widget _meta(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrikolikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
      ),
      child: Text(
        '$k: $v',
        style: const TextStyle(
          color: BrikolikColors.textSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  static int _compareTsDesc(dynamic a, dynamic b) {
    final aMillis = a is Timestamp ? a.millisecondsSinceEpoch : 0;
    final bMillis = b is Timestamp ? b.millisecondsSinceEpoch : 0;
    return bMillis.compareTo(aMillis);
  }

  static String _fmt(Timestamp? ts) {
    if (ts == null) return '-';
    final d = ts.toDate();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

