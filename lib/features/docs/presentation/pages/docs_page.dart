import 'package:flutter/material.dart';

class DocsPage extends StatelessWidget {
  const DocsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice Docs'),
      ),
      body: const Center(
        child: Text('Word Processor: Rich Text Editor Coming Soon'),
      ),
    );
  }
}
