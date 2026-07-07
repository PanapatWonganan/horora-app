import 'package:flutter/material.dart';

/// Navigator key กลางของแอป — ให้ service ที่อยู่นอก widget tree
/// (เช่น push notification) นำทางได้โดยไม่ต้องถือ BuildContext
/// ผูกกับ MaterialApp ใน app.dart ที่เดียว
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
