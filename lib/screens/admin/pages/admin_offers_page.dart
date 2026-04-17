import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminOffersPage extends StatefulWidget {
  const AdminOffersPage({super.key});

  @override
  State<AdminOffersPage> createState() => _AdminOffersPageState();
}

class _AdminOffersPageState extends State<AdminOffersPage> {
  String _status = 'all';
  static const _filters = <String>['all', 'accepted', 'pending'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageHeader(
          title: 'Offres',
          subtitle: 'Suivi des offres envoyees sur les demandes.',
          trailing: DropdownButton<String>(
            value: _status,
            items: _filters
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(_label(f)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? 'all'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collectionGroup('offers')
                .snapshots(),
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
                    'Erreur offres: ${snapshot.error}\n\nAstuce: activez collectionGroup et regles Firestore si besoin.',
                  ),
                );
              }

              final rows = (snapshot.data?.docs ?? const []).map((d) {
                final data = d.data();
                final status = (data['status'] as String?)?.trim() ?? 'pending';
                final jobId = d.reference.parent.parent?.id ?? '';
                return <String, dynamic>{
                  ...data,
                  'id': d.id,
                  'jobId': jobId,
                  '_createdAt': data['createdAt'],
                  '_status': status,
                };
              }).where((o) {
                final s = (o['_status'] as String?) ?? 'pending';
                if (_status == 'all') return true;
                return s == _status;
              }).toList();

              rows.sort(
                  (a, b) => _compareTsDesc(a['_createdAt'], b['_createdAt']));

              return AdminCard(
                padding: const EdgeInsets.all(0),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: const WidgetStatePropertyAll(
                        BrikolikColors.surfaceVariant,
                      ),
                      columns: const [
                        DataColumn(label: Text('Artisan')),
                        DataColumn(label: Text('Prix')),
                        DataColumn(label: Text('Job ID')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Cree le')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows.map((o) {
                        final worker = (o['workerName'] as String?)?.trim();
                        final price = (o['price'] as String?)?.trim();
                        final jobId = (o['jobId'] as String?)?.trim();
                        final createdAt = o['_createdAt'] as Timestamp?;
                        final status = (o['_status'] as String?) ?? 'pending';

                        return DataRow(
                          cells: [
                            DataCell(Text(worker?.isNotEmpty == true
                                ? worker!
                                : 'Artisan')),
                            DataCell(Text(price?.isNotEmpty == true ? price! : '-')),
                            DataCell(Text(jobId?.isNotEmpty == true ? jobId! : '-')),
                            DataCell(_statusPill(status)),
                            DataCell(Text(_fmt(createdAt))),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  if (jobId == null || jobId.isEmpty) return;
                                  Navigator.pushNamed(
                                    context,
                                    '/job-details',
                                    arguments: jobId,
                                  );
                                },
                                child: const Text('Voir demande'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _label(String f) {
    switch (f) {
      case 'accepted':
        return 'Acceptees';
      case 'pending':
        return 'En attente';
      default:
        return 'Toutes';
    }
  }

  static Widget _statusPill(String status) {
    switch (status) {
      case 'accepted':
        return const AdminPill(
          label: 'Acceptee',
          color: BrikolikColors.success,
          bgColor: BrikolikColors.successLight,
        );
      default:
        return const AdminPill(
          label: 'En attente',
          color: BrikolikColors.warning,
          bgColor: BrikolikColors.warningLight,
        );
    }
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
