import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/widgets.dart';
import 'admin_sections.dart';
import 'widgets/admin_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingAccess = true;
  bool _isAdmin = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccess() async {
    final isAdmin = await _authService.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _isLoadingAccess = false;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void _select(int next) {
    setState(() => _index = next);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
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
            title: 'Acces refuse',
            subtitle: 'Cette page est reservee aux administrateurs Brikolik.',
            actionLabel: 'Retour',
            onAction: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (_) => false,
            ),
          ),
        ),
      );
    }

    final sections = adminSections();
    final selected = sections[_index];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final isTablet = width >= 720 && width < 1024;
        final sidebarWidth = isTablet ? 92.0 : 280.0;

        final sidebar = AdminSidebar(
          sections: sections,
          selectedIndex: _index,
          condensed: isTablet,
          onSelect: _select,
          onLogout: _logout,
        );

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: BrikolikColors.background,
          drawer: isDesktop ? null : Drawer(child: sidebar),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop || isTablet)
                  SizedBox(
                    width: sidebarWidth,
                    child: sidebar,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      AdminTopBar(
                        title: selected.label,
                        searchController: _searchCtrl,
                        onMenu: isDesktop || isTablet
                            ? null
                            : () => _scaffoldKey.currentState?.openDrawer(),
                        onLogout: _logout,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(BrikolikRadius.lg),
                            child: Container(
                              color: BrikolikColors.background,
                              child: IndexedStack(
                                index: _index,
                                children:
                                    sections.map((s) => s.page).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

