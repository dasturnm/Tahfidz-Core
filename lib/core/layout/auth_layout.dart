import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Scaffold di sini memastikan child memiliki ruang yang jelas
    return Scaffold(
      body: child,
    );
  }
}