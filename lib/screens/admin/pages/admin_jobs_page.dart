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
          subtitle:
              'Suivi des missions en cours, terminees et des revenus lies.',
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
            builder: (context, jobsSnapshot) {
              if (jobsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: BrikolikColors.primary),
                );
              }
              if (jobsSnapshot.hasError) {
                return AdminCard(
                  child: Text('Erreur missions: ${jobsSnapshot.error}'),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('offers')
                    .snapshots(),
                builder: (context, offersSnapshot) {
                  if (offersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: BrikolikColors.primary,
                      ),
                    );
                  }
                  if (offersSnapshot.hasError) {
                    return AdminCard(
                      child: Text(
                          'Erreur revenus missions: ${offersSnapshot.error}'),
                    );
                  }

                  final offerDocs = offersSnapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final acceptedOffersByJob = <String, Map<String, dynamic>>{};
                  for (final doc in offerDocs) {
                    final data = doc.data();
                    if ((data['status'] as String?)?.trim() != 'accepted') {
                      continue;
                    }
                    final jobId = doc.reference.parent.parent?.id ?? '';
                    if (jobId.isEmpty) continue;
                    acceptedOffersByJob[jobId] = {
                      ...data,
                      'id': doc.id,
                      'jobId': jobId,
                    };
                  }

                  final jobDocs = jobsSnapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final missions = jobDocs.map((d) {
                    final data = d.data();
                    final acceptedOffer = acceptedOffersByJob[d.id];
                    return <String, dynamic>{
                      ...data,
                      'id': d.id,
                      'acceptedPrice': acceptedOffer?['price'] ??
                          data['acceptedPrice'] ??
                          data['budgetMax'] ??
                          data['budget'],
                    };
                  }).where((job) {
                    final status = (job['status'] as String?)?.trim() ?? 'open';
                    final accepted =
                        (job['acceptedWorkerId'] as String?)?.trim();
                    final isMission = accepted != null && accepted.isNotEmpty;
                    if (!isMission) return false;
                    if (_status == 'all') return true;
                    return status == _status;
                  }).toList();

                  missions.sort(
                    (a, b) => _compareTsDesc(
                      a['acceptedAt'] ?? a['updatedAt'],
                      b['acceptedAt'] ?? b['updatedAt'],
                    ),
                  );

                  final totalRevenue = missions.fold<double>(
                    0.0,
                    (sum, job) => sum + _moneyValue(job['acceptedPrice']),
                  );
                  final completed = missions.where((job) {
                    return (job['status'] as String?)?.trim() == 'done';
                  }).length;
                  final inProgress = missions.where((job) {
                    return (job['status'] as String?)?.trim() == 'inprogress';
                  }).length;
                  final avgRevenue = missions.isEmpty
                      ? 0.0
                      : totalRevenue / missions.length.toDouble();

                  return Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _summaryCard(
                            'Missions filtrees',
                            '${missions.length}',
                            Icons.work_outline_rounded,
                            BrikolikColors.primaryLight,
                          ),
                          _summaryCard(
                            'En cours',
                            '$inProgress',
                            Icons.pending_actions_outlined,
                            BrikolikColors.warningLight,
                          ),
                          _summaryCard(
                            'Terminees',
                            '$completed',
                            Icons.task_alt_outlined,
                            BrikolikColors.successLight,
                          ),
                          _summaryCard(
                            'Revenus',
                            _money(totalRevenue),
                            Icons.payments_outlined,
                            BrikolikColors.secondaryLight,
                          ),
                          _summaryCard(
                            'Moyenne / mission',
                            _money(avgRevenue),
                            Icons.analytics_outlined,
                            BrikolikColors.accentLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AdminCard(
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
                                  DataColumn(label: Text('Client')),
                                  DataColumn(label: Text('Artisan')),
                                  DataColumn(label: Text('Montant')),
                                  DataColumn(label: Text('Statut')),
                                  DataColumn(label: Text('Acceptee le')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: missions.map((job) {
                                  final id = (job['id'] as String?) ?? '';
                                  final title =
                                      (job['title'] as String?)?.trim();
                                  final customer =
                                      (job['customerName'] as String?)?.trim();
                                  final worker =
                                      (job['acceptedWorkerName'] as String?)
                                          ?.trim();
                                  final status =
                                      (job['status'] as String?)?.trim() ??
                                          'inprogress';
                                  final acceptedAt =
                                      job['acceptedAt'] as Timestamp?;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        title?.isNotEmpty == true
                                            ? title!
                                            : 'Mission',
                                      )),
                                      DataCell(Text(
                                        customer?.isNotEmpty == true
                                            ? customer!
                                            : '-',
                                      )),
                                      DataCell(Text(
                                        worker?.isNotEmpty == true
                                            ? worker!
                                            : '-',
                                      )),
                                      DataCell(Text(_money(
                                          _moneyValue(job['acceptedPrice'])))),
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
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    IconData icon,
    Color iconBg,
  ) {
    return SizedBox(
      width: 210,
      child: AdminKpiCard(
        label: label,
        value: value,
        icon: icon,
        iconBg: iconBg,
      ),
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

  static double _moneyValue(dynamic raw) {
    if (raw is num) return raw.toDouble();
    final text = (raw ?? '').toString().trim().replaceAll(',', '.');
    if (text.isEmpty) return 0;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  static String _money(double amount) => '${amount.toStringAsFixed(0)} MAD';
}
