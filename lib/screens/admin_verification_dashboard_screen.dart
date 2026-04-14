import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class AdminVerificationDashboardScreen extends StatefulWidget {
  const AdminVerificationDashboardScreen({super.key});

  @override
  State<AdminVerificationDashboardScreen> createState() =>
      _AdminVerificationDashboardScreenState();
}

class _AdminVerificationDashboardScreenState
    extends State<AdminVerificationDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoadingAccess = true;
  bool _isAdmin = false;
  bool _isProcessing = false;
  String _statusFilter = 'pending';

  static const List<String> _filters = <String>[
    'pending',
    'approved',
    'rejected',
    'all',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    final isAdmin = await _authService.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _isLoadingAccess = false;
    });
  }

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
        SnackBar(
          content: Text('Utilisateur approuve.'.tr()),
          backgroundColor: BrikolikColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur approbation: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _reject(String userId) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Refuser la demande'.tr()),
          content: TextField(
            controller: reasonCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Raison du refus (optionnel)'.tr(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, reasonCtrl.text.trim()),
              child: Text('Refuser'.tr()),
            ),
          ],
        );
      },
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
        SnackBar(
          content: Text('Demande refusee.'.tr()),
          backgroundColor: BrikolikColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur refus: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _statusOf(Map<String, dynamic> data) {
    final status = (data['verificationStatus'] as String?)?.trim();
    if (status != null && status.isNotEmpty) {
      return status;
    }
    if (data['isVerified'] == true) return 'approved';
    if (data['verificationRequested'] == true) return 'pending';
    return 'pending';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return BrikolikColors.success;
      case 'rejected':
        return BrikolikColors.error;
      default:
        return BrikolikColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approuve';
      case 'rejected':
        return 'Refuse';
      case 'all':
        return 'Tous';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingAccess) {
      return const Scaffold(
        backgroundColor: BrikolikColors.background,
        body: Center(
          child: CircularProgressIndicator(color: BrikolikColors.primary),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: const BrikolikAppBar(title: 'Admin'),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Acces reserve',
            subtitle: 'Cette page est reservee aux administrateurs Brikolik.',
            actionLabel: 'Retour accueil',
            onAction: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: BrikolikAppBar(
        title: 'Demandes verification',
        actions: [
          IconButton(
            tooltip: 'Deconnexion admin',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(this.context)
                  .pushNamedAndRemoveUntil('/login', (_) => false);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = _statusFilter == filter;
                return ChoiceChip(
                  label: Text(_statusLabel(filter).tr()),
                  selected: selected,
                  onSelected: (_) => setState(() => _statusFilter = filter),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filters.length,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('users').snapshots(),
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
                      padding: const EdgeInsets.all(20),
                      child: Text('Erreur chargement: ${snapshot.error}'),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final users = docs
                    .map((d) => <String, dynamic>{
                          'id': d.id,
                          ...d.data(),
                        })
                    .where((u) {
                  final role = (u['role'] as String?)?.trim();
                  return role != 'admin';
                }).toList();

                users.sort((a, b) {
                  final aTime = a['verificationRequestedAt'];
                  final bTime = b['verificationRequestedAt'];
                  final aMillis =
                      aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
                  final bMillis =
                      bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
                  return bMillis.compareTo(aMillis);
                });

                final filtered = users.where((u) {
                  if (_statusFilter == 'all') return true;
                  return _statusOf(u) == _statusFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Aucune demande',
                    subtitle:
                        'Aucun utilisateur pour le filtre ${_statusLabel(_statusFilter)}.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final userId = user['id'] as String;
                    final name = (user['fullName'] as String?)?.trim();
                    final email = (user['email'] as String?)?.trim() ?? '-';
                    final role = (user['role'] as String?)?.trim() ?? 'unknown';
                    final status = _statusOf(user);
                    final statusColor = _statusColor(status);

                    final rawServices = user['services'];
                    final services = rawServices is List
                        ? rawServices
                            .map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList()
                        : <String>[];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: BrikolikColors.surface,
                        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                        border: Border.all(color: BrikolikColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (name != null && name.isNotEmpty)
                                          ? name
                                          : 'Utilisateur sans nom',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      BrikolikRadius.full),
                                ),
                                child: Text(
                                  _statusLabel(status).tr(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                icon: Icons.badge_outlined,
                                label: 'Role: $role',
                              ),
                              if (user['city'] != null &&
                                  user['city'].toString().trim().isNotEmpty)
                                _MetaChip(
                                  icon: Icons.location_city_outlined,
                                  label: user['city'].toString().trim(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Competences'.tr(),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          if (services.isEmpty)
                            Text('Aucune competence renseignee'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: services
                                  .map(
                                    (service) => Chip(
                                      label: Text(service),
                                      backgroundColor:
                                          BrikolikColors.surfaceVariant,
                                      side: const BorderSide(
                                        color: BrikolikColors.border,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          if (user['bio'] != null &&
                              user['bio'].toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              user['bio'].toString().trim(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (status == 'pending') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: BrikolikButton(
                                    label: 'Refuser',
                                    outlined: true,
                                    foregroundColor: BrikolikColors.error,
                                    onPressed: _isProcessing
                                        ? null
                                        : () => _reject(userId),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: BrikolikButton(
                                    label: 'Approuver',
                                    icon: Icons.check_rounded,
                                    isLoading: _isProcessing,
                                    onPressed: _isProcessing
                                        ? null
                                        : () => _approve(userId),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (status == 'rejected') ...[
                            BrikolikButton(
                              label: 'Approuver maintenant',
                              icon: Icons.check_rounded,
                              isLoading: _isProcessing,
                              onPressed:
                                  _isProcessing ? null : () => _approve(userId),
                            ),
                          ] else ...[
                            BrikolikButton(
                              label: 'Marquer refuse',
                              outlined: true,
                              foregroundColor: BrikolikColors.error,
                              onPressed:
                                  _isProcessing ? null : () => _reject(userId),
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
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrikolikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(BrikolikRadius.full),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BrikolikColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

