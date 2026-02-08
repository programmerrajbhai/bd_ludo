import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'constants.dart';

class BoardPainter extends CustomPainter {
  final List<Map<String, dynamic>> tokenDraw; // [{color, x, y, glow}]
  final Set<int> safeCells;

  BoardPainter({
    required this.tokenDraw,
    required this.safeCells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cell = s / grid;

    final offsetX = (size.width - s) / 2;
    final offsetY = (size.height - s) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), const Radius.circular(18));

    // board base
    canvas.drawRRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, s, s)),
    );

    // subtle pattern
    final pat = Paint()..color = const Color(0x11000000);
    for (double y = 10; y < s; y += cell * 1.15) {
      for (double x = 10; x < s; x += cell * 1.15) {
        canvas.drawCircle(Offset(x, y), 1.2, pat);
      }
    }

    // quadrants (home blocks)
    _homeBlock(canvas, cell, 0, 0, red);
    _homeBlock(canvas, cell, 9, 0, green);
    _homeBlock(canvas, cell, 0, 9, blue);
    _homeBlock(canvas, cell, 9, 9, yellow);

    // track tiles
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x22000000);

    for (final p in track) {
      final rect = Rect.fromLTWH(p.dx * cell, p.dy * cell, cell, cell);
      canvas.drawRect(rect, Paint()..color = Colors.white);
      canvas.drawRect(rect, stroke);
    }

    // color lanes (center cross)
    for (int x = 1; x <= 5; x++) _fillCell(canvas, cell, x, 7, red.withOpacity(.85));
    for (int y = 1; y <= 5; y++) _fillCell(canvas, cell, 7, y, green.withOpacity(.85));
    for (int x = 9; x <= 13; x++) _fillCell(canvas, cell, x, 7, yellow.withOpacity(.85));
    for (int y = 9; y <= 13; y++) _fillCell(canvas, cell, 7, y, blue.withOpacity(.85));

    // home stretches
    homeStretch.forEach((c, path) {
      for (final p in path) {
        _fillCell(canvas, cell, p.dx.toInt(), p.dy.toInt(), colorOf(c).withOpacity(.92));
      }
    });

    _centerTriangles(canvas, cell);

    // safe stars
    for (final idx in safeCells) {
      final p = track[idx];
      _star(canvas, Offset((p.dx + .5) * cell, (p.dy + .5) * cell), cell * .19);
    }

    // tokens
    for (final t in tokenDraw) {
      final col = t['color'] as Color;
      final x = t['x'] as double;
      final y = t['y'] as double;
      final glow = (t['glow'] ?? false) as bool;
      _token(canvas, Offset((x + .5) * cell, (y + .5) * cell), cell * .34, col, glow);
    }

    // border
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0x33000000),
    );

    canvas.restore();
  }

  void _homeBlock(Canvas c, double cell, int x0, int y0, Color col) {
    for (int y = y0; y < y0 + 6; y++) {
      for (int x = x0; x < x0 + 6; x++) {
        _fillCell(c, cell, x, y, col.withOpacity(.95));
      }
    }
    for (int y = y0 + 1; y < y0 + 5; y++) {
      for (int x = x0 + 1; x < x0 + 5; x++) {
        _fillCell(c, cell, x, y, Colors.white);
      }
    }
    final dots = [
      Offset(x0 + 2.3, y0 + 2.3),
      Offset(x0 + 3.7, y0 + 2.3),
      Offset(x0 + 2.3, y0 + 3.7),
      Offset(x0 + 3.7, y0 + 3.7),
    ];
    final p = Paint()..color = col;
    for (final d in dots) {
      c.drawCircle(Offset(d.dx * cell, d.dy * cell), cell * .30, p);
    }
  }

  void _fillCell(Canvas c, double cell, int x, int y, Color col) {
    final rect = Rect.fromLTWH(x * cell, y * cell, cell, cell);
    c.drawRect(rect, Paint()..color = col);
    c.drawRect(rect, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x22000000));
  }

  void _centerTriangles(Canvas c, double cell) {
    final cx = 7.5 * cell, cy = 7.5 * cell;

    void tri(Offset a, Offset b, Color col) {
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close();
      c.drawPath(path, Paint()..color = col.withOpacity(.95));
      c.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x22000000));
    }

    tri(Offset(6 * cell, 6 * cell), Offset(9 * cell, 6 * cell), green);
    tri(Offset(9 * cell, 6 * cell), Offset(9 * cell, 9 * cell), yellow);
    tri(Offset(9 * cell, 9 * cell), Offset(6 * cell, 9 * cell), blue);
    tri(Offset(6 * cell, 9 * cell), Offset(6 * cell, 6 * cell), red);
  }

  void _star(Canvas c, Offset center, double r) {
    const spikes = 5;
    final path = Path();
    double rot = math.pi / 2 * 3;
    final step = math.pi / spikes;

    path.moveTo(center.dx, center.dy - r);
    for (int i = 0; i < spikes; i++) {
      path.lineTo(center.dx + math.cos(rot) * r, center.dy + math.sin(rot) * r);
      rot += step;
      path.lineTo(center.dx + math.cos(rot) * (r * .45), center.dy + math.sin(rot) * (r * .45));
      rot += step;
    }
    path.close();

    c.drawPath(path, Paint()..color = Colors.white.withOpacity(.85));
    c.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x33000000));
  }

  void _token(Canvas c, Offset center, double r, Color col, bool glow) {
    if (glow) {
      c.drawCircle(center, r * 1.25, Paint()..color = const Color(0xFFF7C62F).withOpacity(.35));
    }
    c.drawCircle(center, r, Paint()..color = Colors.white);
    c.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33000000));

    c.drawCircle(Offset(center.dx, center.dy - r * .05), r * .55, Paint()..color = col);

    final path = Path()
      ..moveTo(center.dx, center.dy + r * .85)
      ..quadraticBezierTo(center.dx - r * .65, center.dy + r * .15, center.dx, center.dy - r * .1)
      ..quadraticBezierTo(center.dx + r * .65, center.dy + r * .15, center.dx, center.dy + r * .85)
      ..close();
    c.drawPath(path, Paint()..color = col);

    c.drawCircle(Offset(center.dx - r * .18, center.dy - r * .35), r * .18, Paint()..color = Colors.white.withOpacity(.55));
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
