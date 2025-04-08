import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/routes_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/home/search_delegate.dart';
import 'package:note/features/notes/presentation/add_edit_note_screen.dart';
import 'package:note/features/notes/presentation/provider/note_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(text: AppStrings.personalNotes.tr()),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () {
              showSearch(context: context, delegate: NoteSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? AppIcons.list : AppIcons.grid),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.settings),
            onPressed: () {
              Navigator.pushNamed(context, Routes.settingsRoute);
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.notes.isEmpty) {
            return Center(child: AppText(text: AppStrings.noNotesYet.tr()));
          }
          return _isGridView
              ? GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: noteProvider.notes.length,
                itemBuilder:
                    (context, index) =>
                        _buildNoteCard(noteProvider.notes[index], noteProvider),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: noteProvider.notes.length,
                itemBuilder:
                    (context, index) =>
                        _buildNoteCard(noteProvider.notes[index], noteProvider),
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
        },
        tooltip: AppStrings.addNote.tr(),
        child: const Icon(AppIcons.add),
      ),
    );
  }

  Widget _buildNoteCard(note, NoteProvider noteProvider) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: AppText(text: note.title)),
                  IconButton(
                    icon: Icon(note.isPinned ? AppIcons.pin : AppIcons.unPin),
                    onPressed: () => noteProvider.togglePin(note),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppText(text: note.content, maxLines: 3),
              const Spacer(),
              AppText(
                text: note.timestamp.toString().substring(0, 16),
                fontSize: 12,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.delete, size: 20),
                    onPressed: () => noteProvider.deleteNote(note),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
