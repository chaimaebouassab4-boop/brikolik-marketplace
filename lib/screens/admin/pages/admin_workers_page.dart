import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminWorkersPage extends StatefulWidget {
  const AdminWorkersPage({super.key});

  @override
  State<AdminWorkersPage> createState() => _AdminWorkersPageState();
}

class _AdminWorkersPageState extends State<AdminWorkersPage> {
  final TextEditingController _qCtrl = TextEditingController();
  String _query = '';
  bool _onlyPendingVerification = false;

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
          title: 'Artisans',
          subtitle: 'Gestion des profils artisans, services et verification.',
          trailing: SizedBox(
            width: 420,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qCtrl,
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher...',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  selected: _onlyPendingVerification,
                  onSelected: (v) =>
                      setState(() => _onlyPendingVerification = v),
                  label: const Text('En attente'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
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

              final docs = snapshot.data?.docs ?? const [];
              final rows = docs.map((d) {
                final data = d.data();
                return <String, dynamic>{...data, 'id': d.id};
              }).where((u) {
                final role = (u['role'] as String?)?.trim();
                if (role != 'worker') return false;
                if (_onlyPendingVerification &&
                    u['verificationRequested'] != true) {
                  return false;
                }
                if (_query.isEmpty) return true;
                final name = (u['fullName'] as String?)?.toLowerCase() ?? '';
                final email = (u['email'] as String?)?.toLowerCase() ?? '';
                final city = (u['city'] as String?)?.toLowerCase() ?? '';
                return name.contains(_query) ||
                    email.contains(_query) ||
                    city.contains(_query);
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
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Ville')),
                        DataColumn(label: Text('Services')),
                        DataColumn(label: Text('Verification')),
                        DataColumn(label: Text('Cree le')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows.map((u) {
                        final name = (u['fullName'] as String?)?.trim();
                        final email = (u['email'] as String?)?.trim();
                        final city = (u['city'] as String?)?.trim();
                        final createdAt = u['createdAt'] as Timestamp?;
                        final services = u['services'] is List
                            ? (u['services'] as List)
                                .map((e) => e.toString())
                                .where((e) => e.trim().isNotEmpty)
                                .take(3)
                                .join(', ')
                            : '-';
                        final verificationStatus =
                            (u['verificationStatus'] as String?)?.trim() ??
                                (u['verificationRequested'] == true
                                    ? 'pending'
                                    : (u['isVerified'] == true
                                        ? 'approved'
                                        : 'pending'));
                        final statusPill = _verificationPill(verificationStatus);

                        return DataRow(
                          cells: [
                            DataCell(Text(name?.isNotEmpty == true
                                ? name!
                                : 'Artisan')),
                            DataCell(Text(
                                email?.isNotEmpty == true ? email! : '-')),
                            DataCell(
                                Text(city?.isNotEmpty == true ? city! : '-')),
                            DataCell(Text(services.isNotEmpty ? services : '-')),
                            DataCell(statusPill),
                            DataCell(Text(_fmt(createdAt))),
                            DataCell(
                              TextButton(
                                onPressed: () => _showWorker(context, u),
                                child: const Text('Details'),
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

  static Widget _verificationPill(String status) {
    switch (status) {
      case 'approved':
        return const AdminPill(
          label: 'Approuve',
          color: BrikolikColors.success,
          bgColor: BrikolikColors.successLight,
        );
      case 'rejected':
        return const AdminPill(
          label: 'Refuse',
          color: BrikolikColors.error,
          bgColor: BrikolikColors.errorLight,
        );
      default:
        return const AdminPill(
          label: 'En attente',
          color: BrikolikColors.warning,
          bgColor: BrikolikColors.warningLight,
        );
    }
  }

  void _showWorker(BuildContext context, Map<String, dynamic> u) {
    final name = (u['fullName'] as String?)?.trim();
    final email = (u['email'] as String?)?.trim();
    final phone = (u['phone'] as String?)?.trim();
    final city = (u['city'] as String?)?.trim();
    final bio = (u['bio'] as String?)?.trim();
    final services = u['services'] is List
        ? (u['services'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .join(', ')
        : '';
    final id = (u['id'] as String?) ?? '';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name?.isNotEmpty == true ? name! : 'Artisan'),
        content: Text(
          'ID: $id\nEmail: ${email ?? '-'}\nTelephone: ${phone ?? '-'}\nVille: ${city ?? '-'}\n\nServices: ${services.isNotEmpty ? services : '-'}\n\nBio: ${bio?.isNotEmpty == true ? bio : '-'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
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

