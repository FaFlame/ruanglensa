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

  // List deskripsi dinamis sesuai urutan gambar
  final List<String> _descriptions = [
    'From the best lenses and skilled hands, we are here to capture your precious moments with stunning results.',
    'From rental to the final result, we are here to ensure a limitless photography experience.',
    'Capture the moment, express the story, and let the result inspire many people.',
    'Camera marketplace, the choice of professionals photography.                    ',
    'Express yourself freely, capture the moment, and let the results inspire the world.',
  ];

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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background cycling images with fade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _transition,
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
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
                gaplessPlayback: true,
              ),
            ),
          ),

          // bottom card fixed height
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: size.height * 0.35, // fixed height (48% tinggi layar, bisa disesuaikan)
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Atas: logo, judul, deskripsi
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 283,
                          height: 77,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Image.asset(
                          'assets/images/shootexpressinspire.png',
                          width: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: _transition,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Text(
                          _descriptions[_index],
                          key: ValueKey(_index),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF9DA2A6), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  // Bawah: tombol
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
