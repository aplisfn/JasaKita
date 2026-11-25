import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';
import 'ui.dart';

// ---------------------------------------------------------------------------
// Ilustrasi vektor yang digambar lewat kode (tanpa file gambar / internet),
// supaya ringan dan selalu tajam di semua ukuran layar.
// ---------------------------------------------------------------------------

/// Latar hero: gradient hijau tua, matahari hangat, bukit berlapis, daun, tekstur.
class HeroArt extends StatelessWidget {
  const HeroArt({super.key, this.showSun = true});
  final bool showSun;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HeroPainter(showSun), size: Size.infinite);
  }
}

/// Ilustrasi per kategori jasa (dipakai di kartu kategori, kartu mitra, kartu peran).
class CategoryScene extends StatelessWidget {
  const CategoryScene(this.category, {super.key, this.borderRadius = 20});
  final ServiceCategory category;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(painter: _ScenePainter(category), size: Size.infinite),
    );
  }
}

// ----------------------------- helper gambar -------------------------------

void _gradientBg(Canvas cv, Size s, List<Color> colors) {
  final rect = Offset.zero & s;
  cv.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect),
  );
}

void _hill(Canvas cv, double w, double h, double baseY, double amp, Color color, double phase) {
  final p = Path()..moveTo(0, h)..lineTo(0, baseY);
  for (double x = 0; x <= w; x += 4) {
    p.lineTo(x, baseY + math.sin(x / w * math.pi * 2 + phase) * amp);
  }
  p
    ..lineTo(w, h)
    ..close();
  cv.drawPath(p, Paint()..color = color);
}

void _leaf(Canvas cv, Offset c, double len, double angle, Color color) {
  cv.save();
  cv.translate(c.dx, c.dy);
  cv.rotate(angle);
  final p = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(len * 0.5, -len * 0.38, len, 0)
    ..quadraticBezierTo(len * 0.5, len * 0.38, 0, 0)
    ..close();
  cv.drawPath(p, Paint()..color = color);
  cv.restore();
}

/// Bintik halus ala kertas/tekstur organik.
void _grain(Canvas cv, double w, double h, {double opacity = 0.08}) {
  final r = math.Random(7);
  final paint = Paint()..color = Colors.white.withOpacity(opacity);
  final n = (w * h / 260).clamp(40, 700).toInt();
  for (int i = 0; i < n; i++) {
    cv.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h), 0.8, paint);
  }
}

// ------------------------------- hero --------------------------------------

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.showSun);
  final bool showSun;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    _gradientBg(canvas, size, const [Color(0xFF06182A), Color(0xFF0A4A52), Color(0xFF0B7A70)]);

    if (showSun) {
      final c = Offset(w * 0.84, h * 0.22);
      final glow = Rect.fromCircle(center: c, radius: w * 0.42);
      canvas.drawCircle(
        c,
        w * 0.42,
        Paint()
          ..shader = RadialGradient(
            colors: [kAccent.withOpacity(0.5), kAccent.withOpacity(0)],
          ).createShader(glow),
      );
      canvas.drawCircle(c, w * 0.065, Paint()..color = const Color(0xFFFFD9A8));
    }

    _leaf(canvas, Offset(w * 0.04, h * 0.20), w * 0.20, -0.95, const Color(0xFF2FA394).withOpacity(0.40));
    _leaf(canvas, Offset(w * 0.02, h * 0.34), w * 0.15, -0.35, const Color(0xFF6FD3C2).withOpacity(0.28));
    _leaf(canvas, Offset(w * 0.30, h * 0.06), w * 0.12, 0.7, const Color(0xFF2FA394).withOpacity(0.26));

    _hill(canvas, w, h, h * 0.74, h * 0.05, const Color(0xFF0B7A70).withOpacity(0.55), 0.3);
    _hill(canvas, w, h, h * 0.84, h * 0.04, const Color(0xFF14A596).withOpacity(0.40), 1.7);
    _hill(canvas, w, h, h * 0.93, h * 0.03, const Color(0xFF06324A).withOpacity(0.60), 3.1);

    _grain(canvas, w, h);
  }

  @override
  bool shouldRepaint(covariant _HeroPainter old) => old.showSun != showSun;
}

// ------------------------------ kategori -----------------------------------

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.category);
  final ServiceCategory category;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    switch (category) {
      case ServiceCategory.pertanian:
        _field(canvas, size, w, h);
      case ServiceCategory.bangunan:
        _building(canvas, size, w, h);
      case ServiceCategory.angkut:
        _truck(canvas, size, w, h);
      case ServiceCategory.elektronik:
        _electronics(canvas, size, w, h);
      case ServiceCategory.lainnya:
        _others(canvas, size, w, h);
    }
    _grain(canvas, w, h, opacity: 0.10);
  }

  void _field(Canvas cv, Size s, double w, double h) {
    _gradientBg(cv, s, const [Color(0xFFFFE9B8), Color(0xFFFFC38A)]);
    cv.drawCircle(Offset(w * 0.72, h * 0.28), w * 0.13, Paint()..color = const Color(0xFFFFF4D6));
    _hill(cv, w, h, h * 0.52, h * 0.07, const Color(0xFF9CC48A), 0.0);
    _hill(cv, w, h, h * 0.64, h * 0.06, const Color(0xFF5E9E5E), 1.5);
    final row = Paint()
      ..color = const Color(0xFF2F6B3F)
      ..strokeWidth = math.max(1.6, w * 0.014)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 7; i++) {
      final t = i / 6;
      cv.drawLine(
        Offset(w * (0.5 + (t - 0.5) * 0.18), h * 0.72),
        Offset(w * (-0.15 + t * 1.3), h * 1.02),
        row,
      );
    }
  }

  void _building(Canvas cv, Size s, double w, double h) {
    _gradientBg(cv, s, const [Color(0xFFDCEBF5), Color(0xFFFBE0C2)]);
    final a = Paint()..color = const Color(0xFF5B6B73);
    final b = Paint()..color = const Color(0xFF3E4C54);
    cv.drawRect(Rect.fromLTWH(w * 0.08, h * 0.46, w * 0.22, h * 0.54), a);
    cv.drawRect(Rect.fromLTWH(w * 0.32, h * 0.30, w * 0.22, h * 0.70), b);
    cv.drawRect(Rect.fromLTWH(w * 0.56, h * 0.54, w * 0.16, h * 0.46), a);
    final win = Paint()..color = const Color(0xFFFFD889);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 2; c++) {
        cv.drawRect(
          Rect.fromLTWH(w * (0.355 + c * 0.085), h * (0.35 + r * 0.13), w * 0.05, h * 0.06),
          win,
        );
      }
    }
    final crane = Paint()
      ..color = const Color(0xFFE8833A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, w * 0.016);
    final cable = Paint()
      ..color = const Color(0xFFE8833A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    cv.drawLine(Offset(w * 0.86, h), Offset(w * 0.86, h * 0.16), crane);
    cv.drawLine(Offset(w * 0.58, h * 0.16), Offset(w * 0.98, h * 0.16), crane);
    cv.drawLine(Offset(w * 0.66, h * 0.16), Offset(w * 0.66, h * 0.34), cable);
    cv.drawRect(
      Rect.fromLTWH(w * 0.63, h * 0.34, w * 0.06, h * 0.045),
      Paint()..color = const Color(0xFF3E4C54),
    );
    cv.drawRect(
      Rect.fromLTWH(0, h * 0.93, w, h * 0.07),
      Paint()..color = const Color(0xFF8A7A66),
    );
  }

  void _truck(Canvas cv, Size s, double w, double h) {
    _gradientBg(cv, s, const [Color(0xFFD6E6FF), Color(0xFFFFE6C7)]);
    _hill(cv, w, h, h * 0.60, h * 0.05, const Color(0xFF9CC3A0), 0.8);
    cv.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = const Color(0xFF4A5560));
    final dash = Paint()..color = const Color(0xFFFFE9B8);
    for (double x = 0; x < w; x += w * 0.16) {
      cv.drawRect(Rect.fromLTWH(x, h * 0.89, w * 0.08, h * 0.015), dash);
    }
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.38, w * 0.52, h * 0.36),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = const Color(0xFF3B82F6),
    );
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.50, w * 0.25, h * 0.24),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = const Color(0xFF2563EB),
    );
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.76, h * 0.54, w * 0.10, h * 0.09),
        Radius.circular(w * 0.015),
      ),
      Paint()..color = const Color(0xFFCFE3FF),
    );
    final tire = Paint()..color = const Color(0xFF1F2933);
    final hub = Paint()..color = const Color(0xFFE5E7EB);
    for (final x in const [0.24, 0.50, 0.78]) {
      cv.drawCircle(Offset(w * x, h * 0.77), w * 0.058, tire);
      cv.drawCircle(Offset(w * x, h * 0.77), w * 0.024, hub);
    }
  }

  void _electronics(Canvas cv, Size s, double w, double h) {
    _gradientBg(cv, s, const [Color(0xFF2B2250), Color(0xFF5B3FA6)]);
    final trace = Paint()
      ..color = const Color(0xFFB9A4FF).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final node = Paint()..color = const Color(0xFFE2D8FF);
    final lines = <List<Offset>>[
      [Offset(0, h * 0.30), Offset(w * 0.22, h * 0.30), Offset(w * 0.30, h * 0.42)],
      [Offset(0, h * 0.70), Offset(w * 0.20, h * 0.70), Offset(w * 0.30, h * 0.58)],
      [Offset(w, h * 0.28), Offset(w * 0.80, h * 0.28), Offset(w * 0.70, h * 0.42)],
      [Offset(w, h * 0.72), Offset(w * 0.78, h * 0.72), Offset(w * 0.70, h * 0.58)],
    ];
    for (final pts in lines) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      cv.drawPath(path, trace);
      cv.drawCircle(pts.last, 3.5, node);
    }
    final chip = Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.32, height: w * 0.32);
    final pin = Paint()..color = const Color(0xFFB9A4FF);
    for (int i = 0; i < 4; i++) {
      final dx = chip.left + chip.width * (0.18 + i * 0.22);
      cv.drawRect(Rect.fromLTWH(dx, chip.top - w * 0.03, w * 0.02, w * 0.03), pin);
      cv.drawRect(Rect.fromLTWH(dx, chip.bottom, w * 0.02, w * 0.03), pin);
    }
    cv.drawRRect(
      RRect.fromRectAndRadius(chip, Radius.circular(w * 0.03)),
      Paint()..color = const Color(0xFF1E1A3A),
    );
    cv.drawRRect(
      RRect.fromRectAndRadius(chip.deflate(w * 0.04), Radius.circular(w * 0.02)),
      Paint()
        ..color = const Color(0xFFB9A4FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    cv.drawCircle(chip.center, w * 0.025, node);
  }

  void _others(Canvas cv, Size s, double w, double h) {
    _gradientBg(cv, s, const [Color(0xFFEFE6D2), Color(0xFFD9E6D0)]);
    cv.drawCircle(Offset(w * 0.25, h * 0.35), w * 0.22, Paint()..color = const Color(0xFFBBD5B0));
    cv.drawCircle(Offset(w * 0.68, h * 0.28), w * 0.16, Paint()..color = const Color(0xFFF3C58E));
    cv.drawCircle(Offset(w * 0.55, h * 0.70), w * 0.24, Paint()..color = const Color(0xFF8FB89A));
    cv.drawCircle(Offset(w * 0.15, h * 0.85), w * 0.12, Paint()..color = const Color(0xFFE8A96B));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.category != category;
}
