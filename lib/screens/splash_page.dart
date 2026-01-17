import 'package:flutter/material.dart';

/// Splash screen
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFF0B1020);
    const bgBottom = Color(0xFF1B1244);
    const cardBg = Color(0xFF111827);
    const cardBorder = Color(0xFF273244);
    const aiAccent = Color(0xFF2563EB);
    const textMuted = Color(0xFF94A3B8);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBottom],
              ),
            ),
          ),

          // Subtle starfield
          const _StarField(),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glowing card + icon
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: aiAccent.withOpacity(0.35),
                          blurRadius: 26,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Image.asset(
                            'assets/images/icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: aiAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: bgTop, width: 2),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ResumeAI title (AI accent)
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Resume'),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(color: aiAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Craft your future with AI',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Page indicator dots (center dot active, like screenshot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Dot(isActive: false),
                      SizedBox(width: 8),
                      _Dot(isActive: true),
                      SizedBox(width: 8),
                      _Dot(isActive: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Version bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'v1.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    // Lightweight “star” dots using gradients, no custom painter needed.
    return IgnorePointer(
      child: Opacity(
        opacity: 0.35,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.2, -0.6),
              radius: 1.2,
              colors: [
                Color(0x33FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _StarFieldPainter(),
          ),
        ),
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.25);

    // Deterministic pseudo-random star positions (no RNG needed).
    const stars = [
      Offset(0.12, 0.18),
      Offset(0.22, 0.34),
      Offset(0.78, 0.22),
      Offset(0.86, 0.38),
      Offset(0.58, 0.14),
      Offset(0.40, 0.28),
      Offset(0.15, 0.62),
      Offset(0.32, 0.74),
      Offset(0.72, 0.68),
      Offset(0.88, 0.78),
      Offset(0.52, 0.56),
      Offset(0.64, 0.44),
      Offset(0.08, 0.44),
      Offset(0.92, 0.12),
      Offset(0.46, 0.10),
      Offset(0.30, 0.12),
      Offset(0.10, 0.86),
      Offset(0.56, 0.84),
      Offset(0.70, 0.90),
      Offset(0.84, 0.58),
    ];

    const radii = [1.2, 1.6, 1.0, 1.4, 1.1];
    for (var i = 0; i < stars.length; i++) {
      final p = Offset(stars[i].dx * size.width, stars[i].dy * size.height);
      final r = radii[i % radii.length];
      canvas.drawCircle(p, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}