import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:note/features/notes/data/note_model.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  final Box _noteBox = Hive.box('notes');

  NoteProvider() {
    loadNotes();
  }

  void loadNotes() {
    _notes = _noteBox.values.cast<Note>().toList();
    notifyListeners();
  }

  void addNote(String title, String content, {String? category}) {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
      category: category,
    );
    _noteBox.add(note);
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note note) {
    note.save();
    notifyListeners();
  }

  void deleteNote(Note note) {
    note.delete();
    _notes.remove(note);
    notifyListeners();
  }

  void togglePin(Note note) {
    note.isPinned = !note.isPinned;
    updateNote(note);
  }

  List<Note> searchNotes(String query) {
    return _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
