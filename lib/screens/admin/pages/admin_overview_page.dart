import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/widgets.dart';
import '../services/admin_firestore_service.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_components.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  final AdminFirestoreService _service = AdminFirestoreService();

  Future<AdminOverviewData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.loadOverview();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.loadOverview());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: BrikolikColors.primary,
      onRefresh: _refresh,
      child: FutureBuilder<AdminOverviewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrikolikColors.primary),
            );
          }
          if (snapshot.hasError) {
            return AdminCard(
              child: EmptyState(
                icon: Icons.warning_amber_outlined,
                title: 'Erreur de chargement',
                subtitle: '${snapshot.error}',
                actionLabel: 'Reessayer',
                onAction: () => _refresh(),
              ),
            );
          }

          final data = snapshot.data ??
              const AdminOverviewData(
                totalClients: 0,
                totalWorkers: 0,
                openRequests: 0,
                completedJobs: 0,
                pendingVerifications: 0,
                recentSignups: <Map<String, dynamic>>[],
                recentRequests: <Map<String, dynamic>>[],
                recentComplaints: <Map<String, dynamic>>[],
                requestsWithoutOffers: <Map<String, dynamic>>[],
              );

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w >= 1220
                  ? 5
                  : w >= 980
                      ? 4
                      : w >= 720
                          ? 3
                          : 2;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminPageHeader(
                      title: 'Tableau de bord',
                      subtitle:
                          'Suivi activite, verifications, demandes et alertes.',
                      trailing: TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.25,
                      children: [
                        AdminKpiCard(
                          label: 'Total clients',
                          value: '${data.totalClients}',
                          icon: Icons.people_outline,
                          iconBg: BrikolikColors.secondaryLight,
                        ),
                        AdminKpiCard(
                          label: 'Total artisans',
                          value: '${data.totalWorkers}',
                          icon: Icons.handyman_outlined,
                          iconBg: BrikolikColors.primaryLight,
                        ),
                        AdminKpiCard(
                          label: 'Demandes ouvertes',
                          value: '${data.openRequests}',
                          icon: Icons.assignment_outlined,
                          iconBg: BrikolikColors.warningLight,
                          hint: 'A traiter rapidement',
                        ),
                        AdminKpiCard(
                          label: 'Missions terminees',
                          value: '${data.completedJobs}',
                          icon: Icons.task_alt_outlined,
                          iconBg: BrikolikColors.successLight,
                        ),
                        AdminKpiCard(
                          label: 'Verifications en attente',
                          value: '${data.pendingVerifications}',
                          icon: Icons.verified_user_outlined,
                          iconBg: BrikolikColors.accentLight,
                          hint: data.pendingVerifications > 0
                              ? 'Action requise'
                              : 'Aucune en attente',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAlerts(data),
                    const SizedBox(height: 12),
                    _buildMainGrid(context, data, w),
                    const SizedBox(height: 12),
                    _buildTrends(),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAlerts(AdminOverviewData data) {
    final alerts = data.requestsWithoutOffers;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: BrikolikColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Alertes',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontFamilyFallback: ['Cairo'],
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: BrikolikColors.textPrimary,
                ),
              ),
              const Spacer(),
              AdminPill(
                label:
                    '${alerts.length} demande${alerts.length > 1 ? 's' : ''} sans offre',
                color: alerts.isEmpty
                    ? BrikolikColors.textSecondary
                    : BrikolikColors.warning,
                bgColor: alerts.isEmpty
                    ? BrikolikColors.surfaceVariant
                    : BrikolikColors.warningLight,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (alerts.isEmpty)
            const Text(
              'Aucune demande ouverte sans offre. Tout va bien.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontFamilyFallback: ['Cairo'],
                color: BrikolikColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Column(
              children: alerts.map((job) {
                final title = (job['title'] as String?)?.trim();
                final city = (job['city'] as String?)?.trim();
                final createdAt = job['createdAt'] as Timestamp?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BrikolikColors.warningLight,
                      borderRadius: BorderRadius.circular(BrikolikRadius.md),
                      border: Border.all(
                        color: BrikolikColors.warning.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: BrikolikColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (title == null || title.isEmpty)
                                    ? 'Demande sans titre'
                                    : title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontFamilyFallback: ['Cairo'],
                                  fontWeight: FontWeight.w900,
                                  color: BrikolikColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${city?.isNotEmpty == true ? city : '-'} • ${_fmt(createdAt)}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontFamilyFallback: ['Cairo'],
                                  fontWeight: FontWeight.w700,
                                  color: BrikolikColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            final id = (job['id'] as String?) ?? '';
                            if (id.isEmpty) return;
                            Navigator.pushNamed(
                              context,
                              '/job-details',
                              arguments: id,
                            );
                          },
                          child: const Text('Voir'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainGrid(
    BuildContext context,
    AdminOverviewData data,
    double width,
  ) {
    final isWide = width >= 980;
    if (!isWide) {
      return Column(
        children: [
          _buildRecentSignups(data),
          const SizedBox(height: 12),
          _buildRecentRequests(data),
          const SizedBox(height: 12),
          _buildRecentComplaints(data),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _buildRecentSignups(data)),
        const SizedBox(width: 12),
        Expanded(flex: 7, child: _buildRecentRequests(data)),
        const SizedBox(width: 12),
        Expanded(flex: 6, child: _buildRecentComplaints(data)),
      ],
    );
  }

  Widget _buildRecentSignups(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Inscriptions recentes',
              icon: Icons.person_add_outlined),
          const SizedBox(height: 10),
          if (data.recentSignups.isEmpty)
            const _EmptyInline(label: 'Aucune inscription recente.')
          else
            Column(
              children: data.recentSignups.map((u) {
                final name = (u['fullName'] as String?)?.trim();
                final email = (u['email'] as String?)?.trim();
                final role = (u['role'] as String?)?.trim();
                final createdAt = u['createdAt'] as Timestamp?;
                return _MiniRow(
                  title: name?.isNotEmpty == true ? name! : 'Utilisateur',
                  subtitle:
                      '${email?.isNotEmpty == true ? email : '-'} • ${role ?? 'role?'}',
                  trailing: Text(
                    _fmt(createdAt),
                    style: const TextStyle(color: BrikolikColors.textHint),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Demandes recentes', icon: Icons.assignment_outlined),
          const SizedBox(height: 10),
          if (data.recentRequests.isEmpty)
            const _EmptyInline(label: 'Aucune demande recente.')
          else
            Column(
              children: data.recentRequests.map((j) {
                final id = (j['id'] as String?) ?? '';
                final title = (j['title'] as String?)?.trim();
                final city = (j['city'] as String?)?.trim();
                final status = (j['status'] as String?)?.trim() ?? 'open';
                final offers = (j['offersCount'] as num?)?.toInt() ?? 0;
                final createdAt = j['createdAt'] as Timestamp?;
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/job-details',
                    arguments: id,
                  ),
                  child: _MiniRow(
                    title: title?.isNotEmpty == true ? title! : 'Demande',
                    subtitle:
                        '${city?.isNotEmpty == true ? city : '-'} • $offers offre${offers > 1 ? 's' : ''}',
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _statusPill(status),
                        const SizedBox(height: 6),
                        Text(
                          _fmt(createdAt),
                          style: const TextStyle(
                            color: BrikolikColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentComplaints(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Reclamations recentes', icon: Icons.report_outlined),
          const SizedBox(height: 10),
          if (data.recentComplaints.isEmpty)
            const _EmptyInline(
              label: "Aucune reclamation (collection 'complaints' vide).",
            )
          else
            Column(
              children: data.recentComplaints.map((c) {
                final title = (c['title'] as String?)?.trim();
                final status = (c['status'] as String?)?.trim() ?? 'open';
                final createdAt = c['createdAt'] as Timestamp?;
                return _MiniRow(
                  title: title?.isNotEmpty == true ? title! : 'Reclamation',
                  subtitle: 'Statut: $status',
                  trailing: Text(
                    _fmt(createdAt),
                    style: const TextStyle(color: BrikolikColors.textHint),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTrends() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];

        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 13));
        final buckets = List<int>.filled(14, 0);

        for (final d in docs) {
          final createdAt = d.data()['createdAt'];
          if (createdAt is! Timestamp) continue;
          final dt = createdAt.toDate();
          if (dt.isBefore(start)) continue;
          final diff = DateTime(dt.year, dt.month, dt.day).difference(start);
          final idx = diff.inDays;
          if (idx >= 0 && idx < buckets.length) buckets[idx]++;
        }

        final values = buckets.map((e) => e.toDouble()).toList();

        return AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Tendance demandes (14 jours)',
                  icon: Icons.show_chart_outlined),
              const SizedBox(height: 10),
              AdminMiniLineChart(values: values),
              const SizedBox(height: 8),
              const Text(
                'Chaque point = nombre de demandes creees par jour.',
                style: TextStyle(
                  color: BrikolikColors.textHint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String label, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: BrikolikColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontFamilyFallback: ['Cairo'],
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: BrikolikColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String status) {
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

  static String _fmt(Timestamp? ts) {
    if (ts == null) return '-';
    final d = ts.toDate();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm ${d.year} $hh:$mi';
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BrikolikColors.surfaceVariant,
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontFamilyFallback: ['Cairo'],
                      fontWeight: FontWeight.w900,
                      color: BrikolikColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontFamilyFallback: ['Cairo'],
                      fontWeight: FontWeight.w700,
                      color: BrikolikColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: BrikolikColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

