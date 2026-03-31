import 'dart:async';

import 'package:flutter/material.dart';
import '../auth/presentation/login_page_clean.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  int _index = 0;
  Timer? _timer;

  final int _total = 5;
  final Duration _cycle = const Duration(milliseconds: 3000);
  final Duration _transition = const Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    // Periodically precache the next image then switch index so the next
    // image is ready when the fade begins (prevents white flash).
    _timer = Timer.periodic(_cycle, (_) async {
      if (!mounted) return;
      final next = (_index + 1) % _total;
      try {
        await precacheImage(AssetImage(_bgFor(next)), context);
      } catch (_) {
        // If precache fails for any reason, continue and still switch.
      }
      if (!mounted) return;
      setState(() => _index = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _bgFor(int i) => 'assets/images/bggetstarted${i + 1}.png';

  @override
  Widget build(BuildContext context) {
    final bg = _bgFor(_index);
    return Scaffold(
      // Make scaffold non-white so that any tiny frames during transition
      // won't flash plain white. Black is safer for images; adjust if needed.
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background cycling images with fade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _transition,
              // Keep outgoing and incoming widgets stacked so there's
              // no empty gap while one fades out and the other fades in.
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Image.asset(
                bg,
                key: ValueKey(bg),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                // Keep the underlying image widget in memory across rebuilds
                // so Flutter reuses the same raster-backed image and avoids
                // temporary blank frames.
                gaplessPlayback: true,
              ),
            ),
          ),

          // bottom card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              // height as needed
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // logo row centered
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 283,
                      height: 77,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // shoot express inspire image
                  Center(
                    child: Image.asset(
                      'assets/images/shootexpressinspire.png',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'From the best lenses and skilled hands, we are here to capture your precious moments with stunning results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9DA2A6), fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011229),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginPageClean(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
