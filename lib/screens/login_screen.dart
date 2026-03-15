import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      setState(() => _isLogin = _tabCtrl.index == 0);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHero(),
              const SizedBox(height: 36),
              _buildTabs(),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      BrikolikInput(
                        hint: 'Votre nom complet',
                        label: 'Nom complet',
                        controller: _nameCtrl,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    BrikolikInput(
                      hint: '+212 6XX XXX XXX',
                      label: 'Numéro de téléphone',
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 14),
                    BrikolikInput(
                      hint: '••••••••',
                      label: 'Mot de passe',
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixWidget: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: BrikolikColors.textHint,
                        ),
                        onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                    ),
                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    BrikolikButton(
                      label: _isLogin ? 'Se connecter' : 'Créer mon compte',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    const DividerWithLabel(label: 'ou continuer avec'),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    const SizedBox(height: 32),
                    _buildSwitchModeRow(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: BrikolikColors.primary,
            borderRadius: BorderRadius.circular(BrikolikRadius.md),
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          _isLogin ? 'Bon retour 👋' : 'Créer un compte',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin
              ? 'Connectez-vous pour accéder aux services'
              : 'Rejoignez la plateforme Brikolik',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: BrikolikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(BrikolikRadius.md),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.sm + 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: BrikolikColors.primary,
        unselectedLabelColor: BrikolikColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Connexion'),
          Tab(text: 'Inscription'),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            icon: Icons.facebook_rounded,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchModeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Pas encore de compte ? " : "Déjà un compte ? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () {
            _tabCtrl.animateTo(_isLogin ? 1 : 0);
          },
          child: Text(
            _isLogin ? 'S\'inscrire' : 'Se connecter',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BrikolikRadius.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          border: Border.all(color: BrikolikColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: BrikolikColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BrikolikColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}