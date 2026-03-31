import 'dart:async';

import 'package:flutter/material.dart';
import 'get_started_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _stage = 0;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  void _runSequence() async {
    // show stage 0,1,2 then navigate to GetStarted with fade
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _stage = 1);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _stage = 2);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Navigate with fade transition so it looks like black fades away
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GetStartedPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We'll show a full black background. The three stage visuals are
    // implemented by changing alignment/size/text.
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // center content
            AnimatedAlign(
              duration: const Duration(milliseconds: 600),
              alignment: _stage == 2
                  ? const Alignment(0.0, 0.6)
                  : Alignment.center,
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: _stage == 0 ? 80 : (_stage == 1 ? 120 : 140),
                    height: _stage == 0 ? 80 : (_stage == 1 ? 120 : 140),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _stage >= 1 ? 1.0 : 0.0,
                    child: _stage >= 1
                        ? const Text(
                            'Welcome',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // bottom-left logo in stage 2 (mimic third image placement)
            if (_stage >= 2)
              Positioned(
                left: 24,
                bottom: 40,
                child: Opacity(
                  opacity: 1.0,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
