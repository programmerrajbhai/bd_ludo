import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'constants.dart';
import 'models.dart';

class BoardPainter extends CustomPainter {
  final List<Player> players;
  final List<int> movable;
  final int? lastDice;
  final int animTokenIndex;
  final double animValue;

  BoardPainter({
    required this.players,
    required this.movable,
    this.lastDice,
    this.animTokenIndex = -1,
    this.animValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15.0;

    // Background
    final Paint bgPaint = Paint()..color = boardBase;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawStations(canvas, cellSize);
    _drawTracks(canvas, cellSize);
    _drawCenter(canvas, cellSize);
    _drawTokens(canvas, cellSize);
  }

  void _drawStations(Canvas canvas, double s) {
    _drawYard(canvas, s, 0, 0, red);
    _drawYard(canvas, s, 9, 0, green);
    _drawYard(canvas, s, 0, 9, blue);
    _drawYard(canvas, s, 9, 9, yellow);
  }

  void _drawYard(Canvas canvas, double s, double col, double row, Color color) {
    final Paint boxPaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(col * s, row * s, 6 * s, 6 * s), boxPaint);

    final Paint whitePaint = Paint()..color = Colors.white;
    final Rect innerRect = Rect.fromLTWH(
      (col + 0.8) * s,
      (row + 0.8) * s,
      4.4 * s,
      4.4 * s,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(s * 0.5)),
      whitePaint,
    );

    final Paint borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(s * 0.5)),
      borderPaint,
    );

    _drawYardCircle(canvas, s, col + 1.5, row + 1.5, color);
    _drawYardCircle(canvas, s, col + 3.5, row + 1.5, color);
    _drawYardCircle(canvas, s, col + 1.5, row + 3.5, color);
    _drawYardCircle(canvas, s, col + 3.5, row + 3.5, color);
  }

  void _drawYardCircle(
    Canvas canvas,
    double s,
    double x,
    double y,
    Color color,
  ) {
    final Paint p = Paint()..color = color;
    canvas.drawCircle(Offset((x + 0.5) * s, (y + 0.5) * s), s * 0.35, p);
  }

  void _drawTracks(Canvas canvas, double s) {
    final Paint linePaint = Paint()
      ..color = boardLines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final Paint cellFill = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < track.length; i++) {
      Offset p = track[i];
      Rect cellRect = Rect.fromLTWH(p.dx * s, p.dy * s, s, s);

      cellFill.color = Colors.white;
      canvas.drawRect(cellRect, cellFill);
      canvas.drawRect(cellRect, linePaint);

      if (safeTrack.contains(i)) {
        Color? safeColor;
        if (i == startIndex['red'])
          safeColor = red;
        else if (i == startIndex['green'])
          safeColor = green;
        else if (i == startIndex['yellow'])
          safeColor = yellow;
        else if (i == startIndex['blue'])
          safeColor = blue;

        if (safeColor != null) {
          cellFill.color = safeColor;
          canvas.drawRect(cellRect, cellFill);
          canvas.drawRect(cellRect, linePaint);
        }

        // [UPDATED] Star Icon আঁকা (Index 6, 19, 32, 45)
        // এটি আপনার Image 2 এর মার্ক করা ঘরের সাথে মিলবে
        if ([50, 11, 24, 37].contains(i)) {
          cellFill.color = Colors.grey.withOpacity(0.3);
          canvas.drawRect(cellRect, cellFill);
          canvas.drawRect(cellRect, linePaint);
          _drawStar(canvas, cellRect.center, s * 0.4, Colors.grey[700]!);
        }
      }
    }

    homeStretch.forEach((key, offsets) {
      Color c = colorOf(key);
      for (var off in offsets) {
        Rect cellRect = Rect.fromLTWH(off.dx * s, off.dy * s, s, s);
        cellFill.color = c;
        canvas.drawRect(cellRect, cellFill);
        canvas.drawRect(cellRect, linePaint);
      }
    });

    _drawArrow(
      canvas,
      track[startIndex['red']!] * s,
      s,
      Colors.white,
      Icons.arrow_forward,
    );
    _drawArrow(
      canvas,
      track[startIndex['green']!] * s,
      s,
      Colors.white,
      Icons.arrow_downward,
    );
    _drawArrow(
      canvas,
      track[startIndex['yellow']!] * s,
      s,
      Colors.white,
      Icons.arrow_back,
    );
    _drawArrow(
      canvas,
      track[startIndex['blue']!] * s,
      s,
      Colors.white,
      Icons.arrow_upward,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Path path = Path();
    for (int i = 0; i < 10; i++) {
      double angle = (i * 36 - 90) * math.pi / 180;
      double r = (i % 2 == 0) ? radius : radius * 0.4;
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawArrow(
    Canvas canvas,
    Offset pos,
    double s,
    Color color,
    IconData icon,
  ) {
    Offset center = pos + Offset(s / 2, s / 2);
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: s * 0.7,
        fontFamily: icon.fontFamily,
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2 - 1, textPainter.height / 2 - 1),
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: s * 0.7,
        fontFamily: icon.fontFamily,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawCenter(Canvas canvas, double s) {
    Offset center = Offset(7.5 * s, 7.5 * s);
    Offset topLeft = Offset(6 * s, 6 * s);
    Offset topRight = Offset(9 * s, 6 * s);
    Offset bottomLeft = Offset(6 * s, 9 * s);
    Offset bottomRight = Offset(9 * s, 9 * s);

    Paint p = Paint()..style = PaintingStyle.fill;

    p.color = red;
    Path redPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    canvas.drawPath(redPath, p);

    p.color = green;
    Path greenPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();
    canvas.drawPath(greenPath, p);

    p.color = yellow;
    Path yellowPath = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(yellowPath, p);

    p.color = blue;
    Path bluePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(bluePath, p);

    Paint stroke = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(redPath, stroke);
    canvas.drawPath(greenPath, stroke);
    canvas.drawPath(yellowPath, stroke);
    canvas.drawPath(bluePath, stroke);
  }

  void _drawTokens(Canvas canvas, double s) {
    Map<int, List<MapEntry<Player, Token>>> spotMap = {};
    for (var p in players) {
      for (var t in p.tokens) {
        if (t.finished) continue;
        int posKey = t.pos;
        if (t.pos == -1) {
          _drawSingleToken(
            canvas,
            s,
            p,
            t,
            homeYard[p.color]![p.tokens.indexOf(t)],
            1,
            0,
          );
        } else {
          spotMap.putIfAbsent(posKey, () => []).add(MapEntry(p, t));
        }
      }
    }

    spotMap.forEach((pos, list) {
      for (int i = 0; i < list.length; i++) {
        var entry = list[i];
        Offset drawPos;
        if (pos >= 100) {
          int step = pos - 100;
          drawPos = homeStretch[entry.key.color]![step];
        } else {
          drawPos = track[pos];
        }
        _drawSingleToken(
          canvas,
          s,
          entry.key,
          entry.value,
          drawPos,
          list.length,
          i,
        );
      }
    });
  }

  void _drawSingleToken(
    Canvas canvas,
    double s,
    Player p,
    Token t,
    Offset gridPos,
    int count,
    int index,
  ) {
    Offset finalPos = Offset(gridPos.dx * s + s / 2, gridPos.dy * s + s / 2);
    double scale = 1.0;
    Offset offset = Offset.zero;

    if (count > 1) {
      scale = 0.6;
      double offAmt = s * 0.2;
      switch (index % 4) {
        case 0:
          offset = Offset(-offAmt, -offAmt);
          break;
        case 1:
          offset = Offset(offAmt, -offAmt);
          break;
        case 2:
          offset = Offset(-offAmt, offAmt);
          break;
        case 3:
          offset = Offset(offAmt, offAmt);
          break;
      }
    }

    final Paint paint = Paint()..color = colorOf(p.color);
    final Paint border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Paint shadow = Paint()
      ..color = Colors.black26
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(
      finalPos + offset + Offset(1, 2),
      s * 0.35 * scale,
      shadow,
    );
    canvas.drawCircle(finalPos + offset, s * 0.3 * scale, paint);
    canvas.drawCircle(finalPos + offset, s * 0.3 * scale, border);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
