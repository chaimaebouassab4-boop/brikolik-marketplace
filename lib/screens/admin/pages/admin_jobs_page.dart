import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminJobsPage extends StatefulWidget {
  const AdminJobsPage({super.key});

  @override
  State<AdminJobsPage> createState() => _AdminJobsPageState();
}

class _AdminJobsPageState extends State<AdminJobsPage> {
  String _status = 'inprogress';
  static const _filters = <String>['inprogress', 'done', 'all'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageHeader(
          title: 'Missions',
          subtitle: 'Missions en cours et terminees (jobs acceptes).',
          trailing: DropdownButton<String>(
            value: _status,
            items: _filters
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(_labelStatus(f)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? 'inprogress'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: BrikolikColors.primary),
                );
              }
              if (snapshot.hasError) {
                return AdminCard(child: Text('Erreur: ${snapshot.error}'));
              }

              final rows = (snapshot.data?.docs ?? const []).map((d) {
                final data = d.data();
                return <String, dynamic>{...data, 'id': d.id};
              }).where((j) {
                final status = (j['status'] as String?)?.trim() ?? 'open';
                final accepted = (j['acceptedWorkerId'] as String?)?.trim();
                final isMission = accepted != null && accepted.isNotEmpty;
                if (!isMission) return false;
                if (_status == 'all') return true;
                return status == _status;
              }).toList();

              rows.sort((a, b) => _compareTsDesc(a['acceptedAt'], b['acceptedAt']));

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
                        DataColumn(label: Text('Titre')),
                        DataColumn(label: Text('Artisan')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Acceptee le')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows.map((j) {
                        final id = (j['id'] as String?) ?? '';
                        final title = (j['title'] as String?)?.trim();
                        final worker = (j['acceptedWorkerName'] as String?)?.trim();
                        final status = (j['status'] as String?)?.trim() ?? 'inprogress';
                        final acceptedAt = j['acceptedAt'] as Timestamp?;

                        return DataRow(
                          cells: [
                            DataCell(Text(title?.isNotEmpty == true
                                ? title!
                                : 'Mission')),
                            DataCell(Text(worker?.isNotEmpty == true ? worker! : '-')),
                            DataCell(_statusPill(status)),
                            DataCell(Text(_fmt(acceptedAt))),
                            DataCell(
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/job-details',
                                  arguments: id,
                                ),
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

  static String _labelStatus(String f) {
    switch (f) {
      case 'done':
        return 'Terminees';
      case 'inprogress':
        return 'En cours';
      default:
        return 'Toutes';
    }
  }

  static Widget _statusPill(String status) {
    switch (status) {
      case 'done':
        return const AdminPill(
          label: 'Termine',
          color: BrikolikColors.textSecondary,
          bgColor: BrikolikColors.surfaceVariant,
        );
      default:
        return const AdminPill(
          label: 'En cours',
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

