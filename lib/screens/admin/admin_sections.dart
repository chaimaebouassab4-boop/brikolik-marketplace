import 'package:flutter/material.dart';

import 'pages/admin_analytics_page.dart';
import 'pages/admin_clients_page.dart';
import 'pages/admin_complaints_page.dart';
import 'pages/admin_jobs_page.dart';
import 'pages/admin_offers_page.dart';
import 'pages/admin_overview_page.dart';
import 'pages/admin_requests_page.dart';
import 'pages/admin_settings_page.dart';
import 'pages/admin_verifications_page.dart';
import 'pages/admin_workers_page.dart';

class AdminSection {
  const AdminSection({
    required this.id,
    required this.label,
    required this.icon,
    required this.group,
    required this.page,
  });

  final String id;
  final String label;
  final IconData icon;
  final String group;
  final Widget page;
}

List<AdminSection> adminSections() {
  return const <AdminSection>[
    AdminSection(
      id: 'overview',
      label: 'Apercu',
      icon: Icons.dashboard_outlined,
      group: 'Vue d ensemble',
      page: AdminOverviewPage(),
    ),
    AdminSection(
      id: 'clients',
      label: 'Clients',
      icon: Icons.people_outline,
      group: 'Utilisateurs',
      page: AdminClientsPage(),
    ),
    AdminSection(
      id: 'workers',
      label: 'Artisans',
      icon: Icons.handyman_outlined,
      group: 'Utilisateurs',
      page: AdminWorkersPage(),
    ),
    AdminSection(
      id: 'requests',
      label: 'Demandes',
      icon: Icons.assignment_outlined,
      group: 'Operations',
      page: AdminRequestsPage(),
    ),
    AdminSection(
      id: 'offers',
      label: 'Offres',
      icon: Icons.local_offer_outlined,
      group: 'Operations',
      page: AdminOffersPage(),
    ),
    AdminSection(
      id: 'jobs',
      label: 'Missions',
      icon: Icons.work_outline,
      group: 'Operations',
      page: AdminJobsPage(),
    ),
    AdminSection(
      id: 'verifications',
      label: 'Verifications',
      icon: Icons.verified_user_outlined,
      group: 'Confiance & Securite',
      page: AdminVerificationsPage(),
    ),
    AdminSection(
      id: 'complaints',
      label: 'Reclamations',
      icon: Icons.report_outlined,
      group: 'Confiance & Securite',
      page: AdminComplaintsPage(),
    ),
    AdminSection(
      id: 'analytics',
      label: 'Analytics',
      icon: Icons.insights_outlined,
      group: 'Insights',
      page: AdminAnalyticsPage(),
    ),
    AdminSection(
      id: 'settings',
      label: 'Parametres',
      icon: Icons.settings_outlined,
      group: 'Systeme',
      page: AdminSettingsPage(),
    ),
  ];
}

