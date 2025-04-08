import 'package:flutter/foundation.dart';
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

  Future<void> loadNotes() async {
    try {
      _notes = _noteBox.values.cast<Note>().toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notes: $e');
      }
      _notes = [];
    }
  }

  Future<void> addNote(
    String title,
    String content, {
    String? category,
    bool isPinned = false,
    String? voiceNotePath,
  }) async {
    try {
      final note = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        timestamp: DateTime.now(),
        isPinned: isPinned,
        category: category,
        voiceNotePath: voiceNotePath,
      );
      await _noteBox.add(note);
      _notes.add(note);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding note: $e');
      }
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await note.save();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating note: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await note.delete();
      _notes.remove(note);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting note: $e');
      }
    }
  }

  void togglePin(Note note) {
    try {
      note.isPinned = !note.isPinned;
      updateNote(note);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling pin: $e');
      }
    }
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
