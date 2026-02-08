import 'dart:math';

class Sfx {
  // offline safe: simple "beep" simulation via future delays (placeholder)
  // You can replace with asset audio later.
  static Future<void> dice(bool on) async { if(!on) return; _tiny(); }
  static Future<void> move(bool on) async { if(!on) return; _tiny(); }
  static Future<void> capture(bool on) async { if(!on) return; _tiny(); }
  static Future<void> win(bool on) async { if(!on) return; _tiny(); }

  static void _tiny(){
    // intentionally empty (no package). Keeps app offline & stable on web.
    // You can integrate audioplayers later.
    Random().nextInt(1);
  }
}
