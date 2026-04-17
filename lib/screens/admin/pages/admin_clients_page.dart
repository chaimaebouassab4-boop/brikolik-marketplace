import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminClientsPage extends StatefulWidget {
  const AdminClientsPage({super.key});

  @override
  State<AdminClientsPage> createState() => _AdminClientsPageState();
}

class _AdminClientsPageState extends State<AdminClientsPage> {
  final TextEditingController _qCtrl = TextEditingController();
  String _query = '';

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
          title: 'Clients',
          subtitle: 'Liste, recherche et suivi des comptes clients.',
          trailing: SizedBox(
            width: 360,
            child: TextField(
              controller: _qCtrl,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher par nom/email/telephone...',
                isDense: true,
              ),
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
                return AdminCard(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              final docs = snapshot.data?.docs ?? const [];
              final rows = docs.map((d) {
                final data = d.data();
                return <String, dynamic>{...data, 'id': d.id};
              }).where((u) {
                final role = (u['role'] as String?)?.trim();
                if (role != 'customer') return false;
                if (_query.isEmpty) return true;
                final name = (u['fullName'] as String?)?.toLowerCase() ?? '';
                final email = (u['email'] as String?)?.toLowerCase() ?? '';
                final phone = (u['phone'] as String?)?.toLowerCase() ?? '';
                return name.contains(_query) ||
                    email.contains(_query) ||
                    phone.contains(_query);
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
                        DataColumn(label: Text('Telephone')),
                        DataColumn(label: Text('Ville')),
                        DataColumn(label: Text('Cree le')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: rows.map((u) {
                        final name = (u['fullName'] as String?)?.trim();
                        final email = (u['email'] as String?)?.trim();
                        final phone = (u['phone'] as String?)?.trim();
                        final city = (u['city'] as String?)?.trim();
                        final createdAt = u['createdAt'] as Timestamp?;
                        final verified = u['isVerified'] == true;
                        return DataRow(
                          cells: [
                            DataCell(Text(name?.isNotEmpty == true
                                ? name!
                                : 'Client')),
                            DataCell(Text(
                                email?.isNotEmpty == true ? email! : '-')),
                            DataCell(Text(
                                phone?.isNotEmpty == true ? phone! : '-')),
                            DataCell(
                                Text(city?.isNotEmpty == true ? city! : '-')),
                            DataCell(Text(_fmt(createdAt))),
                            DataCell(
                              AdminPill(
                                label: verified ? 'Verifie' : 'Non verifie',
                                color: verified
                                    ? BrikolikColors.success
                                    : BrikolikColors.textSecondary,
                                bgColor: verified
                                    ? BrikolikColors.successLight
                                    : BrikolikColors.surfaceVariant,
                              ),
                            ),
                            DataCell(
                              TextButton(
                                onPressed: () => _showUser(context, u),
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

  void _showUser(BuildContext context, Map<String, dynamic> u) {
    final name = (u['fullName'] as String?)?.trim();
    final email = (u['email'] as String?)?.trim();
    final phone = (u['phone'] as String?)?.trim();
    final city = (u['city'] as String?)?.trim();
    final id = (u['id'] as String?) ?? '';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name?.isNotEmpty == true ? name! : 'Client'),
        content: Text(
          'ID: $id\nEmail: ${email ?? '-'}\nTelephone: ${phone ?? '-'}\nVille: ${city ?? '-'}',
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

