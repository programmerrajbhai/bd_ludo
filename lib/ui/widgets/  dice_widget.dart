import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int value; // 0 = idle
  final bool rolling;
  final VoidCallback onTap;

  const DiceWidget({
    super.key,
    required this.value,
    required this.rolling,
    required this.onTap,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _t = CurvedAnimation(parent: _c, curve: Curves.easeInOutBack);
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rolling && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.rolling && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 92, height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.18)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(.22), Colors.white.withOpacity(.10)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
          boxShadow: const [BoxShadow(blurRadius: 55, offset: Offset(0, 18), color: Color(0x55000000))],
        ),
        child: AnimatedBuilder(
          animation: _t,
          builder: (_, __) {
            final v = widget.rolling ? _t.value : 0.0;
            final rx = (widget.rolling ? (v * 0.9) : 0.0);
            final ry = (widget.rolling ? (v * 1.2) : 0.0);
            return Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0025) // perspective
                  ..rotateX(rx)
                  ..rotateY(ry)
                  ..scale(widget.rolling ? (1.02 - v * 0.04) : 1.0),
                child: _face(widget.value == 0 ? 1 : widget.value),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _face(int n) {
    return Container(
      width: 66, height: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFDDE7FF)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.black.withOpacity(.10)),
        boxShadow: const [BoxShadow(blurRadius: 16, offset: Offset(0, 10), color: Color(0x22000000))],
      ),
      child: CustomPaint(painter: _PipPainter(n)),
    );
  }
}

class _PipPainter extends CustomPainter {
  final int n;
  _PipPainter(this.n);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF111111);
    final w = size.width, h = size.height;
    Offset pos(double x, double y) => Offset(w * x, h * y);

    final r = size.shortestSide * 0.075;

    List<Offset> pts;
    switch (n) {
      case 1: pts = [pos(.5,.5)]; break;
      case 2: pts = [pos(.28,.28), pos(.72,.72)]; break;
      case 3: pts = [pos(.28,.28), pos(.5,.5), pos(.72,.72)]; break;
      case 4: pts = [pos(.28,.28), pos(.72,.28), pos(.28,.72), pos(.72,.72)]; break;
      case 5: pts = [pos(.28,.28), pos(.72,.28), pos(.5,.5), pos(.28,.72), pos(.72,.72)]; break;
      default:
        pts = [pos(.28,.28), pos(.72,.28), pos(.28,.5), pos(.72,.5), pos(.28,.72), pos(.72,.72)];
    }
    for (final o in pts) {
      canvas.drawCircle(o, r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PipPainter oldDelegate) => oldDelegate.n != n;
}
