import 'package:flutter/material.dart';

// --- Global Config ---
const grid = 15;

// --- Existing Colors (আপনার আগের কোড থেকে) ---
const red = Color(0xFFFF3B3E);
const green = Color(0xFF21C06B);
const yellow = Color(0xFFFFD32F);
const blue = Color(0xFF2D8CFF);

const bg1 = Color(0xFF05386B);
const bg2 = Color(0xFF0B5FB3);

// --- NEW UI Colors (নতুন ডিজাইনের জন্য অ্যাড করা হয়েছে) ---
const appBg = Color(0xFF18191A);      // মেইন ব্যাকগ্রাউন্ড (Dark)
const boardBase = Colors.white;       // বোর্ডের সাদা ব্যাকগ্রাউন্ড
const boardLines = Colors.black;      // গ্রিড লাইন
const winnerColor = Colors.amber;     // উইনার টেক্সট কালার
const uiHighlight = Colors.white12;   // বাটন বা বক্সের হালকা ব্যাকগ্রাউন্ড
const textDim = Colors.white54;       // ডিম লাইট টেক্সট
const shadowColor = Colors.black54;   // শ্যাডো

// --- Track & Maps (আপনার আগের কোড যা ছিল হুবহু তাই) ---
const track = <Offset>[
  Offset(6,0),Offset(7,0),Offset(8,0),Offset(8,1),Offset(8,2),Offset(8,3),Offset(8,4),Offset(8,5),
  Offset(9,6),Offset(10,6),Offset(11,6),Offset(12,6),Offset(13,6),Offset(14,6),Offset(14,7),Offset(14,8),
  Offset(13,8),Offset(12,8),Offset(11,8),Offset(10,8),Offset(9,8),Offset(8,9),Offset(8,10),Offset(8,11),
  Offset(8,12),Offset(8,13),Offset(8,14),Offset(7,14),Offset(6,14),Offset(6,13),Offset(6,12),Offset(6,11),
  Offset(6,10),Offset(6,9),Offset(5,8),Offset(4,8),Offset(3,8),Offset(2,8),Offset(1,8),Offset(0,8),
  Offset(0,7),Offset(0,6),Offset(1,6),Offset(2,6),Offset(3,6),Offset(4,6),Offset(5,6),Offset(6,5),
  Offset(6,4),Offset(6,3),Offset(6,2),Offset(6,1),
];

const startIndex = { 'red':0, 'green':13, 'yellow':26, 'blue':39 };
const entryIndex = { 'red':50, 'green':11, 'yellow':24, 'blue':37 };

final safeTrack = <int>{ startIndex['red']!, startIndex['green']!, startIndex['yellow']!, startIndex['blue']!, 8,21,34,47 };

const homeStretch = {
  'red':   [Offset(7,1),Offset(7,2),Offset(7,3),Offset(7,4),Offset(7,5),Offset(7,6)],
  'green': [Offset(13,7),Offset(12,7),Offset(11,7),Offset(10,7),Offset(9,7),Offset(8,7)],
  'yellow':[Offset(7,13),Offset(7,12),Offset(7,11),Offset(7,10),Offset(7,9),Offset(7,8)],
  'blue':  [Offset(1,7),Offset(2,7),Offset(3,7),Offset(4,7),Offset(5,7),Offset(6,7)],
};

const homeYard = {
  'red':   [Offset(2,2),Offset(4,2),Offset(2,4),Offset(4,4)],
  'green': [Offset(10,2),Offset(12,2),Offset(10,4),Offset(12,4)],
  'yellow':[Offset(10,10),Offset(12,10),Offset(10,12),Offset(12,12)],
  'blue':  [Offset(2,10),Offset(4,10),Offset(2,12),Offset(4,12)],
};

// --- Helper Functions ---

// String দিয়ে কালার পাওয়ার জন্য (আপনার আগের ফাংশন)
Color colorOf(String c){
  switch(c){
    case 'red': return red;
    case 'green': return green;
    case 'yellow': return yellow;
    default: return blue;
  }
}

// [NEW] Index দিয়ে কালার পাওয়ার জন্য (UI ফাইলে এরর ফিক্স করার জন্য এটি লাগবে)
// 0: Red, 1: Green, 2: Yellow, 3: Blue
Color colorByIndex(int index) {
  switch (index) {
    case 0: return red;
    case 1: return green;
    case 2: return yellow;
    case 3: return blue;
    default: return Colors.white;
  }
}

// [NEW] Index দিয়ে প্লেয়ারের নাম (String Key) পাওয়ার জন্য
String keyByIndex(int index) {
  switch (index) {
    case 0: return 'red';
    case 1: return 'green';
    case 2: return 'yellow';
    default: return 'blue';
  }
}