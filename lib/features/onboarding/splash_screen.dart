import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'get_started_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1: Logo icon scale-in
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoOpacityAnim;

  // Phase 2: Brand image slide-in from left
  late AnimationController _brandController;
  late Animation<double> _brandOpacityAnim;
  late Animation<Offset> _brandSlideAnim;

  // Phase 3: "Welcome" text slide-in from bottom
  late AnimationController _welcomeController;
  late Animation<double> _welcomeOpacityAnim;
  late Animation<Offset> _welcomeSlideAnim;

  // Phase 4: "Welcome" fade-out
  late AnimationController _welcomeFadeOutController;
  late Animation<double> _welcomeFadeOutAnim;

  @override
  void initState() {
    super.initState();

    // Phase 1
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Phase 2
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _brandOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeIn),
    );
    _brandSlideAnim = Tween<Offset>(
      begin: const Offset(-0.4, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutCubic),
    );

    // Phase 3
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _welcomeOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn),
    );
    _welcomeSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOutCubic),
    );

    // Phase 4
    _welcomeFadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _welcomeFadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _welcomeFadeOutController, curve: Curves.easeOut),
    );

    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // Phase 1 — logo icon appears
    await Future.delayed(const Duration(milliseconds: 300));
    await _logoController.forward();

    // Phase 2 & 3 — brand image slide-in DAN "Welcome" slide-up BERSAMAAN
    await Future.delayed(const Duration(milliseconds: 300));
    await Future.wait([
      _brandController.forward(),
      _welcomeController.forward(),
    ]);

    // Hold
    await Future.delayed(const Duration(milliseconds: 1200));

    // Phase 4 — "Welcome" fades out
    await _welcomeFadeOutController.forward();

    // Hold end splash, then navigate
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _brandController.dispose();
    _welcomeController.dispose();
    _welcomeFadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo row: icon + brand image — sejajar di tengah
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Camera icon (logo only)
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) => Opacity(
                          opacity: _logoOpacityAnim.value,
                          child: Transform.scale(
                            scale: _logoScaleAnim.value,
                            child: child,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logononame.png',
                          width: 64,
                          height: 64,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Brand image: "RUANG LENSA + Sewa mudah, Hasil mewah"
                      ClipRect(
                        child: AnimatedBuilder(
                          animation: _brandController,
                          builder: (context, child) => FractionalTranslation(
                            translation: _brandSlideAnim.value,
                            child: Opacity(
                              opacity: _brandOpacityAnim.value,
                              child: child,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/onlytextmid.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  // "Welcome" text
                  ClipRect(
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_welcomeController, _welcomeFadeOutController]),
                      builder: (context, child) {
                        final isPhase4Running =
                            _welcomeFadeOutController.status ==
                                    AnimationStatus.forward ||
                                _welcomeFadeOutController.status ==
                                    AnimationStatus.completed;

                        final opacity = isPhase4Running
                            ? _welcomeFadeOutAnim.value
                            : _welcomeOpacityAnim.value;

                        return FractionalTranslation(
                          translation: _welcomeSlideAnim.value,
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Welcome',
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
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
  }
}