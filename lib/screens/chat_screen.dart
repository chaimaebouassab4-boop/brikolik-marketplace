import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<_ContactData> _contactFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map<String, dynamic>
        ? rawArgs
        : <String, dynamic>{};

    _contactFuture = _resolveContact(args);
    _initialized = true;
  }

  Future<_ContactData> _resolveContact(Map<String, dynamic> args) async {
    String name = (args['contactName'] as String? ?? '').trim();
    String phone = (args['contactPhone'] as String? ?? '').trim();
    String city = (args['contactCity'] as String? ?? '').trim();
    String role = (args['contactRole'] as String? ?? '').trim();
    final userId = (args['contactUserId'] as String? ?? '').trim();

    if (userId.isNotEmpty &&
        (name.isEmpty || phone.isEmpty || city.isEmpty || role.isEmpty)) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final data = doc.data();
        if (data != null) {
          name = name.isEmpty ? (data['fullName'] as String? ?? '').trim() : name;
          phone = phone.isEmpty ? (data['phone'] as String? ?? '').trim() : phone;
          city = city.isEmpty ? (data['city'] as String? ?? '').trim() : city;
          role = role.isEmpty ? (data['role'] as String? ?? '').trim() : role;
        }
      } catch (_) {
        // Keep fallback values when user profile cannot be fetched.
      }
    }

    return _ContactData(
      name: name.isEmpty ? 'Contact' : name,
      phone: phone,
      city: city,
      role: role.isEmpty ? 'contact' : role,
    );
  }

  Future<void> _openWhatsApp(_ContactData contact) async {
    final normalized = _normalizeForWhatsapp(contact.phone);
    if (normalized == null) {
      _showError('Numero WhatsApp indisponible.'.tr());
      return;
    }

    final greeting = Uri.encodeComponent(
      'Bonjour ${contact.name}, je vous contacte depuis Brikolik.',
    );
    final uri = Uri.parse('https://wa.me/$normalized?text=$greeting');
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched && mounted) {
      _showError('Impossible d ouvrir WhatsApp.'.tr());
    }
  }

  Future<void> _openCall(_ContactData contact) async {
    final normalized = _normalizeForDial(contact.phone);
    if (normalized == null) {
      _showError('Numero de telephone indisponible.'.tr());
      return;
    }

    final uri = Uri.parse('tel:$normalized');
    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched && mounted) {
      _showError('Impossible de lancer l appel.'.tr());
    }
  }

  String? _normalizeForWhatsapp(String rawPhone) {
    final phone = rawPhone.trim();
    if (phone.isEmpty) return null;

    final compact = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (compact.isEmpty) return null;

    if (compact.startsWith('+')) {
      return compact.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
    }
    if (compact.startsWith('00')) {
      return compact.substring(2).replaceAll(RegExp(r'[^0-9]'), '');
    }
    if (compact.startsWith('0')) {
      return '212${compact.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }
    return compact.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String? _normalizeForDial(String rawPhone) {
    final phone = rawPhone.trim();
    if (phone.isEmpty) return null;

    final compact = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (compact.isEmpty) return null;

    if (compact.startsWith('+')) return compact;
    if (compact.startsWith('00')) return '+${compact.substring(2)}';
    if (compact.startsWith('0')) return '+212${compact.substring(1)}';
    return compact;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BrikolikColors.error,
      ),
    );
  }

  String _roleLabel(String role) {
    if (role == 'worker') return 'Artisan';
    if (role == 'customer') return 'Client';
    return 'Contact';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: BrikolikColors.background,
        appBar: AppBar(
          backgroundColor: BrikolikColors.surface,
          foregroundColor: BrikolikColors.textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: BrikolikColors.border, height: 1),
          ),
          leadingWidth: 48,
          title: Text(
            'Messages'.tr(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['Cairo'],
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: BrikolikColors.textPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.lock_person_outlined,
            title: 'Connexion requise',
            subtitle:
                'Creez un compte ou connectez-vous pour acceder aux messages.',
            actionLabel: 'Se connecter',
            onAction: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (_) => false,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      appBar: AppBar(
        backgroundColor: BrikolikColors.surface,
        foregroundColor: BrikolikColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: BrikolikColors.border, height: 1),
        ),
        leadingWidth: 48,
        title: Text(
          'Contact rapide'.tr(),
          style: const TextStyle(
            fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: BrikolikColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/rating'),
            child: Text(
              'Terminer'.tr(),
              style: const TextStyle(
                fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                color: BrikolikColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<_ContactData>(
        future: _contactFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrikolikColors.primary),
            );
          }

          final contact = snapshot.data ??
              const _ContactData(
                name: 'Contact',
                phone: '',
                city: '',
                role: 'contact',
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    borderRadius: BorderRadius.circular(BrikolikRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: BrikolikColors.primary.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          contact.initials,
                          style: const TextStyle(
                            fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_roleLabel(contact.role)} • ${contact.city.isEmpty ? 'Maroc' : contact.city}',
                              style: TextStyle(
                                fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: BrikolikColors.surface,
                    borderRadius: BorderRadius.circular(BrikolikRadius.md),
                    border: Border.all(color: BrikolikColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          color: BrikolikColors.textSecondary, size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contact.phone.isEmpty
                              ? 'Numero non disponible'.tr()
                              : contact.phone,
                          style: TextStyle(
                            fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: contact.phone.isEmpty
                                ? BrikolikColors.textHint
                                : BrikolikColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'WhatsApp',
                  subtitle: 'Contact instantane en un clic'.tr(),
                  icon: Icons.chat_bubble_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  ),
                  onTap: () => _openWhatsApp(contact),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Appeler'.tr(),
                  subtitle: 'Lancer un appel immediat'.tr(),
                  icon: Icons.call_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  ),
                  onTap: () => _openCall(contact),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Nunito', fontFamilyFallback: ['Cairo'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactData {
  const _ContactData({
    required this.name,
    required this.phone,
    required this.city,
    required this.role,
  });

  final String name;
  final String phone;
  final String city;
  final String role;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'C';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }
}
