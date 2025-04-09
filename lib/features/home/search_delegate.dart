import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/notes/presentation/add_edit_note_screen.dart';
import 'package:note/features/notes/presentation/provider/note_provider.dart';

class NoteSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(AppIcons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(AppIcons.backArrow),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final results =
        query.isEmpty ? noteProvider.notes : noteProvider.searchNotes(query);

    if (results.isEmpty) {
      return Center(
        child: AppText(
          text: AppStrings.noResultsFound.tr(),
          fontSize: 18,
          color: Colors.grey,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ListTile(
          title: AppText(
            text: note.title.isEmpty ? AppStrings.untitled.tr() : note.title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: AppText(
            text:
                note.content.isEmpty ? AppStrings.noContent.tr() : note.content,
            fontSize: 14,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing:
              note.voiceNotePath != null
                  ? Icon(
                    AppIcons.audio,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                  : null,
          onTap: () {
            close(context, null); // Close search
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context); // Same UI for suggestions and results
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.hintColor),
        border: InputBorder.none,
      ),
    );
  }
}
