import 'package:flutter/material.dart';

// --- Global Config ---
const grid = 15;

// --- Colors ---
const red = Color(0xFFFF3B3E);
const green = Color(0xFF21C06B);
const yellow = Color(0xFFFFD32F);
const blue = Color(0xFF2D8CFF);

const bg1 = Color.fromARGB(255, 140, 143, 146);
const bg2 = Color(0xFF0B5FB3);

// --- UI Colors ---
const appBg = Color(0xFF18191A);
const boardBase = Colors.white;
const boardLines = Colors.black;
const winnerColor = Colors.amber;
const uiHighlight = Colors.white12;
const textDim = Colors.white54;
const shadowColor = Colors.black54;

// --- Track & Maps ---
const track = <Offset>[
  Offset(6,0),Offset(7,0),Offset(8,0),Offset(8,1),Offset(8,2),Offset(8,3),Offset(8,4),Offset(8,5),
  Offset(9,6),Offset(10,6),Offset(11,6),Offset(12,6),Offset(13,6),Offset(14,6),Offset(14,7),Offset(14,8),
  Offset(13,8),Offset(12,8),Offset(11,8),Offset(10,8),Offset(9,8),Offset(8,9),Offset(8,10),Offset(8,11),
  Offset(8,12),Offset(8,13),Offset(8,14),Offset(7,14),Offset(6,14),Offset(6,13),Offset(6,12),Offset(6,11),
  Offset(6,10),Offset(6,9),Offset(5,8),Offset(4,8),Offset(3,8),Offset(2,8),Offset(1,8),Offset(0,8),
  Offset(0,7),Offset(0,6),Offset(1,6),Offset(2,6),Offset(3,6),Offset(4,6),Offset(5,6),Offset(6,5),
  Offset(6,4),Offset(6,3),Offset(6,2),Offset(6,1),
];

// Start Index
const startIndex = { 
  'red': 42, 
  'green': 3, 
  'yellow': 16, 
  'blue': 29 
};

// Entry Index
const entryIndex = { 
  'red': 40,    
  'green': 1,   
  'yellow': 14, 
  'blue': 27    
};

// [FIXED] Safe Track: এখানে 8, 21, 34, 47 আছে কিনা ভালো করে দেখুন
final safeTrack = <int>{ 
  42, 3, 16, 29, // Start Points
  47, 8, 21, 34  // Star Points (8 number ghor)
};

// Home Stretch
const homeStretch = {
  'red':    [Offset(1,7), Offset(2,7), Offset(3,7), Offset(4,7), Offset(5,7), Offset(6,7)],
  'green':  [Offset(7,1), Offset(7,2), Offset(7,3), Offset(7,4), Offset(7,5), Offset(7,6)],
  'yellow': [Offset(13,7), Offset(12,7), Offset(11,7), Offset(10,7), Offset(9,7), Offset(8,7)],
  'blue':   [Offset(7,13), Offset(7,12), Offset(7,11), Offset(7,10), Offset(7,9), Offset(7,8)],
};

// Home Yard
const homeYard = {
  'red':    [Offset(2,2), Offset(4,2), Offset(2,4), Offset(4,4)],
  'green':  [Offset(10,2), Offset(12,2), Offset(10,4), Offset(12,4)],
  'yellow': [Offset(10,10), Offset(12,10), Offset(10,12), Offset(12,12)],
  'blue':   [Offset(2,10), Offset(4,10), Offset(2,12), Offset(4,12)],
};

// --- Helper Functions ---
Color colorOf(String c) {
  switch (c) {
    case 'red': return red;
    case 'green': return green;
    case 'yellow': return yellow;
    default: return blue;
  }
}

Color colorByIndex(int index) {
  switch (index) {
    case 0: return red;
    case 1: return green;
    case 2: return yellow;
    case 3: return blue;
    default: return Colors.white;
  }
}

String keyByIndex(int index) {
  switch (index) {
    case 0: return 'red';
    case 1: return 'green';
    case 2: return 'yellow';
    default: return 'blue';
  }
}