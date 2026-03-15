import 'package:flutter/material.dart';

class SlidesPage extends StatelessWidget {
  const SlidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice Slides'),
      ),
      body: const Center(
        child: Text('Presentation: Slide Editor Coming Soon'),
      ),
    );
  }
}
