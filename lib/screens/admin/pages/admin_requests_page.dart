import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  final TextEditingController _qCtrl = TextEditingController();
  String _query = '';
  String _status = 'open';

  static const _filters = <String>['open', 'inprogress', 'done', 'all'];

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageHeader(
          title: 'Demandes de service',
          subtitle: 'Suivi des demandes, statut, offres et details.',
          trailing: SizedBox(
            width: 520,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qCtrl,
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher par titre/ville/categorie...',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _status,
                  items: _filters
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(_labelStatus(f)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? 'open'),
                ),
              ],
            ),
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
                if (_status != 'all' && status != _status) return false;
                if (_query.isEmpty) return true;
                final title = (j['title'] as String?)?.toLowerCase() ?? '';
                final city = (j['city'] as String?)?.toLowerCase() ?? '';
                final category = (j['category'] as String?)?.toLowerCase() ?? '';
                return title.contains(_query) ||
                    city.contains(_query) ||
                    category.contains(_query);
              }).toList();

              rows.sort((a, b) => _compareTsDesc(a['createdAt'], b['createdAt']));

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
                        DataColumn(label: Text('Categorie')),
                        DataColumn(label: Text('Ville')),
                        DataColumn(label: Text('Offres')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Cree le')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows.map((j) {
                        final id = (j['id'] as String?) ?? '';
                        final title = (j['title'] as String?)?.trim();
                        final category = (j['category'] as String?)?.trim();
                        final city = (j['city'] as String?)?.trim();
                        final offers = (j['offersCount'] as num?)?.toInt() ?? 0;
                        final status = (j['status'] as String?)?.trim() ?? 'open';
                        final createdAt = j['createdAt'] as Timestamp?;
                        return DataRow(
                          cells: [
                            DataCell(Text(title?.isNotEmpty == true
                                ? title!
                                : 'Demande')),
                            DataCell(Text(
                                category?.isNotEmpty == true ? category! : '-')),
                            DataCell(Text(city?.isNotEmpty == true ? city! : '-')),
                            DataCell(
                              AdminPill(
                                label: '$offers',
                                color: offers > 0
                                    ? BrikolikColors.primary
                                    : BrikolikColors.warning,
                                bgColor: offers > 0
                                    ? BrikolikColors.primaryLight
                                    : BrikolikColors.warningLight,
                              ),
                            ),
                            DataCell(_statusPill(status)),
                            DataCell(Text(_fmt(createdAt))),
                            DataCell(
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/job-details',
                                      arguments: id,
                                    ),
                                    child: const Text('Voir'),
                                  ),
                                ],
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

  static String _labelStatus(String status) {
    switch (status) {
      case 'done':
        return 'Terminees';
      case 'inprogress':
        return 'En cours';
      case 'open':
        return 'Ouvertes';
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
      case 'inprogress':
        return const AdminPill(
          label: 'En cours',
          color: BrikolikColors.warning,
          bgColor: BrikolikColors.warningLight,
        );
      default:
        return const AdminPill(
          label: 'Ouvert',
          color: BrikolikColors.success,
          bgColor: BrikolikColors.successLight,
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

