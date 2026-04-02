import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════
//  BRIKOLIK HOMEPAGE  —  Inspirée d'Airtasker, marché marocain
// ════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────
  late final AnimationController _heroCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _particleCtrl;
  late final ScrollController _scrollCtrl;

  // ── Hero animations ──────────────────────────────────────
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  // ── Scroll-triggered visibility ──────────────────────────
  final Map<String, bool> _visible = {
    'trust': false,
    'categories': false,
    'recentTasks': false,
    'safety': false,
    'worker': false,
    'blog': false,
    'footer': false,
  };

  bool _scrolled = false;

  final _trustKey       = GlobalKey();
  final _categoriesKey  = GlobalKey();
  final _recentKey      = GlobalKey();
  final _safetyKey      = GlobalKey();
  final _workerKey      = GlobalKey();
  final _blogKey        = GlobalKey();
  final _footerKey      = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _scrollCtrl = ScrollController()..addListener(_onScroll);

    _heroCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1100))
      ..forward();

    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);

    _floatCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);

    _particleCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 8000))
      ..repeat();

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroCtrl,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));

    _heroSlide = Tween<Offset>(
        begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));

    _pulse = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _float = Tween<double>(begin: -5.0, end: 5.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  void _onScroll() {
    final scrolled = _scrollCtrl.offset > 50;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    final pairs = [
      ['trust', _trustKey], ['categories', _categoriesKey],
      ['recentTasks', _recentKey], ['safety', _safetyKey],
      ['worker', _workerKey], ['blog', _blogKey], ['footer', _footerKey],
    ];
    for (final p in pairs) {
      _checkVis(p[0] as String, p[1] as GlobalKey);
    }
  }

  void _checkVis(String key, GlobalKey gk) {
    if (_visible[key] == true) return;
    final ctx = gk.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    if (pos.dy < MediaQuery.of(context).size.height * 0.88) {
      setState(() => _visible[key] = true);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final hPad = isWide ? size.width * 0.08 : 20.0;

    return Scaffold(
      backgroundColor: BrikolikColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // 1. HERO
                _buildHero(size, isWide, hPad),

                // 2. TRUST STATS
                _Reveal(key: _trustKey, visible: _visible['trust']!,
                    child: _buildTrustStats(hPad)),

                // 3. CATEGORIES (Poster une tâche)
                _Reveal(key: _categoriesKey, visible: _visible['categories']!,
                    child: _buildCategories(isWide, hPad)),

                // 4. RECENT TASKS
                _Reveal(key: _recentKey, visible: _visible['recentTasks']!,
                    child: _buildRecentTasks(isWide, hPad)),

                // 5. SAFETY & TRUST
                _Reveal(key: _safetyKey, visible: _visible['safety']!,
                    child: _buildSafetySection(isWide, hPad)),

                // 6. WORKER SECTION
                _Reveal(key: _workerKey, visible: _visible['worker']!,
                    child: _buildWorkerSection(isWide, hPad)),

                // 7. BLOG
                _Reveal(key: _blogKey, visible: _visible['blog']!,
                    child: _buildBlog(isWide, hPad)),

                // 8. FOOTER
                _Reveal(key: _footerKey, visible: _visible['footer']!,
                    child: _buildFooter(hPad)),
              ],
            ),
          ),

          // Sticky Nav
          Positioned(top: 0, left: 0, right: 0,
              child: _buildNav(isWide, hPad)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  NAV BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildNav(bool isWide, double hPad) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14, left: hPad, right: hPad,
      ),
      decoration: BoxDecoration(
        color: _scrolled
            ? const Color(0xFF111E3A).withOpacity(0.96)
            : Colors.transparent,
        border: _scrolled
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.07)))
            : null,
        boxShadow: _scrolled
            ? [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 24, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // If on home page, scroll to top, otherwise navigate to home
                if (ModalRoute.of(context)?.settings.name != '/') {
                  Navigator.pushNamed(context, '/');
                } else {
                  _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                }
              },
              child: Row(children: [
                SizedBox(
                  width: 50, height: 50,
                  child: Image.asset('lib/assets/lasgbrik-removebg-preview.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                      const Icon(Icons.build_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('BRIKOLIK',
                  style: TextStyle(
                    fontFamily: 'Nunito', fontSize: 18,
                    fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.0,
                  )),
              ]),
            ),
          ),
          const Spacer(),
          if (isWide) ...[
            _NavLink('Services'),
            _NavLink('Comment ça marche'),
            _NavLink('Artisans'),
            const SizedBox(width: 12),
          ],
          _NavBtn(label: 'Connexion', filled: false,
              onTap: () => Navigator.pushNamed(context, '/login')),
          const SizedBox(width: 8),
          _NavBtn(label: "S'inscrire", filled: true,
              onTap: () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  1. HERO  ──  "FAITES TOUT CE QUI COMPTE"
  // ══════════════════════════════════════════════════════════
  Widget _buildHero(Size size, bool isWide, double hPad) {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: size.height * 0.88),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1D3A), // Fallback base color
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'lib/assets/deuxherobriko.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
              // Dark gradient overlay for text readability (opaque on left, transparent on right)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF0F1D3A).withOpacity(0.95),
                        const Color(0xFF1B2F5E).withOpacity(0.85),
                        const Color(0xFF2B3F7A).withOpacity(0.4),
                        const Color(0xFF1F3A6B).withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.35, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
              // Particles
              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) => CustomPaint(
                  size: Size(size.width, size.height * 0.88),
                  painter: _ParticlePainter(_particleCtrl.value),
                ),
              ),

              // Decorative circle top-right
              Positioned(
                top: -60, right: -60,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BrikolikColors.primary.withOpacity(0.06 * _pulse.value),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40, left: -80,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.025),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 70, hPad, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Floating logo
                      AnimatedBuilder(
                        animation: Listenable.merge([_float, _pulse]),
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _float.value * 0.5),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130, height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: BrikolikColors.primary
                                      .withOpacity(0.12 * _pulse.value),
                                ),
                              ),
                              SizedBox(
                                width: 108, height: 108,
                                child: Image.asset(
                                  'lib/assets/lasgbrik-removebg-preview.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.build_rounded,
                                    color: Colors.white, size: 34,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tagline badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: BrikolikColors.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: BrikolikColors.primary.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4DFFB4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Plus de 2 000 artisans disponibles au Maroc',
                              style: TextStyle(
                                fontFamily: 'Nunito', fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Main headline
                      Text(
                        'Faites tout\nce qui compte.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: isWide ? 52 : 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.08,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Accent line
                      Container(
                        width: 64, height: 4,
                        decoration: BoxDecoration(
                          color: BrikolikColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Bricolik met en relation les particuliers\navec des artisans de confiance partout\nau Maroc — rapidement, simplement.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: isWide ? 17 : 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.72),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // CTA Buttons
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _HeroBtn(
                            label: '📋  Poster une tâche',
                            filled: true,
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/post-job'),
                          ),
                          _HeroBtn(
                            label: '🔧  Devenir bricoleur',
                            filled: false,
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/role'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Quick search bar
                      _buildSearchBar(),

                      const SizedBox(height: 28),

                      // Popular searches
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Plombier', 'Nettoyage', 'Peinture',
                          'Électricien', 'Déménagement',
                        ].map((s) => _QuickTag(label: s)).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded,
              color: BrikolikColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Ex : Plombier à Casablanca…',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: BrikolikColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BrikolikColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 40,
            child: const Center(
              child: Text('Chercher',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  2. TRUST STATS
  // ══════════════════════════════════════════════════════════
  Widget _buildTrustStats(double hPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8650A), Color(0xFFBF4D00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final isRow = constraints.maxWidth > 480;
        final items = [
          _StatData('2 000+', 'Artisans vérifiés', Icons.engineering_rounded),
          _StatData('15 000+', 'Tâches réussies', Icons.check_circle_outline_rounded),
          _StatData('4.8 ★', 'Note moyenne', Icons.star_outline_rounded),
          _StatData('48h', 'Délai moyen', Icons.timer_outlined),
        ];
        if (isRow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _StatTile(data: items[i]),
                if (i < items.length - 1)
                  Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.2)),
              ],
            ],
          );
        }
        return Column(
          children: items.map((d) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _StatTile(data: d, horizontal: true),
          )).toList(),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  3. CATEGORIES / POSTER UNE TÂCHE
  // ══════════════════════════════════════════════════════════
  Widget _buildCategories(bool isWide, double hPad) {
    final cats = [
      _CatData(Icons.water_drop_outlined,    'Plomberie',      const Color(0xFF3B8BD4)),
      _CatData(Icons.bolt_outlined,           'Électricité',    const Color(0xFFF5A623)),
      _CatData(Icons.cleaning_services_outlined,'Nettoyage',   const Color(0xFF2D9B5A)),
      _CatData(Icons.format_paint_outlined,   'Peinture',       const Color(0xFFD85A30)),
      _CatData(Icons.local_shipping_outlined, 'Déménagement',   const Color(0xFF9B4DB5)),
      _CatData(Icons.grass_outlined,          'Jardinage',      const Color(0xFF639922)),
      _CatData(Icons.carpenter_outlined,      'Menuiserie',     const Color(0xFF854F0B)),
      _CatData(Icons.ac_unit_outlined,        'Climatisation',  const Color(0xFF0097A7)),
      _CatData(Icons.construction_outlined,   'Maçonnerie',     const Color(0xFF6B6560)),
      _CatData(Icons.camera_indoor_outlined,  'Sécurité',       const Color(0xFF2D3561)),
      _CatData(Icons.roofing_outlined,        'Toiture',        const Color(0xFFB5651D)),
      _CatData(Icons.more_horiz_rounded,      'Plus encore…',   BrikolikColors.textSecondary),
    ];

    return Container(
      color: BrikolikColors.background,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 56),
      child: Column(
        children: [
          _SectionHead(
            badge: '🚀  Poster une tâche',
            title: 'Que voulez-vous faire\nafaire faire ?',
            subtitle: 'Sélectionnez une catégorie et recevez des offres en minutes',
          ),
          const SizedBox(height: 36),

          // Steps
          _buildHowSteps(isWide),

          const SizedBox(height: 36),

          // Grid
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 500 ? 4 : 3;
            final gap  = 12.0;
            final w    = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap, runSpacing: gap,
              children: cats.map((cat) => SizedBox(
                width: w,
                child: _CatCard(data: cat),
              )).toList(),
            );
          }),

          const SizedBox(height: 28),
          _PostTaskBtn(
            onTap: () => Navigator.pushReplacementNamed(context, '/post-job'),
          ),
        ],
      ),
    );
  }

  Widget _buildHowSteps(bool isWide) {
    final steps = [
      _StepD('1', '📝', 'Décrivez', 'Publiez votre besoin en 60 secondes'),
      _StepD('2', '📬', 'Recevez', 'Des artisans vous envoient leurs offres'),
      _StepD('3', '✅', 'Choisissez', 'Sélectionnez le meilleur et réservez'),
    ];

    return LayoutBuilder(builder: (ctx, c) {
      final isRow = c.maxWidth > 480;
      if (isRow) {
        return Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              Expanded(child: _StepCard(d: steps[i])),
              if (i < 2) const _Arrow(),
            ],
          ],
        );
      }
      return Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepCard(d: steps[i]),
            if (i < 2) const _DownArrow(),
          ],
        ],
      );
    });
  }

  // ══════════════════════════════════════════════════════════
  //  4. RECENT TASKS
  // ══════════════════════════════════════════════════════════
  Widget _buildRecentTasks(bool isWide, double hPad) {
    final tasks = [
      _TaskD('Réparation fuite robinet', 'Plomberie', 'Casablanca, Maarif',
          '200–350 MAD', '4.9', Icons.water_drop_outlined, const Color(0xFF3B8BD4), '15 min'),
      _TaskD('Peinture salon 30m²', 'Peinture', 'Rabat, Agdal',
          '700–1 100 MAD', '4.8', Icons.format_paint_outlined, const Color(0xFFD85A30), '1h'),
      _TaskD('Nettoyage appartement F3', 'Nettoyage', 'Marrakech, Guéliz',
          '150–250 MAD', '5.0', Icons.cleaning_services_outlined, const Color(0xFF2D9B5A), '2h'),
      _TaskD('Installation prise électrique', 'Électricité', 'Tanger, Centre',
          '120–200 MAD', '4.7', Icons.bolt_outlined, const Color(0xFFF5A623), '3h'),
      _TaskD('Déménagement studio', 'Déménagement', 'Fès, Saïss',
          '400–700 MAD', '4.8', Icons.local_shipping_outlined, const Color(0xFF9B4DB5), '5h'),
      _TaskD('Pose carrelage terrasse', 'Maçonnerie', 'Agadir, Centre',
          '500–900 MAD', '4.9', Icons.construction_outlined, const Color(0xFF6B6560), '1j'),
    ];

    return Container(
      color: BrikolikColors.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 56),
      child: Column(
        children: [
          _SectionHead(
            badge: '🔥  En ce moment au Maroc',
            title: 'Ce que cherchent\nles gens autour de vous',
            subtitle: 'Tâches récentes postées par la communauté Brikolik',
          ),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 500 ? 2 : 1;
            final gap  = 14.0;
            final w    = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap, runSpacing: gap,
              children: tasks.map((t) =>
                  SizedBox(width: w, child: _TaskCard(data: t))).toList(),
            );
          }),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/jobs'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Voir toutes les tâches'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BrikolikColors.primary,
              side: const BorderSide(color: BrikolikColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              textStyle: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  5. SAFETY & TRUST
  // ══════════════════════════════════════════════════════════
  Widget _buildSafetySection(bool isWide, double hPad) {
    final items = [
      _SafetyD(Icons.verified_user_outlined, 'Artisans vérifiés',
          'Chaque artisan passe une vérification d\'identité et de compétences avant d\'être accepté sur Brikolik.',
          BrikolikColors.primary),
      _SafetyD(Icons.lock_outline_rounded, 'Paiement 100% sécurisé',
          'Votre argent est retenu jusqu\'à la fin de la mission. Payez seulement quand vous êtes satisfait.',
          BrikolikColors.success),
      _SafetyD(Icons.star_border_rounded, 'Avis clients réels',
          'Chaque évaluation est vérifiée. Lisez des avis authentiques de vrais clients au Maroc.',
          const Color(0xFFF5A623)),
      _SafetyD(Icons.shield_outlined, 'Assistance 24h/7j',
          'Notre équipe est disponible par téléphone, WhatsApp et chat pour vous aider à tout moment.',
          const Color(0xFF9B4DB5)),
    ];

    return Container(
      color: BrikolikColors.surface,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 56),
      child: Column(
        children: [
          _SectionHead(
            badge: '🔒  Confiance & Sécurité',
            title: 'Votre sécurité est\nnotre priorité',
            subtitle: 'Nous vérifions chaque artisan et chaque paiement',
          ),
          const SizedBox(height: 36),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 500 ? 2 : 1;
            final gap = 16.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap, runSpacing: gap,
              children: items.map((it) =>
                  SizedBox(width: w, child: _SafetyCard(data: it))).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  6. WORKER SECTION — "Soyez votre propre patron"
  // ══════════════════════════════════════════════════════════
  Widget _buildWorkerSection(bool isWide, double hPad) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1D3A), Color(0xFF1B2F5E), Color(0xFF2B3F7A)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: BrikolikColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: BrikolikColors.primary.withOpacity(0.5)),
            ),
            child: const Text('🔧  Pour les artisans',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12,
                  fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 20),

          const Text('Soyez votre\npropre patron.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 34,
              fontWeight: FontWeight.w800, color: Colors.white, height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rejoignez des milliers d\'artisans marocains\nqui gagnent leur vie à leur rythme avec Brikolik.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.65), height: 1.6,
            ),
          ),

          const SizedBox(height: 40),

          // Benefits
          LayoutBuilder(builder: (ctx, c) {
            final isRow = c.maxWidth > 480;
            final benefits = [
              _BenefitD('💰', 'Gagnez plus', 'Fixez vos tarifs et choisissez vos missions'),
              _BenefitD('📅', 'Votre agenda', 'Travaillez quand vous le souhaitez'),
              _BenefitD('⭐', 'Votre réputation', 'Construisez un profil 5 étoiles'),
            ];
            if (isRow) {
              return Row(
                children: benefits.map((b) =>
                    Expanded(child: _BenefitCard(d: b))).toList(),
              );
            }
            return Column(
              children: benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BenefitCard(d: b),
              )).toList(),
            );
          }),

          const SizedBox(height: 36),

          // Profile example card
          _WorkerProfileCard(),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/role'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Commencer à gagner',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrikolikColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  7. BLOG
  // ══════════════════════════════════════════════════════════
  Widget _buildBlog(bool isWide, double hPad) {
    final posts = [
      _BlogD('10 conseils pour bien choisir son plombier au Maroc',
          'Astuces', '5 min'),
      _BlogD('Comment fixer un tarif juste pour vos services à domicile ?',
          'Guide artisans', '7 min'),
      _BlogD('Brikolik à Marrakech : 500 artisans disponibles dès maintenant',
          'Actualité', '3 min'),
    ];

    return Container(
      color: BrikolikColors.background,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 56),
      child: Column(
        children: [
          _SectionHead(
            badge: '📰  Blog & Conseils',
            title: 'Articles, conseils\net actualités',
            subtitle: 'Tout ce que vous devez savoir sur les services à domicile au Maroc',
          ),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 500 ? 3 : 1;
            final gap = 16.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap, runSpacing: gap,
              children: posts.map((p) =>
                  SizedBox(width: w, child: _BlogCard(data: p))).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  8. FOOTER
  // ══════════════════════════════════════════════════════════
  Widget _buildFooter(double hPad) {
    return Container(
      color: const Color(0xFF0F1D3A),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
      child: Column(
        children: [
          // Logo + tagline
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: BrikolikColors.primary),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                    'lib/assets/lasgbrik-removebg-preview.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                    const Icon(Icons.build_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('BRIKOLIK',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 14,
                fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: 1.8,
              )),
          ]),
          const SizedBox(height: 8),
          Text('Services à domicile · المغرب 🇲🇦',
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            )),
          const SizedBox(height: 28),

          // Links
          Wrap(
            spacing: 20, runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              'À propos', 'Comment ça marche', 'Services',
              'Artisans', 'Blog', 'Contact', 'CGU', 'Confidentialité',
            ].map((l) => Text(l,
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.45),
              ))).toList(),
          ),
          const SizedBox(height: 24),

          // Socials
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Social(Icons.facebook_rounded),
            const SizedBox(width: 14),
            _Social(Icons.camera_alt_outlined),
            const SizedBox(width: 14),
            _Social(Icons.chat_bubble_outline_rounded),
          ]),

          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.07)),
          const SizedBox(height: 16),

          Text(
            '© 2026 Brikolik — Tous droits réservés · Casablanca, Maroc',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 11,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  DATA MODELS
// ════════════════════════════════════════════════════════════════
class _StatData  { final String v, l; final IconData i;
  const _StatData(this.v, this.l, this.i); }
class _CatData   { final IconData icon; final String l; final Color c;
  const _CatData(this.icon, this.l, this.c); }
class _TaskD     { final String t, cat, city, budget, rating;
  final IconData icon; final Color c; final String ago;
  const _TaskD(this.t, this.cat, this.city, this.budget,
      this.rating, this.icon, this.c, this.ago); }
class _SafetyD   { final IconData icon; final String t, d; final Color c;
  const _SafetyD(this.icon, this.t, this.d, this.c); }
class _BenefitD  { final String emoji, t, d;
  const _BenefitD(this.emoji, this.t, this.d); }
class _BlogD     { final String t, tag, read;
  const _BlogD(this.t, this.tag, this.read); }
class _StepD     { final String n, emoji, t, d;
  const _StepD(this.n, this.emoji, this.t, this.d); }

// ════════════════════════════════════════════════════════════════
//  SMALL WIDGETS
// ════════════════════════════════════════════════════════════════

class _Reveal extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _Reveal({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.04),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  const _NavLink(this.label);
  @override
  State<_NavLink> createState() => _NavLinkState();
}
class _NavLinkState extends State<_NavLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _h ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(widget.label,
        style: TextStyle(fontFamily: 'Nunito', fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _h ? Colors.white : Colors.white.withOpacity(0.72))),
    ),
  );
}

class _NavBtn extends StatefulWidget {
  final String label; final bool filled; final VoidCallback onTap;
  const _NavBtn({required this.label, required this.filled, required this.onTap});
  @override
  State<_NavBtn> createState() => _NavBtnState();
}
class _NavBtnState extends State<_NavBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_h ? Colors.white.withOpacity(0.92) : Colors.white)
              : Colors.white.withOpacity(_h ? 0.12 : 0.0),
          borderRadius: BorderRadius.circular(10),
          border: widget.filled ? null : Border.all(
              color: Colors.white.withOpacity(_h ? 0.55 : 0.35), width: 1.2),
          boxShadow: widget.filled ? [BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10, offset: const Offset(0, 3),
          )] : [],
        ),
        child: Text(widget.label, style: TextStyle(
          fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700,
          color: widget.filled ? BrikolikColors.primary : Colors.white,
        )),
      ),
    ),
  );
}

class _HeroBtn extends StatefulWidget {
  final String label; final bool filled; final VoidCallback onTap;
  const _HeroBtn({required this.label, required this.filled, required this.onTap});
  @override
  State<_HeroBtn> createState() => _HeroBtnState();
}
class _HeroBtnState extends State<_HeroBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: widget.filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: widget.filled ? null : Border.all(
              color: Colors.white.withOpacity(_h ? 0.75 : 0.45), width: 1.5),
          boxShadow: widget.filled ? [BoxShadow(
            color: Colors.black.withOpacity(_h ? 0.28 : 0.16),
            blurRadius: _h ? 30 : 20, offset: const Offset(0, 8),
          )] : [],
        ),
        transform: _h ? (Matrix4.identity()..translate(0.0, -2.0)) : Matrix4.identity(),
        child: Text(widget.label, style: TextStyle(
          fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700,
          color: widget.filled ? BrikolikColors.primary : Colors.white.withOpacity(_h ? 1.0 : 0.92),
        )),
      ),
    ),
  );
}

class _QuickTag extends StatelessWidget {
  final String label;
  const _QuickTag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Text(label, style: const TextStyle(
      fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600,
      color: Colors.white,
    )),
  );
}

class _StatTile extends StatelessWidget {
  final _StatData data; final bool horizontal;
  const _StatTile({required this.data, this.horizontal = false});
  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Row(children: [
        Icon(data.i, size: 20, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.v, style: const TextStyle(fontFamily: 'Nunito',
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(data.l, style: TextStyle(fontFamily: 'Nunito', fontSize: 11,
              color: Colors.white.withOpacity(0.7))),
        ]),
      ]);
    }
    return Column(children: [
      Icon(data.i, size: 22, color: Colors.white.withOpacity(0.75)),
      const SizedBox(height: 8),
      Text(data.v, style: const TextStyle(fontFamily: 'Nunito',
          fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 3),
      Text(data.l, style: TextStyle(fontFamily: 'Nunito', fontSize: 11,
          fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.65))),
    ]);
  }
}

class _SectionHead extends StatelessWidget {
  final String badge, title, subtitle;
  const _SectionHead({required this.badge, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: BrikolikColors.primaryLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Text(badge, style: const TextStyle(fontFamily: 'Nunito',
          fontSize: 12, fontWeight: FontWeight.w700,
          color: BrikolikColors.primaryDark, letterSpacing: 0.2)),
    ),
    const SizedBox(height: 18),
    Text(title, textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 30,
          fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary,
          height: 1.18, letterSpacing: -0.5)),
    const SizedBox(height: 10),
    Text(subtitle, textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14,
          fontWeight: FontWeight.w500, color: BrikolikColors.textSecondary, height: 1.5)),
  ]);
}

class _StepCard extends StatelessWidget {
  final _StepD d;
  const _StepCard({required this.d});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: BrikolikColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: BrikolikColors.border),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14, offset: const Offset(0, 5),
      )],
    ),
    child: Column(children: [
      Stack(alignment: Alignment.topRight, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [BrikolikColors.primaryLight, Color(0xFFF0ECF8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: Center(child: Text(d.emoji, style: const TextStyle(fontSize: 24))),
        ),
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: BrikolikColors.primary, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(child: Text(d.n, style: const TextStyle(
            fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
        ),
      ]),
      const SizedBox(height: 14),
      Text(d.t, style: const TextStyle(fontFamily: 'Nunito',
          fontSize: 15, fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary)),
      const SizedBox(height: 6),
      Text(d.d, textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12,
            fontWeight: FontWeight.w500,
            color: BrikolikColors.textSecondary, height: 1.45)),
    ]),
  );
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: 24),
    child: Icon(Icons.arrow_forward_rounded,
        size: 20, color: BrikolikColors.textHint),
  );
}

class _DownArrow extends StatelessWidget {
  const _DownArrow();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Icon(Icons.keyboard_arrow_down_rounded,
        size: 28, color: BrikolikColors.textHint),
  );
}

class _CatCard extends StatefulWidget {
  final _CatData data;
  const _CatCard({required this.data});
  @override
  State<_CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<_CatCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit:  (_) => setState(() => _hover = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: _hover ? widget.data.c.withOpacity(0.08) : BrikolikColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hover ? widget.data.c.withOpacity(0.45) : BrikolikColors.border,
          width: _hover ? 1.5 : 1,
        ),
        boxShadow: _hover ? [BoxShadow(
          color: widget.data.c.withOpacity(0.16),
          blurRadius: 18, offset: const Offset(0, 6),
        )] : [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 3),
        )],
      ),
      transform: _hover
          ? (Matrix4.identity()..translate(0.0, -5.0))
          : Matrix4.identity(),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [widget.data.c.withOpacity(0.12), widget.data.c.withOpacity(0.24)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.data.c.withOpacity(0.2)),
          ),
          child: Icon(widget.data.icon, size: 22, color: widget.data.c),
        ),
        const SizedBox(height: 10),
        Text(widget.data.l,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BrikolikColors.textPrimary)),
      ]),
    ),
  );
}

class _PostTaskBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _PostTaskBtn({required this.onTap});
  @override
  State<_PostTaskBtn> createState() => _PostTaskBtnState();
}
class _PostTaskBtnState extends State<_PostTaskBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 56, width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BrikolikColors.primary,
              _h ? const Color(0xFF7A63AB) : BrikolikColors.accent],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: BrikolikColors.primary.withOpacity(_h ? 0.45 : 0.28),
            blurRadius: _h ? 24 : 16, offset: const Offset(0, 6),
          )],
        ),
        transform: _h ? (Matrix4.identity()..translate(0.0, -2.0)) : Matrix4.identity(),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_rounded, size: 20, color: Colors.white),
          SizedBox(width: 10),
          Text('Poster ma tâche gratuitement',
            style: TextStyle(fontFamily: 'Nunito',
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    ),
  );
}

class _TaskCard extends StatefulWidget {
  final _TaskD data;
  const _TaskCard({required this.data});
  @override
  State<_TaskCard> createState() => _TaskCardState();
}
class _TaskCardState extends State<_TaskCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      transform: _h ? (Matrix4.identity()..translate(0.0, -3.0)) : Matrix4.identity(),
      child: Stack(children: [
        // Card body with uniform border
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(19, 16, 16, 16),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _h ? widget.data.c.withOpacity(0.25) : BrikolikColors.border,
            ),
            boxShadow: [BoxShadow(
              color: _h ? widget.data.c.withOpacity(0.12) : Colors.black.withOpacity(0.04),
              blurRadius: _h ? 20 : 10, offset: const Offset(0, 4),
            )],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.data.c.withOpacity(0.1), widget.data.c.withOpacity(0.22)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.data.icon, size: 19, color: widget.data.c),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.data.cat, style: TextStyle(fontFamily: 'Nunito',
                fontSize: 10, fontWeight: FontWeight.w700,
                color: widget.data.c, letterSpacing: 0.3)),
            Text('Il y a ' + widget.data.ago, style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 10, color: BrikolikColors.textHint)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: BrikolikColors.successLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6,
                decoration: const BoxDecoration(color: BrikolikColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Ouvert', style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 10,
                  fontWeight: FontWeight.w700, color: BrikolikColors.success)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(widget.data.t, style: const TextStyle(fontFamily: 'Nunito',
            fontSize: 14, fontWeight: FontWeight.w700,
            color: BrikolikColors.textPrimary, height: 1.35),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 13, color: BrikolikColors.textHint),
          const SizedBox(width: 3),
          Expanded(child: Text(widget.data.city, style: const TextStyle(
              fontFamily: 'Nunito', fontSize: 11, color: BrikolikColors.textSecondary),
              overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BrikolikColors.surfaceVariant,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: Text(widget.data.budget, style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 11,
                fontWeight: FontWeight.w800, color: BrikolikColors.textPrimary)),
          ),
        ]),
      ]),
        ), // close inner AnimatedContainer
        // Left accent bar
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 3,
            decoration: BoxDecoration(
              color: widget.data.c,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
        ),
      ]), // close Stack
    ), // close outer AnimatedContainer
  ); // close MouseRegion
}

class _SafetyCard extends StatefulWidget {
  final _SafetyD data;
  const _SafetyCard({required this.data});
  @override
  State<_SafetyCard> createState() => _SafetyCardState();
}
class _SafetyCardState extends State<_SafetyCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _h ? widget.data.c.withOpacity(0.35) : BrikolikColors.border),
        boxShadow: [BoxShadow(
          color: _h ? widget.data.c.withOpacity(0.12) : Colors.black.withOpacity(0.04),
          blurRadius: _h ? 24 : 10, offset: const Offset(0, 4),
        )],
      ),
      transform: _h ? (Matrix4.identity()..translate(0.0, -3.0)) : Matrix4.identity(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [widget.data.c.withOpacity(0.1), widget.data.c.withOpacity(0.22)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.data.c.withOpacity(0.2)),
          ),
          child: Icon(widget.data.icon, size: 24, color: widget.data.c),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.data.t, style: const TextStyle(fontFamily: 'Nunito',
              fontSize: 15, fontWeight: FontWeight.w700, color: BrikolikColors.textPrimary)),
          const SizedBox(height: 6),
          Text(widget.data.d, style: const TextStyle(fontFamily: 'Nunito',
              fontSize: 12, fontWeight: FontWeight.w500,
              color: BrikolikColors.textSecondary, height: 1.55)),
        ])),
      ]),
    ),
  );
}

class _BenefitCard extends StatefulWidget {
  final _BenefitD d;
  const _BenefitCard({required this.d});
  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}
class _BenefitCardState extends State<_BenefitCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_h ? 0.13 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(_h ? 0.22 : 0.1)),
        boxShadow: _h ? [BoxShadow(
          color: BrikolikColors.primary.withOpacity(0.25),
          blurRadius: 22, offset: const Offset(0, 6),
        )] : [],
      ),
      transform: _h ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
      child: Column(children: [
        Text(widget.d.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 12),
        Text(widget.d.t, style: const TextStyle(fontFamily: 'Nunito',
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 6),
        Text(widget.d.d, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Nunito', fontSize: 12,
              color: Colors.white.withOpacity(0.65), height: 1.45)),
      ]),
    ),
  );
}

class _WorkerProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.11), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.18)),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 6),
      )],
    ),
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [BrikolikColors.primary, BrikolikColors.accent],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: const Center(child: Text('HT', style: TextStyle(
            fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hamid Tazi', style: TextStyle(
            fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const Text('Plombier · Casablanca', style: TextStyle(
            fontFamily: 'Nunito', fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
          const SizedBox(width: 3),
          const Text('4.9 · 47 avis', style: TextStyle(
              fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF4DFFB4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Text('Ce mois', style: TextStyle(
              fontFamily: 'Nunito', fontSize: 9, color: Color(0xFF4DFFB4), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
        const Text('4 800 MAD', style: TextStyle(
            fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF4DFFB4))),
        const Text('12 missions', style: TextStyle(
            fontFamily: 'Nunito', fontSize: 10, color: Colors.white38)),
      ]),
    ]),
  );
}

class _BlogCard extends StatefulWidget {
  final _BlogD data;
  const _BlogCard({required this.data});
  @override
  State<_BlogCard> createState() => _BlogCardState();
}
class _BlogCardState extends State<_BlogCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _h ? BrikolikColors.primary.withOpacity(0.3) : BrikolikColors.border),
        boxShadow: [BoxShadow(
          color: _h ? BrikolikColors.primary.withOpacity(0.1) : Colors.black.withOpacity(0.04),
          blurRadius: _h ? 24 : 10, offset: const Offset(0, 4),
        )],
      ),
      transform: _h ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: Container(
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [BrikolikColors.primary, BrikolikColors.accent],
              ),
            ),
            child: Stack(children: [
              Positioned(top: -20, right: -20, child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              )),
              Center(child: Icon(Icons.article_rounded, size: 38,
                  color: Colors.white.withOpacity(0.85))),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: BrikolikColors.primaryLight,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(widget.data.tag, style: const TextStyle(
                    fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w700,
                    color: BrikolikColors.primaryDark)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time_rounded, size: 11, color: BrikolikColors.textHint),
              const SizedBox(width: 3),
              Text(widget.data.read + ' de lecture', style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 10, color: BrikolikColors.textHint)),
            ]),
            const SizedBox(height: 10),
            Text(widget.data.t, style: const TextStyle(fontFamily: 'Nunito',
                fontSize: 13, fontWeight: FontWeight.w700,
                color: BrikolikColors.textPrimary, height: 1.45),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            const Row(children: [
              Text("Lire l'article", style: TextStyle(
                fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700,
                color: BrikolikColors.primary)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 13, color: BrikolikColors.primary),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

class _Social extends StatefulWidget {
  final IconData icon;
  const _Social(this.icon);
  @override
  State<_Social> createState() => _SocialState();
}
class _SocialState extends State<_Social> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(_h ? 0.16 : 0.07),
        border: Border.all(color: Colors.white.withOpacity(_h ? 0.28 : 0.1)),
      ),
      child: Icon(widget.icon, size: 17, color: Colors.white.withOpacity(_h ? 0.95 : 0.5)),
    ),
  );
}

// ── Particle Painter ─────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double p;
  _ParticlePainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
      final bx = rng.nextDouble() * size.width;
      final by = rng.nextDouble() * size.height;
      final sp = 0.3 + rng.nextDouble() * 0.7;
      final ph = rng.nextDouble() * 2 * math.pi;
      final x  = bx + math.sin((p * 2 * math.pi * sp) + ph) * 22;
      final y  = by + math.cos((p * 2 * math.pi * sp) + ph) * 16;
      final a  = (0.02 + rng.nextDouble() * 0.05) *
          (0.5 + 0.5 * math.sin(p * 2 * math.pi + ph));
      paint.color = Colors.white.withOpacity(a.clamp(0, 1));
      canvas.drawCircle(Offset(x, y), 2 + rng.nextDouble() * 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.p != p;
}
