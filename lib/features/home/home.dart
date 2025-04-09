import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/routes_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/utils/utils.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/home/provider/home_provider.dart';
import 'package:note/features/home/search_delegate.dart';
import 'package:note/features/notes/data/note_model.dart';
import 'package:note/features/notes/presentation/add_edit_note_screen.dart';
import 'package:note/features/notes/presentation/provider/audio_provider.dart';
import 'package:note/features/notes/presentation/provider/note_provider.dart';
import 'package:note/features/settings/presentation/provider/settings_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).screenSize;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return AppText(
              text: AppStrings.personalNotes.tr(),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed:
                () => showSearch(
                  context: context,
                  delegate: NoteSearchDelegate(),
                ),
          ),
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return IconButton(
                icon: Icon(
                  homeProvider.isGridView ? AppIcons.list : AppIcons.grid,
                ),
                onPressed: () => homeProvider.toggleViewMode(),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(AppIcons.sort),
            onSelected: (value) {
              final sortedNotes = List<Note>.from(
                context.read<NoteProvider>().notes,
              );
              _sortNotes(sortedNotes, value);
              context.read<NoteProvider>().updateNotes(sortedNotes);
              context.read<HomeProvider>().setSortMode(value);
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'title',
                    child: AppText(
                      text: AppStrings.sortByTitle.tr(),
                      color: Colors.blueGrey,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date',
                    child: AppText(
                      text: AppStrings.sortByDate.tr(),
                      color: Colors.blueGrey,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'pinned',
                    child: AppText(
                      text: AppStrings.sortByPinned.tr(),
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(AppIcons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.settingsRoute),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.addNote,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: size.height * 0.02),
                  AppText(
                    text: AppStrings.noNotesYet.tr(),
                    fontSize: 20,
                    color: Colors.red.shade900,
                  ),
                  SizedBox(height: size.height * 0.02),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditNoteScreen(),
                          ),
                        ),
                    child: Text(AppStrings.addNote.tr()),
                  ),
                ],
              ),
            );
          }
          final sortedNotes = List<Note>.from(noteProvider.notes);
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              _sortNotes(
                sortedNotes,
                homeProvider.sortMode,
              ); // Apply saved sort mode
              return homeProvider.isGridView
                  ? MasonryGridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    itemCount: sortedNotes.length,
                    itemBuilder:
                        (context, index) => _buildNoteCard(
                          sortedNotes[index],
                          noteProvider,
                          size,
                        ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedNotes.length,
                    itemBuilder:
                        (context, index) => _buildNoteCard(
                          sortedNotes[index],
                          noteProvider,
                          size,
                        ),
                  );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
        },
        tooltip: AppStrings.addNote.tr(),
        child: const Icon(AppIcons.add, size: 28),
      ),
    );
  }

  void _sortNotes(List<Note> notes, String sortMode) {
    if (sortMode == 'title') {
      notes.sort(
        (a, b) => (a.title.isEmpty ? AppStrings.untitled.tr() : a.title)
            .compareTo(b.title.isEmpty ? AppStrings.untitled.tr() : b.title),
      );
    } else if (sortMode == 'date') {
      notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (sortMode == 'pinned') {
      notes.sort(
        (a, b) =>
            a.isPinned == b.isPinned
                ? b.timestamp.compareTo(a.timestamp)
                : (a.isPinned ? -1 : 1),
      );
    }
  }

  Widget _buildNoteCard(Note note, NoteProvider noteProvider, Size size) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return Card(
          elevation: 6,
          shadowColor: Colors.grey.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: _getCategoryColor(note.category),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNoteScreen(note: note),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text:
                              note.title.isEmpty
                                  ? AppStrings.untitled.tr()
                                  : note.title,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          note.isPinned ? AppIcons.pin : AppIcons.unPin,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () => noteProvider.togglePin(note),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.001),
                  AppText(
                    text:
                        note.content.isEmpty
                            ? AppStrings.noContent.tr()
                            : note.content,
                    fontSize: 14,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.grey[800],
                  ),
                  if (note.voiceNotePath != null) ...[
                    SizedBox(height: size.height * 0.001),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            audioProvider.isPlaying &&
                                    audioProvider.voiceNotePath ==
                                        note.voiceNotePath
                                ? Icons.stop
                                : Icons.play_arrow,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () async {
                            if (audioProvider.isPlaying &&
                                audioProvider.voiceNotePath ==
                                    note.voiceNotePath) {
                              await audioProvider.stopPlaying();
                            } else {
                              audioProvider.setVoiceNotePath(
                                note.voiceNotePath,
                              );
                              await audioProvider.startPlaying();
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        AppText(
                          text: AppStrings.voiceNote.tr(),
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: size.height * 0.0001),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(note.timestamp),
                          fontSize: 12,
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          AppIcons.delete,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => noteProvider.deleteNote(note),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Work' || "العمل":
        return Colors.blue[50]!;
      case 'Personal' || "شخصي":
        return Colors.green[50]!;
      case 'Ideas' || "أفكار":
        return Colors.yellow[50]!;
      case 'Shopping' || "تسوق":
        return Colors.orange[50]!;
      case 'Travel' || "سفر":
        return Colors.purple[50]!;
      case 'Health' || "صحة":
        return Colors.red[50]!;
      case 'Education' || "تعليم":
        return Colors.teal[50]!;
      case 'Other' || "أخرى":
      default:
        return Colors.grey[50]!;
    }
  }
}
