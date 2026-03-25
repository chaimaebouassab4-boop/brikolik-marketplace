import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _particleCtrl;
  late final ScrollController _scrollCtrl;

  // Section animations
  late final Animation<double> _navFade;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  // Scroll-triggered sections visibility
  final Map<String, bool> _sectionVisible = {
    'services': false,
    'howItWorks': false,
    'stats': false,
    'trust': false,
    'cta': false,
    'footer': false,
  };

  // GlobalKeys for sections
  final _servicesKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _statsKey = GlobalKey();
  final _trustKey = GlobalKey();
  final _ctaKey = GlobalKey();
  final _footerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _scrollCtrl = ScrollController()..addListener(_onScroll);

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Nav: instant
    _navFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    // Hero
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _float = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _masterCtrl.forward();
  }

  void _onScroll() {
    _checkVisibility('services', _servicesKey);
    _checkVisibility('howItWorks', _howItWorksKey);
    _checkVisibility('stats', _statsKey);
    _checkVisibility('trust', _trustKey);
    _checkVisibility('cta', _ctaKey);
    _checkVisibility('footer', _footerKey);
  }

  void _checkVisibility(String key, GlobalKey gk) {
    if (_sectionVisible[key] == true) return;
    final ctx = gk.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH * 0.85) {
      setState(() => _sectionVisible[key] = true);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _masterCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // ── 1. Hero Section ──────────────────────────
                _buildHeroSection(size, isWide),

                // ── 2. Services Grid ─────────────────────────
                _AnimatedSection(
                  key: _servicesKey,
                  visible: _sectionVisible['services'] ?? false,
                  child: _buildServicesSection(isWide),
                ),

                // ── 3. How It Works ──────────────────────────
                _AnimatedSection(
                  key: _howItWorksKey,
                  visible: _sectionVisible['howItWorks'] ?? false,
                  child: _buildHowItWorksSection(isWide),
                ),

                // ── 4. Stats Banner ──────────────────────────
                _AnimatedSection(
                  key: _statsKey,
                  visible: _sectionVisible['stats'] ?? false,
                  child: _buildStatsBanner(),
                ),

                // ── 5. Trust Section ─────────────────────────
                _AnimatedSection(
                  key: _trustKey,
                  visible: _sectionVisible['trust'] ?? false,
                  child: _buildTrustSection(isWide),
                ),

                // ── 6. Final CTA ─────────────────────────────
                _AnimatedSection(
                  key: _ctaKey,
                  visible: _sectionVisible['cta'] ?? false,
                  child: _buildFinalCTA(),
                ),

                // ── 7. Footer ────────────────────────────────
                _AnimatedSection(
                  key: _footerKey,
                  visible: _sectionVisible['footer'] ?? false,
                  child: _buildFooter(),
                ),
              ],
            ),
          ),

          // ── Sticky Nav Bar ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _navFade,
              child: _buildNavBar(isWide),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  1. NAV BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildNavBar(bool isWide) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: isWide ? 48 : 20,
        right: isWide ? 48 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2D3561).withOpacity(0.95),
            const Color(0xFF2D3561).withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          // Logo + Name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'lib/assets/lasgbrik-removebg-preview.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.build_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'BRIKOLIK',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Nav buttons
          _NavButton(
            label: 'Se connecter',
            outlined: true,
            onTap: () => Navigator.pushNamed(context, '/login'),
          ),
          const SizedBox(width: 10),
          _NavButton(
            label: "S'inscrire",
            outlined: false,
            onTap: () => Navigator.pushReplacementNamed(context, '/role'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  2. HERO SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeroSection(Size size, bool isWide) {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            bottom: 60,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D3561),
                Color(0xFF3B4A8A),
                Color(0xFF5A4A8A),
                Color(0xFF6D5593),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated particles/circles
              _buildParticles(size),

              // Content
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 64 : 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Floating logo
                    AnimatedBuilder(
                      animation: Listenable.merge([_pulse, _float]),
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(0, _float.value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                      .withOpacity(0.08 * _pulse.value),
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                      .withOpacity(0.05 * _pulse.value),
                                ),
                              ),
                              // Logo
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.2 * _pulse.value),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'lib/assets/lasgbrik-removebg-preview.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.build_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Tagline pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.9)),
                          const SizedBox(width: 6),
                          Text(
                            'Artisans vérifiés · Disponibles maintenant',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main headline
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: isWide ? 42 : 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                        children: [
                          const TextSpan(text: 'Trouvez un pro\nde '),
                          TextSpan(
                            text: 'confiance',
                            style: TextStyle(
                              color: const Color(0xFFB8A9D4),
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const TextSpan(text: '\nen secondes ⚡'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Des milliers d\'artisans qualifiés près\nde chez vous, disponibles maintenant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.75),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // CTA Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeroCTAButton(
                          label: 'Commencer',
                          icon: Icons.arrow_forward_rounded,
                          filled: true,
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/role'),
                        ),
                        const SizedBox(width: 12),
                        _HeroCTAButton(
                          label: 'Se connecter',
                          icon: Icons.login_rounded,
                          filled: false,
                          onTap: () =>
                              Navigator.pushNamed(context, '/login'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (context, _) {
        return CustomPaint(
          size: Size(size.width, 500),
          painter: _ParticlePainter(_particleCtrl.value),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  3. SERVICES SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildServicesSection(bool isWide) {
    final services = [
      _ServiceData(Icons.water_drop_outlined, 'Plomberie', 'Réparation & installation', const Color(0xFF3B8BD4)),
      _ServiceData(Icons.bolt_outlined, 'Électricité', 'Installation & dépannage', const Color(0xFFF5A623)),
      _ServiceData(Icons.cleaning_services_outlined, 'Nettoyage', 'Maison & bureaux', const Color(0xFF2D9B5A)),
      _ServiceData(Icons.format_paint_outlined, 'Peinture', 'Intérieur & extérieur', const Color(0xFFD85A30)),
      _ServiceData(Icons.grass_outlined, 'Jardinage', 'Entretien & aménagement', const Color(0xFF639922)),
      _ServiceData(Icons.carpenter_outlined, 'Menuiserie', 'Meubles & réparation', const Color(0xFF854F0B)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 24,
        vertical: 56,
      ),
      color: BrikolikColors.background,
      child: Column(
        children: [
          // Section header
          _SectionHeader(
            badge: 'NOS SERVICES',
            title: 'Que cherchez-vous ?',
            subtitle: 'Plus de 20 catégories de services à domicile',
          ),
          const SizedBox(height: 32),

          // Grid
          LayoutBuilder(builder: (ctx, constraints) {
            final cols = constraints.maxWidth > 500 ? 3 : 2;
            final spacing = 14.0;
            final itemW =
                (constraints.maxWidth - spacing * (cols - 1)) / cols;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: services.map((s) {
                return SizedBox(
                  width: itemW,
                  child: _ServiceCard(data: s),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  4. HOW IT WORKS
  // ═══════════════════════════════════════════════════════════
  Widget _buildHowItWorksSection(bool isWide) {
    final steps = [
      _StepData('1', Icons.edit_note_rounded, 'Décrivez',
          'Publiez votre besoin en quelques clics'),
      _StepData('2', Icons.compare_arrows_rounded, 'Comparez',
          'Recevez des offres d\'artisans qualifiés'),
      _StepData('3', Icons.handshake_rounded, 'Réservez',
          'Choisissez le pro idéal et réservez'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 24,
        vertical: 56,
      ),
      color: BrikolikColors.surfaceVariant,
      child: Column(
        children: [
          _SectionHeader(
            badge: 'COMMENT ÇA MARCHE',
            title: 'Simple comme 1, 2, 3',
            subtitle: 'Trouvez votre artisan en 3 étapes simples',
          ),
          const SizedBox(height: 36),

          LayoutBuilder(builder: (ctx, constraints) {
            if (constraints.maxWidth > 500) {
              // Horizontal layout
              return Row(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    Expanded(child: _StepCard(data: steps[i])),
                    if (i < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: BrikolikColors.primary.withOpacity(0.3),
                          size: 24,
                        ),
                      ),
                  ],
                ],
              );
            } else {
              // Vertical layout
              return Column(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    _StepCard(data: steps[i]),
                    if (i < steps.length - 1) ...[
                      const SizedBox(height: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: BrikolikColors.primary.withOpacity(0.3),
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  5. STATS BANNER
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF465892), Color(0xFF6D5593)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _StatItem(value: '2 000+', label: 'Artisans vérifiés',
              icon: Icons.engineering_rounded),
          _StatDivider(),
          _StatItem(value: '15 000+', label: 'Missions réussies',
              icon: Icons.check_circle_outline_rounded),
          _StatDivider(),
          _StatItem(value: '4.8 ★', label: 'Note moyenne',
              icon: Icons.star_outline_rounded),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  6. TRUST SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildTrustSection(bool isWide) {
    final items = [
      _TrustData(Icons.verified_user_outlined, 'Artisans vérifiés',
          'Chaque artisan est vérifié : identité, compétences et avis clients.',
          BrikolikColors.primary),
      _TrustData(Icons.shield_outlined, 'Paiement sécurisé',
          'Vos paiements sont protégés. Payez uniquement quand le travail est fait.',
          BrikolikColors.success),
      _TrustData(Icons.sentiment_satisfied_alt_outlined,
          'Satisfaction garantie',
          'Pas satisfait ? Nous intervenons pour trouver une solution.',
          BrikolikColors.accent),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 24,
        vertical: 56,
      ),
      color: BrikolikColors.background,
      child: Column(
        children: [
          _SectionHeader(
            badge: 'CONFIANCE',
            title: 'Pourquoi Brikolik ?',
            subtitle: 'La plateforme de confiance pour vos services à domicile',
          ),
          const SizedBox(height: 32),

          LayoutBuilder(builder: (ctx, constraints) {
            if (constraints.maxWidth > 500) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map((t) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: _TrustCard(data: t),
                          ),
                        ))
                    .toList(),
              );
            }
            return Column(
              children: items
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _TrustCard(data: t),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  7. FINAL CTA
  // ═══════════════════════════════════════════════════════════
  Widget _buildFinalCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3561), Color(0xFF5A4A8A)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🚀',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Prêt à commencer ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rejoignez la communauté Brikolik et\ntrouvez votre artisan idéal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroCTAButton(
                label: 'Créer un compte',
                icon: Icons.person_add_alt_1_rounded,
                filled: true,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/role'),
              ),
              const SizedBox(width: 12),
              _HeroCTAButton(
                label: 'Se connecter',
                icon: Icons.login_rounded,
                filled: false,
                onTap: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  8. FOOTER
  // ═══════════════════════════════════════════════════════════
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: const Color(0xFF1E2340),
      child: Column(
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'lib/assets/lasgbrik-removebg-preview.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.build_rounded,
                        color: Colors.white54,
                        size: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'BRIKOLIK',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Links
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: 'À propos'),
              _FooterLink(label: 'Services'),
              _FooterLink(label: 'Contact'),
              _FooterLink(label: 'CGU'),
              _FooterLink(label: 'Confidentialité'),
            ],
          ),
          const SizedBox(height: 20),

          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(icon: Icons.facebook_rounded),
              const SizedBox(width: 16),
              _SocialIcon(icon: Icons.camera_alt_outlined), // Instagram
              const SizedBox(width: 16),
              _SocialIcon(icon: Icons.public_rounded), // Website
            ],
          ),
          const SizedBox(height: 20),

          Divider(
            color: Colors.white.withOpacity(0.08),
            height: 1,
          ),
          const SizedBox(height: 16),

          Text(
            '© 2026 Brikolik · Services à domicile au Maroc 🇲🇦',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

// ── Animated Section (scroll-triggered fade-in) ──────────────
class _AnimatedSection extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedSection({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: BrikolikColors.primaryLight,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: BrikolikColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: BrikolikColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: BrikolikColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Nav Button ───────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: outlined ? Colors.white : BrikolikColors.primary,
          ),
        ),
      ),
    );
  }
}

// ── Hero CTA Button ──────────────────────────────────────────
class _HeroCTAButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeroCTAButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: filled
                    ? BrikolikColors.primary
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon,
                size: 18,
                color: filled
                    ? BrikolikColors.primary
                    : Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Service Data ─────────────────────────────────────────────
class _ServiceData {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  const _ServiceData(this.icon, this.label, this.desc, this.color);
}

// ── Service Card ─────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final _ServiceData data;
  const _ServiceCard({required this.data});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BrikolikColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? widget.data.color.withOpacity(0.4) : BrikolikColors.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.data.color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translate(0, -3, 0))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.data.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.data.icon,
                  size: 22, color: widget.data.color),
            ),
            const SizedBox(height: 12),
            Text(
              widget.data.label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BrikolikColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.desc,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: BrikolikColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step Data ────────────────────────────────────────────────
class _StepData {
  final String number;
  final IconData icon;
  final String title;
  final String desc;
  const _StepData(this.number, this.icon, this.title, this.desc);
}

// ── Step Card ────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final _StepData data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number circle
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: BrikolikColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.number,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Icon(data.icon, size: 28, color: BrikolikColors.primary),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BrikolikColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Item ────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.white.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.15),
    );
  }
}

// ── Trust Data ───────────────────────────────────────────────
class _TrustData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _TrustData(this.icon, this.title, this.desc, this.color);
}

// ── Trust Card ───────────────────────────────────────────────
class _TrustCard extends StatelessWidget {
  final _TrustData data;
  const _TrustCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrikolikColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 24, color: data.color),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BrikolikColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer Link ──────────────────────────────────────────────
class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.45),
      ),
    );
  }
}

// ── Social Icon ──────────────────────────────────────────────
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
        border:
            Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
    );
  }
}

// ── Particle Painter ─────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble() * 2 * math.pi;

      final x = baseX +
          math.sin((progress * 2 * math.pi * speed) + phase) * 20;
      final y = baseY +
          math.cos((progress * 2 * math.pi * speed) + phase) * 15;

      final alpha = (0.03 + rng.nextDouble() * 0.06) *
          (0.5 + 0.5 * math.sin(progress * 2 * math.pi + phase));
      final radius = 2 + rng.nextDouble() * 4;

      paint.color = Colors.white.withOpacity(alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}