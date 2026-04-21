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
    return FutureBuilder<AdminOverviewData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: BrikolikColors.primary),
          );
        }

        final data = snapshot.data ??
            const AdminOverviewData(
              totalClients: 0,
              totalWorkers: 0,
              pendingRequests: 0,
              inProgressJobs: 0,
              completedJobs: 0,
              pendingVerifications: 0,
              dayRevenue: 0,
              monthRevenue: 0,
              totalMissionRevenue: 0,
              activeMissionValue: 0,
              averageMissionRevenue: 0,
              verificationRate: 0,
              missionCompletionRate: 0,
              recentSignups: <Map<String, dynamic>>[],
              recentRequests: <Map<String, dynamic>>[],
              recentMissions: <Map<String, dynamic>>[],
              recentComplaints: <Map<String, dynamic>>[],
              recentActivities: <Map<String, dynamic>>[],
              requestsWithoutOffers: <Map<String, dynamic>>[],
              missionsTrend: <double>[],
              revenueTrend: <double>[],
            );

        return RefreshIndicator(
          color: BrikolikColors.primary,
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final compact = width < 900;
              final kpiColumns = width >= 1400
                  ? 4
                  : width >= 1100
                      ? 3
                      : width >= 700
                          ? 2
                          : 1;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 28),
                children: [
                  _buildHero(data),
                  const SizedBox(height: 16),
                  AdminPageHeader(
                    title: 'Tableau de bord',
                    subtitle:
                        'Vue rapide de la plateforme, missions, revenus et activite recente.',
                    trailing: TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: kpiColumns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: compact ? 2.6 : 2.2,
                    children: [
                      AdminKpiCard(
                        label: 'Clients',
                        value: '${data.totalClients}',
                        icon: Icons.people_outline_rounded,
                        iconBg: BrikolikColors.secondaryLight,
                        hint: 'Comptes clients actifs',
                      ),
                      AdminKpiCard(
                        label: 'Artisans',
                        value: '${data.totalWorkers}',
                        icon: Icons.handyman_outlined,
                        iconBg: BrikolikColors.primaryLight,
                        hint: 'Professionnels inscrits',
                      ),
                      AdminKpiCard(
                        label: 'Missions en cours',
                        value: '${data.inProgressJobs}',
                        icon: Icons.work_history_outlined,
                        iconBg: BrikolikColors.warningLight,
                        hint: 'Jobs acceptes actuellement',
                      ),
                      AdminKpiCard(
                        label: 'Demandes en attente',
                        value: '${data.pendingRequests}',
                        icon: Icons.pending_actions_outlined,
                        iconBg: BrikolikColors.accentLight,
                        hint: 'Demandes encore ouvertes',
                      ),
                      AdminKpiCard(
                        label: 'CA du jour',
                        value: '${data.dayRevenue.toStringAsFixed(0)} MAD',
                        icon: Icons.today_outlined,
                        iconBg: BrikolikColors.successLight,
                        hint: 'Base sur les offres acceptees',
                      ),
                      AdminKpiCard(
                        label: 'CA du mois',
                        value: '${data.monthRevenue.toStringAsFixed(0)} MAD',
                        icon: Icons.calendar_month_outlined,
                        iconBg: BrikolikColors.secondaryLight,
                        hint: 'Estimation mensuelle',
                      ),
                      AdminKpiCard(
                        label: 'Taux verification',
                        value: '${data.verificationRate.toStringAsFixed(0)}%',
                        icon: Icons.verified_user_outlined,
                        iconBg: BrikolikColors.primaryLight,
                        hint: '${data.pendingVerifications} en attente',
                      ),
                      AdminKpiCard(
                        label: 'Missions terminees',
                        value: '${data.completedJobs}',
                        icon: Icons.task_alt_outlined,
                        iconBg: BrikolikColors.surfaceVariant,
                        hint: 'Historique cloture',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _buildRevenueCard(data),
                    const SizedBox(height: 12),
                    _buildMissionHealthCard(data),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildRevenueCard(data)),
                        const SizedBox(width: 12),
                        Expanded(flex: 5, child: _buildMissionHealthCard(data)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _buildTrendCard(data),
                    const SizedBox(height: 12),
                    _buildActivityCard(data),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildTrendCard(data)),
                        const SizedBox(width: 12),
                        Expanded(flex: 5, child: _buildActivityCard(data)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _buildRecentMissions(data),
                    const SizedBox(height: 12),
                    _buildRecentRequests(data),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildRecentMissions(data)),
                        const SizedBox(width: 12),
                        Expanded(flex: 5, child: _buildRecentRequests(data)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _buildAlerts(data),
                    const SizedBox(height: 12),
                    _buildRecentSignups(data),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildAlerts(data)),
                        const SizedBox(width: 12),
                        Expanded(flex: 5, child: _buildRecentSignups(data)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _buildRecentComplaints(data),
                    const SizedBox(height: 12),
                    _buildActivitySnapshot(data),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildRecentComplaints(data)),
                        const SizedBox(width: 12),
                        Expanded(flex: 4, child: _buildActivitySnapshot(data)),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHero(AdminOverviewData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF233B73),
            Color(0xFF4C67A8),
            Color(0xFF1B8D76),
          ],
        ),
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final summary = compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _heroChildren(data),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _heroChildren(data),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: _heroHealth(data),
                    ),
                  ],
                );

          return summary;
        },
      ),
    );
  }

  List<Widget> _heroChildren(AdminOverviewData data) {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(BrikolikRadius.full),
        ),
        child: const Text(
          'Vue d ensemble Brikolik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Pilotez les clients, artisans et missions depuis un seul espace.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        '${data.pendingRequests} demandes ouvertes, ${data.inProgressJobs} missions en cours et ${data.pendingVerifications} verifications a traiter.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.90),
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _heroMiniStat('Clients', '${data.totalClients}'),
          _heroMiniStat('Artisans', '${data.totalWorkers}'),
          _heroMiniStat(
              'CA mois', '${data.monthRevenue.toStringAsFixed(0)} MAD'),
          _heroMiniStat(
              'Revenus missions', '${data.totalMissionRevenue.toStringAsFixed(0)} MAD'),
        ],
      ),
    ];
  }

  Widget _heroHealth(AdminOverviewData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sante de la plateforme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _healthRow(
            'Verification artisans',
            '${data.verificationRate.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 10),
          _healthRow(
            'Demandes sans offre',
            '${data.requestsWithoutOffers.length}',
          ),
          const SizedBox(height: 10),
          _healthRow(
            'Reclamations recentes',
            '${data.recentComplaints.length}',
          ),
        ],
      ),
    );
  }

  Widget _healthRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _heroMiniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Revenus des missions',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 6),
          const Text(
            'Suivi des montants des offres acceptees sur les 7 derniers jours.',
            style: TextStyle(
              color: BrikolikColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          AdminMiniLineChart(
            values: data.revenueTrend,
            color: BrikolikColors.success,
            height: 150,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricChip('Aujourd hui', _money(data.dayRevenue)),
              _metricChip('Ce mois', _money(data.monthRevenue)),
              _metricChip('Cumule missions', _money(data.totalMissionRevenue)),
              _metricChip('Panier moyen', _money(data.averageMissionRevenue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHealthCard(AdminOverviewData data) {
    final totalMissions = data.inProgressJobs + data.completedJobs;
    final progress = totalMissions == 0
        ? 0.0
        : (data.completedJobs / totalMissions).clamp(0.0, 1.0).toDouble();

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Suivi des missions',
            icon: Icons.assignment_turned_in_outlined,
          ),
          const SizedBox(height: 12),
          _healthStat(
            'Valeur des missions actives',
            _money(data.activeMissionValue),
          ),
          const SizedBox(height: 10),
          _healthStat(
            'Taux d achevement',
            '${data.missionCompletionRate.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: BrikolikColors.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(BrikolikColors.success),
            borderRadius: BorderRadius.circular(BrikolikRadius.full),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AdminPill(
                label: '${data.inProgressJobs} en cours',
                color: BrikolikColors.warning,
                bgColor: BrikolikColors.warningLight,
              ),
              AdminPill(
                label: '${data.completedJobs} terminees',
                color: BrikolikColors.success,
                bgColor: BrikolikColors.successLight,
              ),
              AdminPill(
                label: '$totalMissions missions suivies',
                color: BrikolikColors.primaryDark,
                bgColor: BrikolikColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Evolution des missions (7 jours)',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 6),
          const Text(
            'Visualisation simple des demandes creees chaque jour.',
            style: TextStyle(
              color: BrikolikColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          AdminMiniLineChart(
            values: data.missionsTrend,
            color: BrikolikColors.primary,
            height: 160,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMissions(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Missions recentes',
            icon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 12),
          if (data.recentMissions.isEmpty)
            const _EmptyInline(label: 'Aucune mission acceptee pour le moment.')
          else
            Column(
              children: data.recentMissions.map((job) {
                final title = (job['title'] as String?)?.trim();
                final worker = (job['acceptedWorkerName'] as String?)?.trim();
                final status = (job['status'] as String?)?.trim() ?? 'inprogress';
                final amount = _money(_toDouble(job['acceptedPrice']));
                final at = job['activityAt'] as Timestamp?;
                return _MiniRow(
                  title: title?.isNotEmpty == true ? title! : 'Mission',
                  subtitle:
                      '${worker?.isNotEmpty == true ? worker : 'Artisan'} | $amount',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statusPill(status),
                      const SizedBox(height: 6),
                      Text(
                        _fmt(at),
                        style: const TextStyle(
                          color: BrikolikColors.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Dernieres activites',
            icon: Icons.bolt_outlined,
          ),
          const SizedBox(height: 12),
          if (data.recentActivities.isEmpty)
            const _EmptyInline(
              label: 'Aucune activite recente a afficher pour le moment.',
            )
          else
            Column(
              children: data.recentActivities.map((item) {
                final title = (item['title'] as String?)?.trim() ?? 'Activite';
                final subtitle = (item['subtitle'] as String?)?.trim() ?? '-';
                final badge = (item['badge'] as String?)?.trim() ?? '';
                final createdAt = item['createdAt'] as Timestamp?;
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
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: BrikolikColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(BrikolikRadius.md),
                          ),
                          child: Icon(
                            _activityIcon(item['type'] as String?),
                            color: BrikolikColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: BrikolikColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: BrikolikColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (badge.isNotEmpty) _activityBadge(badge),
                            const SizedBox(height: 6),
                            Text(
                              _fmt(createdAt),
                              style: const TextStyle(
                                color: BrikolikColors.textHint,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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

  Widget _buildRecentRequests(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Demandes recentes',
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 12),
          if (data.recentRequests.isEmpty)
            const _EmptyInline(label: 'Aucune demande recente.')
          else
            Column(
              children: data.recentRequests.map((job) {
                final id = (job['id'] as String?) ?? '';
                final title = (job['title'] as String?)?.trim();
                final city = (job['city'] as String?)?.trim();
                final offers = (job['offersCount'] as num?)?.toInt() ?? 0;
                final status = (job['status'] as String?)?.trim() ?? 'open';
                final createdAt = job['createdAt'] as Timestamp?;

                return InkWell(
                  onTap: () {
                    if (id.isEmpty) return;
                    Navigator.pushNamed(
                      context,
                      '/job-details',
                      arguments: id,
                    );
                  },
                  child: _MiniRow(
                    title: title?.isNotEmpty == true ? title! : 'Demande',
                    subtitle:
                        '${city?.isNotEmpty == true ? city : '-'} | $offers offre${offers > 1 ? 's' : ''}',
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
                            fontWeight: FontWeight.w700,
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

  Widget _buildAlerts(AdminOverviewData data) {
    final alerts = data.requestsWithoutOffers;
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  'Alertes prioritaires',
                  icon: Icons.warning_amber_outlined,
                ),
              ),
              AdminPill(
                label: '${alerts.length} sans offre',
                color: alerts.isEmpty
                    ? BrikolikColors.textSecondary
                    : BrikolikColors.warning,
                bgColor: alerts.isEmpty
                    ? BrikolikColors.surfaceVariant
                    : BrikolikColors.warningLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            const _EmptyInline(
              label:
                  'Aucune demande ouverte sans offre. La plateforme est saine.',
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
                        const Icon(
                          Icons.schedule_outlined,
                          color: BrikolikColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title?.isNotEmpty == true
                                    ? title!
                                    : 'Demande sans titre',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: BrikolikColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${city?.isNotEmpty == true ? city : '-'} | ${_fmt(createdAt)}',
                                style: const TextStyle(
                                  color: BrikolikColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  Widget _buildRecentSignups(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Dernieres inscriptions',
            icon: Icons.person_add_alt_1_outlined,
          ),
          const SizedBox(height: 12),
          if (data.recentSignups.isEmpty)
            const _EmptyInline(label: 'Aucune inscription recente.')
          else
            Column(
              children: data.recentSignups.map((user) {
                final name = (user['fullName'] as String?)?.trim();
                final email = (user['email'] as String?)?.trim();
                final role = (user['role'] as String?)?.trim() ?? 'non defini';
                final createdAt = user['createdAt'] as Timestamp?;
                return _MiniRow(
                  title: name?.isNotEmpty == true ? name! : 'Utilisateur',
                  subtitle:
                      '${email?.isNotEmpty == true ? email : '-'} | $role',
                  trailing: Text(
                    _fmt(createdAt),
                    style: const TextStyle(
                      color: BrikolikColors.textHint,
                      fontWeight: FontWeight.w700,
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
          _sectionTitle(
            'Reclamations recentes',
            icon: Icons.report_gmailerrorred_outlined,
          ),
          const SizedBox(height: 12),
          if (data.recentComplaints.isEmpty)
            const _EmptyInline(
              label: 'Aucune reclamation recente ou collection absente.',
            )
          else
            Column(
              children: data.recentComplaints.map((complaint) {
                final title = (complaint['title'] as String?)?.trim();
                final status =
                    (complaint['status'] as String?)?.trim() ?? 'open';
                final createdAt = complaint['createdAt'] as Timestamp?;
                return _MiniRow(
                  title: title?.isNotEmpty == true ? title! : 'Reclamation',
                  subtitle: 'Statut: $status',
                  trailing: Text(
                    _fmt(createdAt),
                    style: const TextStyle(
                      color: BrikolikColors.textHint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySnapshot(AdminOverviewData data) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Resume mission & revenu',
            icon: Icons.insights_outlined,
          ),
          const SizedBox(height: 14),
          _snapshotRow(
            label: 'Mission moyenne',
            value: _money(data.averageMissionRevenue),
          ),
          const SizedBox(height: 10),
          _snapshotRow(
            label: 'Revenu du jour',
            value: _money(data.dayRevenue),
          ),
          const SizedBox(height: 10),
          _snapshotRow(
            label: 'Revenu du mois',
            value: _money(data.monthRevenue),
          ),
          const SizedBox(height: 10),
          _snapshotRow(
            label: 'Demandes sans offre',
            value: '${data.requestsWithoutOffers.length}',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: BrikolikColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: BrikolikColors.textPrimary,
            ),
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

  Widget _activityBadge(String label) {
    final lower = label.toLowerCase();
    if (lower == 'accepted' || lower == 'approved' || lower == 'done') {
      return const AdminPill(
        label: 'OK',
        color: BrikolikColors.success,
        bgColor: BrikolikColors.successLight,
      );
    }
    if (lower == 'pending' || lower == 'open' || lower == 'inprogress') {
      return const AdminPill(
        label: 'Suivi',
        color: BrikolikColors.warning,
        bgColor: BrikolikColors.warningLight,
      );
    }
    return AdminPill(
      label: label,
      color: BrikolikColors.primaryDark,
      bgColor: BrikolikColors.primaryLight,
    );
  }

  IconData _activityIcon(String? type) {
    switch (type) {
      case 'signup':
        return Icons.person_add_alt_1_rounded;
      case 'offer':
        return Icons.local_offer_outlined;
      case 'complaint':
        return Icons.report_outlined;
      case 'request':
      default:
        return Icons.assignment_outlined;
    }
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

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BrikolikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrikolikColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: BrikolikColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthStat(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BrikolikColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: BrikolikColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _snapshotRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BrikolikColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: BrikolikColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  String _money(double amount) => '${amount.toStringAsFixed(0)} MAD';

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final text = (value ?? '').toString().trim().replaceAll(',', '.');
    if (text.isEmpty) return 0;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
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
                      color: BrikolikColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BrikolikColors.textSecondary,
                      fontWeight: FontWeight.w700,
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
