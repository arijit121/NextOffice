import 'package:flutter/material.dart';

class FileManagerPage extends StatelessWidget {
  const FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> files = [
      {'name': 'Q4 Report.pdf', 'type': 'PDF', 'icon': Icons.picture_as_pdf, 'color': Colors.red},
      {'name': 'Project Budget.xlsx', 'type': 'Excel', 'icon': Icons.table_chart, 'color': Colors.green},
      {'name': 'Marketing Pitch.pptx', 'type': 'Slides', 'icon': Icons.slideshow, 'color': Colors.orange},
      {'name': 'Meeting Notes.docx', 'type': 'Word', 'icon': Icons.description, 'color': Colors.blue},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice File Manager'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: files.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final file = files[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: file['color'].withOpacity(0.1),
              child: Icon(file['icon'], color: file['color']),
            ),
            title: Text(file['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${file['type']} • Modified 2 hours ago'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
            onTap: () {
              // Open file logic
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }
}
