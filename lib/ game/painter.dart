import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'constants.dart';

class BoardPainter extends CustomPainter {
  final List<Map<String, dynamic>> tokenDraw; 
  final Set<int> safeCells;

  BoardPainter({
    required this.tokenDraw,
    required this.safeCells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cell = s / 15; // 15x15 Grid standard

    // 1. White Background Base
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s), bgPaint);

    // 2. Draw Colored Homes (4 Corners)
    _drawHomeBase(canvas, cell, 0, 0, red);       // Top-Left (Red)
    _drawHomeBase(canvas, cell, 9, 0, green);     // Top-Right (Green)
    _drawHomeBase(canvas, cell, 0, 9, blue);      // Bottom-Left (Blue)
    _drawHomeBase(canvas, cell, 9, 9, yellow);    // Bottom-Right (Yellow)

    // 3. Draw Grid Lines (Black Thin Lines)
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Drawing the main cross tracks borders
    // Vertical Tracks
    canvas.drawRect(Rect.fromLTWH(6*cell, 0, 3*cell, 6*cell), linePaint); // Top
    canvas.drawRect(Rect.fromLTWH(6*cell, 9*cell, 3*cell, 6*cell), linePaint); // Bottom
    // Horizontal Tracks
    canvas.drawRect(Rect.fromLTWH(0, 6*cell, 6*cell, 3*cell), linePaint); // Left
    canvas.drawRect(Rect.fromLTWH(9*cell, 6*cell, 6*cell, 3*cell), linePaint); // Right
    
    // Draw internal cells
    _drawCells(canvas, cell, linePaint);

    // 4. Draw Colored Paths (Home Stretches - The "Red/Green Lines")
    _fillPath(canvas, cell, 1, 7, 5, 1, red);    // Red Strip
    _fillPath(canvas, cell, 7, 1, 1, 5, green);  // Green Strip
    _fillPath(canvas, cell, 7, 9, 1, 5, blue);   // Blue Strip
    _fillPath(canvas, cell, 9, 7, 5, 1, yellow); // Yellow Strip

    // 5. Center Triangle (Winner's Spot)
    _drawCenter(canvas, cell);

    // 6. Start Squares (Highlight the starting box on track)
    _fillCell(canvas, cell, 1, 6, red);
    _fillCell(canvas, cell, 8, 1, green);
    _fillCell(canvas, cell, 6, 13, blue);
    _fillCell(canvas, cell, 13, 8, yellow);

    // 7. Safe Stars
    // Manually placing stars on standard safe spots
    _drawStar(canvas, cell, 2, 6); // Red safe
    _drawStar(canvas, cell, 6, 2); // Green safe
    _drawStar(canvas, cell, 8, 12); // Blue safe
    _drawStar(canvas, cell, 12, 8); // Yellow safe
    
    // 8. Draw Tokens (Guti)
    for (final t in tokenDraw) {
      final col = t['color'] as Color;
      final x = t['x'] as double;
      final y = t['y'] as double;
      final glow = (t['glow'] ?? false) as bool;
      _drawToken(canvas, Offset((x + .5) * cell, (y + .5) * cell), cell * .35, col, glow);
    }
  }

  void _drawHomeBase(Canvas c, double cell, int x, int y, Color color) {
    // Large colored box
    c.drawRect(Rect.fromLTWH(x*cell, y*cell, 6*cell, 6*cell), Paint()..color = color);
    
    // Inner white box
    c.drawRect(Rect.fromLTWH((x+1)*cell, (y+1)*cell, 4*cell, 4*cell), Paint()..color = Colors.white);

    // 4 Token Circles inside
    final circlePaint = Paint()..color = color;
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;
    
    List<Offset> spots = [
       Offset((x+1.5)*cell, (y+1.5)*cell),
       Offset((x+4.5)*cell, (y+1.5)*cell),
       Offset((x+1.5)*cell, (y+4.5)*cell),
       Offset((x+4.5)*cell, (y+4.5)*cell),
    ];

    for(var s in spots) {
      c.drawCircle(s, cell*0.6, Paint()..color = Colors.white); // Circle bg
      c.drawCircle(s, cell*0.6, borderPaint); // Circle border
      c.drawCircle(s, cell*0.4, circlePaint); // Inner color
    }
  }

  void _fillPath(Canvas c, double cell, int x, int y, int w, int h, Color color) {
    c.drawRect(Rect.fromLTWH(x*cell, y*cell, w*cell, h*cell), Paint()..color = color);
    
    // Draw grid lines over the color
    final p = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;
    for(int i=0; i<=w; i++) c.drawLine(Offset((x+i)*cell, y*cell), Offset((x+i)*cell, (y+h)*cell), p);
    for(int i=0; i<=h; i++) c.drawLine(Offset(x*cell, (y+i)*cell), Offset((x+w)*cell, (y+i)*cell), p);
  }

  void _fillCell(Canvas c, double cell, int x, int y, Color color) {
    c.drawRect(Rect.fromLTWH(x*cell, y*cell, cell, cell), Paint()..color = color);
    c.drawRect(Rect.fromLTWH(x*cell, y*cell, cell, cell), Paint()..color = Colors.black..style=PaintingStyle.stroke..strokeWidth=1);
  }

  void _drawCells(Canvas c, double cell, Paint p) {
    // Simple loop to draw grid on tracks
    // Top Track
    for(int i=6; i<9; i++) for(int j=0; j<6; j++) c.drawRect(Rect.fromLTWH(i*cell, j*cell, cell, cell), p);
    // Bottom Track
    for(int i=6; i<9; i++) for(int j=9; j<15; j++) c.drawRect(Rect.fromLTWH(i*cell, j*cell, cell, cell), p);
    // Left Track
    for(int i=0; i<6; i++) for(int j=6; j<9; j++) c.drawRect(Rect.fromLTWH(i*cell, j*cell, cell, cell), p);
    // Right Track
    for(int i=9; i<15; i++) for(int j=6; j<9; j++) c.drawRect(Rect.fromLTWH(i*cell, j*cell, cell, cell), p);
  }

  void _drawCenter(Canvas c, double cell) {
    final cx = 7.5 * cell;
    final cy = 7.5 * cell;
    
    // Center Triangle Path
    Path path = Path();
    path.moveTo(6*cell, 6*cell);
    path.lineTo(9*cell, 6*cell);
    path.lineTo(9*cell, 9*cell);
    path.lineTo(6*cell, 9*cell);
    path.close();
    
    // Draw 4 colored triangles
    // Red (Left)
    c.drawPath(Path()..moveTo(cx, cy)..lineTo(6*cell, 6*cell)..lineTo(6*cell, 9*cell)..close(), Paint()..color = red);
    // Green (Top)
    c.drawPath(Path()..moveTo(cx, cy)..lineTo(6*cell, 6*cell)..lineTo(9*cell, 6*cell)..close(), Paint()..color = green);
    // Yellow (Right)
    c.drawPath(Path()..moveTo(cx, cy)..lineTo(9*cell, 6*cell)..lineTo(9*cell, 9*cell)..close(), Paint()..color = yellow);
    // Blue (Bottom)
    c.drawPath(Path()..moveTo(cx, cy)..lineTo(6*cell, 9*cell)..lineTo(9*cell, 9*cell)..close(), Paint()..color = blue);

    // Border
    c.drawRect(Rect.fromLTWH(6*cell, 6*cell, 3*cell, 3*cell), Paint()..style=PaintingStyle.stroke..color=Colors.black..strokeWidth=1.5);
  }

  void _drawStar(Canvas c, double cell, int x, int y) {
    final cx = (x + 0.5) * cell;
    final cy = (y + 0.5) * cell;
    // Simple star icon using text or path
    TextSpan span = TextSpan(style: TextStyle(color: Colors.grey[700], fontSize: cell*0.8, fontFamily: 'MaterialIcons'), text: String.fromCharCode(Icons.star.codePoint));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(cx - tp.width/2, cy - tp.height/2));
  }

  void _drawToken(Canvas c, Offset center, double r, Color col, bool glow) {
    if (glow) {
      c.drawCircle(center, r * 1.3, Paint()..color = Colors.white.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    // Shadow
    c.drawCircle(Offset(center.dx+2, center.dy+2), r, Paint()..color = Colors.black26);
    
    // Main Body
    c.drawCircle(center, r, Paint()..color = col);
    
    // Border
    c.drawCircle(center, r, Paint()..style=PaintingStyle.stroke..color=Colors.white..strokeWidth=2);
    
    // Inner bevel highlight
    c.drawCircle(Offset(center.dx - r*0.2, center.dy - r*0.2), r*0.3, Paint()..color = Colors.white24);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}