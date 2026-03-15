import 'package:flutter/material.dart';

class FileManagerPage extends StatelessWidget {
  const FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice File Manager'),
      ),
      body: const Center(
        child: Text('Local File Manager: Browsing NextOffice Files'),
      ),
    );
  }
}
