import 'package:flutter/material.dart';
import 'package:note/core/widgets/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'My Notes',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Center(
        child: AppText(
          text: 'No notes yet. Add one!',
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
