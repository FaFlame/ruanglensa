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
    _timer = Timer.periodic(_cycle, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _total);
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
      body: Stack(
        children: [
          // Background cycling images with fade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _transition,
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
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // logo row centered
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // shoot express inspire image
                  Center(
                    child: Image.asset(
                      'assets/images/shootexpressinspire.png',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'From the best lenses and skilled hands, we are here to capture your precious moments with stunning results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9DA2A6), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
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
