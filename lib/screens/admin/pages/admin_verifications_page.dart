import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminVerificationsPage extends StatefulWidget {
  const AdminVerificationsPage({super.key});

  @override
  State<AdminVerificationsPage> createState() => _AdminVerificationsPageState();
}

class _AdminVerificationsPageState extends State<AdminVerificationsPage> {
  final AuthService _authService = AuthService();
  bool _isProcessing = false;
  String _filter = 'pending';

  static const _filters = <String>[
    'pending',
    'approved',
    'rejected',
    'all',
  ];

  Future<void> _approve(String userId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _authService.updateUserVerificationStatus(
        userId: userId,
        approved: true,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur approuve.'),
          backgroundColor: BrikolikColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur approbation: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject(String userId) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: TextField(
          controller: reasonCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Raison (optionnel)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonCtrl.text.trim()),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    reasonCtrl.dispose();
    if (reason == null) return;

    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _authService.updateUserVerificationStatus(
        userId: userId,
        approved: false,
        rejectionReason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande refusee.'),
          backgroundColor: BrikolikColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur refus: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageHeader(
          title: 'Verification artisans',
          subtitle:
              'File de validation manuelle (approuver/refuser) et historique.',
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
                onChanged: (v) => setState(() => _filter = v ?? 'pending'),
              ),
              const SizedBox(width: 10),
              if (_isProcessing)
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

              final users = (snapshot.data?.docs ?? const []).map((d) {
                final data = d.data();
                return <String, dynamic>{...data, 'id': d.id};
              }).toList();

              users.sort((a, b) {
                return _compareTsDesc(
                  a['verificationRequestedAt'],
                  b['verificationRequestedAt'],
                );
              });

              final filtered = users.where((u) {
                if (_filter == 'all') return true;
                return _statusOf(u) == _filter;
              }).toList();

              if (filtered.isEmpty) {
                return const AdminCard(
                  child: Center(
                    child: Text(
                      'Aucune demande pour ce filtre.',
                      style: TextStyle(color: BrikolikColors.textSecondary),
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final u = filtered[index];
                  final id = (u['id'] as String?) ?? '';
                  final name = (u['fullName'] as String?)?.trim();
                  final email = (u['email'] as String?)?.trim();
                  final role = (u['role'] as String?)?.trim() ?? 'unknown';
                  final status = _statusOf(u);
                  final services = u['services'] is List
                      ? (u['services'] as List)
                          .map((e) => e.toString())
                          .where((e) => e.trim().isNotEmpty)
                          .take(6)
                          .join(', ')
                      : '';
                  final requestedAt = u['verificationRequestedAt'] as Timestamp?;

                  return AdminCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name?.isNotEmpty == true
                                        ? name!
                                        : 'Utilisateur',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${email?.isNotEmpty == true ? email : '-'} • $role',
                                    style: const TextStyle(
                                      color: BrikolikColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _statusPill(status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Services: ${services.isNotEmpty ? services : '-'}',
                                style: const TextStyle(
                                  color: BrikolikColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              'Demande: ${_fmt(requestedAt)}',
                              style: const TextStyle(
                                color: BrikolikColors.textHint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (status == 'pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _isProcessing ? null : () => _reject(id),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Refuser'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: BrikolikColors.error,
                                    side: const BorderSide(
                                        color: BrikolikColors.error),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isProcessing ? null : () => _approve(id),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approuver'),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  static String _statusOf(Map<String, dynamic> data) {
    final status = (data['verificationStatus'] as String?)?.trim();
    if (status != null && status.isNotEmpty) return status;
    if (data['isVerified'] == true) return 'approved';
    if (data['verificationRequested'] == true) return 'pending';
    return 'pending';
  }

  static Widget _statusPill(String status) {
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

  static String _label(String f) {
    switch (f) {
      case 'approved':
        return 'Approuve';
      case 'rejected':
        return 'Refuse';
      case 'pending':
        return 'En attente';
      default:
        return 'Tout';
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
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} $hh:$mi';
  }
}

