import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: const Color(0xFF00c1e8),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text('قريباً', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
      ),
    );
  }
}
