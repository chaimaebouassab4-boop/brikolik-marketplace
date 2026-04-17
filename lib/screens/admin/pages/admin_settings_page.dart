import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/admin_components.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdminPageHeader(
          title: 'Parametres',
          subtitle: 'Configuration admin (whitelist emails, etc.).',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emails administrateurs',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontFamilyFallback: ['Cairo'],
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ces emails (collection 'admin_emails') obtiennent le role admin a la connexion.",
                      style: TextStyle(
                        color: BrikolikColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Ajouter un email admin (ex: admin@x.com)',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _addAdminEmail,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(140, 52),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('admin_emails')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Erreur: ${snapshot.error}',
                            style: const TextStyle(color: BrikolikColors.error),
                          );
                        }

                        final docs = snapshot.data?.docs ?? const [];
                        if (docs.isEmpty) {
                          return const Text(
                            'Aucun email admin configure.',
                            style: TextStyle(color: BrikolikColors.textSecondary),
                          );
                        }

                        final emails = docs
                            .map((d) => d.id.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                          ..sort();

                        return Column(
                          children: emails.map((email) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: BrikolikColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(
                                      BrikolikRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined,
                                        color: BrikolikColors.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: BrikolikColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Supprimer',
                                      onPressed: _isSaving
                                          ? null
                                          : () => _deleteAdminEmail(email),
                                      icon: const Icon(Icons.delete_outline,
                                          color: BrikolikColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'A venir',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontFamilyFallback: ['Cairo'],
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Parametres SLA (delais verifications / reclamations)\n- Regles anti-fraude\n- Export CSV',
                      style: TextStyle(
                        color: BrikolikColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addAdminEmail() async {
    final normalized = _emailCtrl.text.trim().toLowerCase();
    if (!normalized.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email invalide.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('admin_emails')
          .doc(normalized)
          .set({
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      _emailCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email admin ajoute.'),
          backgroundColor: BrikolikColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAdminEmail(String email) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer email admin ?'),
        content: Text(email),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('admin_emails').doc(email).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email admin supprime.'),
          backgroundColor: BrikolikColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

