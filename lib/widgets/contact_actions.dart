import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class ContactActions extends StatelessWidget {
  const ContactActions({
    super.key,
    required this.phone,
    this.title = 'Contact direct',
    this.subtitle = 'Communiquez rapidement via WhatsApp ou appel direct.',
  });

  final String phone;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cleanPhone = phone.trim();
    final hasPhone = cleanPhone.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: BrikolikColors.successLight,
                  borderRadius: BorderRadius.circular(BrikolikRadius.sm),
                ),
                child: const Icon(
                  Icons.phone_in_talk_outlined,
                  size: 17,
                  color: BrikolikColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      hasPhone ? cleanPhone : subtitle.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: BrikolikColors.success,
                  backgroundColor: BrikolikColors.successLight,
                  onTap: hasPhone ? () => _openWhatsApp(context, cleanPhone) : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ContactButton(
                  label: 'Appel',
                  icon: Icons.call_rounded,
                  color: BrikolikColors.primary,
                  backgroundColor: BrikolikColors.primaryLight,
                  onTap: hasPhone ? () => _openCall(context, cleanPhone) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final normalized = _normalizeForWhatsapp(phone);
    if (normalized == null) {
      _showError(context, 'Numero WhatsApp indisponible.');
      return;
    }

    final greeting = Uri.encodeComponent(
      'Bonjour, je vous contacte via Brikolik.',
    );
    final uri = Uri.parse('https://wa.me/$normalized?text=$greeting');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError(context, 'Impossible d ouvrir WhatsApp.');
    }
  }

  static Future<void> _openCall(BuildContext context, String phone) async {
    final normalized = _normalizeForDial(phone);
    if (normalized == null) {
      _showError(context, 'Numero de telephone indisponible.');
      return;
    }

    final uri = Uri.parse('tel:$normalized');
    if (!await launchUrl(uri)) {
      _showError(context, 'Impossible de lancer l appel.');
    }
  }

  static String? _normalizeForWhatsapp(String rawPhone) {
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

  static String? _normalizeForDial(String rawPhone) {
    final phone = rawPhone.trim();
    if (phone.isEmpty) return null;
    final compact = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (compact.isEmpty) return null;
    if (compact.startsWith('+')) return compact;
    if (compact.startsWith('00')) return '+${compact.substring(2)}';
    if (compact.startsWith('0')) return '+212${compact.substring(1)}';
    return compact;
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.tr()),
        backgroundColor: BrikolikColors.error,
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? backgroundColor : BrikolikColors.surfaceVariant,
      borderRadius: BorderRadius.circular(BrikolikRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled ? color : BrikolikColors.textHint,
              ),
              const SizedBox(width: 8),
              Text(
                label.tr(),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontFamilyFallback: const ['Cairo'],
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: enabled ? color : BrikolikColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
