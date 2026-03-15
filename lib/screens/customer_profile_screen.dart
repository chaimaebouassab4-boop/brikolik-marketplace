import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  void _save() {
    Navigator.pushReplacementNamed(context, '/post-job');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil client')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complétez votre profil',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BrikolikColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ces informations sont visibles par les artisans.',
              style: TextStyle(color: BrikolikColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _label('Nom complet'),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'Ex: Ahmed El Alami'),
            ),
            const SizedBox(height: 16),
            _label('Téléphone'),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '06 XX XX XX XX'),
            ),
            const SizedBox(height: 16),
            _label('Ville'),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(hintText: 'Ex: Casablanca'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BrikolikColors.textPrimary),
      ),
    );
  }
}
