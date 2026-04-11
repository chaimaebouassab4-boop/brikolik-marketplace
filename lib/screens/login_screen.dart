import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: 'CHAIMAE2026@');
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
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _routeAfterAuth() async {
    final profile = await _authService.getCurrentUserProfile();
    if (!mounted) return;

    final role = profile?['role'] as String?;
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-verifications');
      return;
    }

    if (profile?['isVerified'] != true) {
      Navigator.pushReplacementNamed(context, '/identity-verification');
      return;
    }

    if (role == 'customer') {
      Navigator.pushReplacementNamed(context, '/customer-profile');
    } else if (role == 'worker') {
      Navigator.pushReplacementNamed(context, '/worker-profile');
    } else {
      Navigator.pushReplacementNamed(context, '/role');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.tr())),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      await _routeAfterAuth();
    } on AuthServiceException catch (e) {
      _showSnack(e.message);
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyAuthMessage(e));
    } catch (_) {
      _showSnack('Connexion Google impossible. Reessayez.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrikolikColors.background,
      extendBodyBehindAppBar: true,
      appBar: const BrikolikAppBar(
        title: '',
        transparent: true,
      ),
      body: Stack(
        children: [
          // Decorative top gradient banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF465892), Color(0xFF6D5593)],
                ),
              ),
            ),
          ),
          // White curved panel
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: BrikolikColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHero(),
                  const SizedBox(height: 32),
                  _buildCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(BrikolikRadius.md),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 1),
              ),
              child: const Icon(Icons.build_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'BRIKOLIK',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          (_isLogin ? 'Bon retour' : 'Creer un compte').tr(),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin
              ? 'Connectez-vous pour acceder aux services'.tr()
              : 'Rejoignez la plateforme Brikolik'.tr(),
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.xl),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 24),
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
                    hint: 'email@exemple.com',
                    label: 'Email',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Champ requis';
                      if (!v.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  BrikolikInput(
                    hint: '********',
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
                        color: BrikolikColors.muted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimum 6 caracteres'
                        : null,
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
                        child: Text('Mot de passe oublie ?'.tr(),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: BrikolikColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Gradient CTA button
                  _GradientButton(
                    label: _isLogin ? 'Se connecter'.tr() : 'Creer mon compte'.tr(),
                    isLoading: _isLoading,
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      setState(() => _isLoading = true);

                      try {
                        if (_isLogin) {
                          await _authService.signIn(
                            email: _emailCtrl.text,
                            password: _passwordCtrl.text,
                          );
                          debugPrint("LOGIN SUCCESS");
                          await _routeAfterAuth();
                        } else {
                          await _authService.signUp(
                            email: _emailCtrl.text,
                            password: _passwordCtrl.text,
                            fullName: _nameCtrl.text,
                          );
                          debugPrint("SIGNUP SUCCESS");
                          await _routeAfterAuth();
                        }
                      } on FirebaseAuthException catch (e) {
                        final action = _isLogin ? 'LOGIN' : 'SIGNUP';
                        final details = '${e.code} | ${e.message}';
                        final friendlyMessage = _friendlyAuthMessage(e);
                        debugPrint("ERROR $action: $details");
                        _showSnack(friendlyMessage);
                      } on AuthServiceException catch (e) {
                        final action = _isLogin ? 'LOGIN' : 'SIGNUP';
                        debugPrint("ERROR $action: ${e.code} | ${e.message}");
                        _showSnack(e.message);
                      } catch (e) {
                        final action = _isLogin ? 'LOGIN' : 'SIGNUP';
                        debugPrint("ERROR $action: $e");
                        _showSnack('Erreur $action: $e');
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const DividerWithLabel(label: 'ou continuer avec Google'),
                  const SizedBox(height: 20),
                  _buildSocialButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est deja utilise.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caracteres).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Identifiants invalides.';
      case 'too-many-requests':
        return 'Trop de tentatives. Reessayez plus tard.';
      default:
        return 'Operation impossible pour le moment. Reessayez.';
    }
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
          gradient: BrikolikColors.brandGradient,
          borderRadius: BorderRadius.circular(BrikolikRadius.sm + 2),
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
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
        tabs: [
          Tab(text: 'Connexion'.tr()),
          Tab(text: 'Inscription'.tr()),
        ],
      ),
    );
  }

  Widget _buildSocialButtons() {
    return _SocialButton(
      label: 'Google',
      icon: Icons.g_mobiledata_rounded,
      onTap: _handleGoogleSignIn,
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬ Gradient CTA Button Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: BrikolikColors.brandGradient,
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          boxShadow: [
            BoxShadow(
              color: BrikolikColors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label.tr(),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬ Social Button Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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
          color: BrikolikColors.surfaceVariant,
          borderRadius: BorderRadius.circular(BrikolikRadius.md),
          border: Border.all(color: BrikolikColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: BrikolikColors.primary),
            const SizedBox(width: 8),
            Text(
              label.tr(),
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

