import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/notes/presentation/provider/note_provider.dart';

class NoteSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(AppIcons.clear), onPressed: () => query = ''),
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
    final results = noteProvider.searchNotes(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ListTile(
          title: AppText(text: note.title),
          subtitle: AppText(text: note.content),
          onTap: () {},
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
