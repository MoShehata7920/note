import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/utils/utils.dart';
import 'package:note/features/notes/data/note_model.dart';
import 'package:note/features/notes/presentation/provider/note_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  String? _selectedCategory;

  final List<String> _categories = [
    AppStrings.work.tr(),
    AppStrings.personal.tr(),
    AppStrings.ideas.tr(),
    AppStrings.shopping.tr(),
    AppStrings.travel.tr(),
    AppStrings.health.tr(),
    AppStrings.education.tr(),
    AppStrings.other.tr(),
  ];

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _voiceNotePath;
  bool _isAudioInitialized = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeAudio();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPinned = widget.note!.isPinned;
      _selectedCategory = widget.note!.category;
      _voiceNotePath = widget.note!.voiceNotePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).screenSize;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? AppStrings.addNote.tr()
              : AppStrings.editNote.tr(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? AppIcons.pin : AppIcons.unPin),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: 'Pin Note',
          ),
          IconButton(
            icon: const Icon(AppIcons.save),
            onPressed: () async => await _saveNote(noteProvider),
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: AppStrings.title.tr()),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: size.height * 0.02),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text(AppStrings.selectCategory.tr()),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: size.height * 0.01),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: const InputDecoration(),
                icon: Icon(
                  AppIcons.dropDown,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: AppStrings.writeYourNote.tr(),
                ),
                maxLines: 10,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: size.height * 0.02),
              if (_voiceNotePath != null || _isRecording) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isRecording
                                ? Icons.mic
                                : _isPlaying
                                ? Icons.stop
                                : Icons.play_arrow,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed:
                              _isRecording
                                  ? null
                                  : _isPlaying
                                  ? _stopPlaying
                                  : _startPlaying,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isRecording
                                ? AppStrings.recording.tr()
                                : AppStrings.voiceNoteRecorded.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (!_isRecording)
                          IconButton(
                            icon: const Icon(AppIcons.delete),
                            onPressed:
                                () => setState(() => _voiceNotePath = null),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        tooltip: _isRecording ? 'Stop Recording' : 'Record Voice Note',
        backgroundColor:
            _isRecording ? Colors.red : Theme.of(context).colorScheme.secondary,
        child: Icon(_isRecording ? AppIcons.stop : AppIcons.mic),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work' || "العمل":
        return AppIcons.work;
      case 'Personal' || "شخصي":
        return AppIcons.personal;
      case 'Ideas' || "أفكار":
        return AppIcons.ideas;
      case 'Shopping' || "تسوق":
        return AppIcons.shopping;
      case 'Travel' || "سفر":
        return AppIcons.travel;
      case 'Health' || "صحة":
        return AppIcons.health;
      case 'Education' || "تعليم":
        return AppIcons.education;
      case 'Other' || "أخرى":
      default:
        return AppIcons.others;
    }
  }

  Future<void> _saveNote(NoteProvider noteProvider) async {
    try {
      if (_titleController.text.isEmpty &&
          _contentController.text.isEmpty &&
          _voiceNotePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.pleaseEnterATitle.tr())),
        );
        return;
      }

      if (widget.note == null) {
        await noteProvider.addNote(
          _titleController.text.isEmpty
              ? AppStrings.untitled.tr()
              : _titleController.text,
          _contentController.text,
          category: _selectedCategory,
          isPinned: _isPinned,
          voiceNotePath: _voiceNotePath,
        );
      } else {
        widget.note!
          ..title =
              _titleController.text.isEmpty
                  ? AppStrings.untitled.tr()
                  : _titleController.text
          ..content = _contentController.text
          ..isPinned = _isPinned
          ..category = _selectedCategory
          ..voiceNotePath = _voiceNotePath
          ..timestamp = DateTime.now();
        await noteProvider.updateNote(widget.note!);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving note: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.failedToSaveNote.tr()} $e')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isAudioInitialized && await Permission.microphone.isGranted) {
      final dir = await getTemporaryDirectory();
      _voiceNotePath =
          '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: _voiceNotePath);
      setState(() => _isRecording = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.microphonePermissionDenied.tr())),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (_isAudioInitialized) {
      await _recorder!.stopRecorder();
      setState(() => _isRecording = false);
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await _recorder!.openRecorder();
      await Permission.microphone.request();
      await _player!.openPlayer();
      setState(() => _isAudioInitialized = true);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _startPlaying() async {
    if (_isAudioInitialized &&
        _voiceNotePath != null &&
        File(_voiceNotePath!).existsSync()) {
      try {
        await _player!.startPlayer(fromURI: _voiceNotePath);
        setState(() => _isPlaying = true);
        _player!.onProgress!.listen((event) {
          if (event.position >= event.duration) {
            setState(() => _isPlaying = false);
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error starting playback: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.failedToPlaVoiceNote.tr()} $e'),
            ),
          );
        }
      }
    } else {
      if (kDebugMode) {
        print('Audio not initialized or file not found: $_voiceNotePath');
      }
    }
  }

  Future<void> _stopPlaying() async {
    if (_isAudioInitialized) {
      await _player!.stopPlayer();
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recorder?.closeRecorder();
    _recorder = null;
    _player?.closePlayer();
    _player = null;
    super.dispose();
  }
}
