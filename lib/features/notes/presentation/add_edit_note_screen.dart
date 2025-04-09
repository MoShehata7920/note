import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/utils/utils.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/notes/data/note_model.dart';
import 'package:note/features/notes/presentation/provider/audio_provider.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPinned = widget.note!.isPinned;
      _selectedCategory = widget.note!.category;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AudioProvider>(
          context,
          listen: false,
        ).setVoiceNotePath(widget.note!.voiceNotePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).screenSize;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text:
              widget.note == null
                  ? AppStrings.addNote.tr()
                  : AppStrings.editNote.tr(),
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? AppIcons.pin : AppIcons.unPin),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: 'Pin Note',
          ),
          IconButton(
            icon: const Icon(AppIcons.save),
            onPressed: () async => await _saveNote(noteProvider, audioProvider),
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
                hint: AppText(text: AppStrings.selectCategory.tr()),
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
                            AppText(text: category),
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
              if (audioProvider.voiceNotePath != null ||
                  audioProvider.isRecording) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            audioProvider.isRecording
                                ? AppIcons.mic
                                : audioProvider.isPlaying
                                ? AppIcons.stop
                                : AppIcons.play,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed:
                              audioProvider.isRecording
                                  ? null
                                  : audioProvider.isPlaying
                                  ? audioProvider.stopPlaying
                                  : () => _startPlaying(audioProvider),
                        ),
                        SizedBox(width: size.height * 0.01),
                        Expanded(
                          child: AppText(
                            text:
                                audioProvider.isRecording
                                    ? AppStrings.recording.tr()
                                    : AppStrings.voiceNoteRecorded.tr(),
                          ),
                        ),
                        if (!audioProvider.isRecording)
                          IconButton(
                            icon: const Icon(AppIcons.delete),
                            onPressed: audioProvider.deleteVoiceNote,
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
        onPressed:
            audioProvider.isRecording
                ? audioProvider.stopRecording
                : () => _startRecording(audioProvider),
        tooltip:
            audioProvider.isRecording ? 'Stop Recording' : 'Record Voice Note',
        backgroundColor:
            audioProvider.isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.secondary,
        child: Icon(audioProvider.isRecording ? AppIcons.stop : AppIcons.mic),
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

  Future<void> _startRecording(AudioProvider audioProvider) async {
    if (await Permission.microphone.isGranted) {
      await audioProvider.startRecording();
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        await audioProvider.startRecording();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                text: AppStrings.microphonePermissionDenied.tr(),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _startPlaying(AudioProvider audioProvider) async {
    await audioProvider.startPlaying();
  }

  Future<void> _saveNote(
    NoteProvider noteProvider,
    AudioProvider audioProvider,
  ) async {
    try {
      if (_titleController.text.isEmpty &&
          _contentController.text.isEmpty &&
          audioProvider.voiceNotePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText(text: AppStrings.pleaseEnterATitle.tr())),
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
          voiceNotePath: audioProvider.voiceNotePath,
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
          ..voiceNotePath = audioProvider.voiceNotePath
          ..timestamp = DateTime.now();
        await noteProvider.updateNote(widget.note!);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving note: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(text: '${AppStrings.failedToSaveNote.tr()} $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
