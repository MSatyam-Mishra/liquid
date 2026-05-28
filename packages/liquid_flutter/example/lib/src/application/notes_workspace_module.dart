import 'package:liquid_flutter/liquid_flutter.dart';

import '../domain/models.dart';
import '../domain/notes_repository.dart';

class NotesWorkspaceModule {
  NotesWorkspaceModule(this.repository)
      : tub = Tub(label: 'notes_workspace'),
        folders = Drop<List<WorkspaceFolder>>(<WorkspaceFolder>[], label: 'folders'),
        notes = Drop<List<NoteItem>>(<NoteItem>[], label: 'notes'),
        selectedFolderId = Drop<String>('homework', label: 'selected_folder'),
        searchQuery = Drop<String>('', label: 'search_query'),
        selectedNoteId = Drop<String>('vacation', label: 'selected_note'),
        editorText = Drop<String>('', label: 'editor_text'),
        themeMode = Drop<AppThemeMode>(AppThemeMode.light, label: 'theme_mode'),
        reminder = Drop<ReminderConfig>(
          ReminderConfig(
            date: DateTime(2023, 2, 14),
            primaryTime: '10:30 AM',
            secondaryTime: '02:30 AM',
          ),
          label: 'reminder',
        );

  final NotesRepository repository;
  final Tub tub;

  // Nested state and hierarchy state.
  final Drop<List<WorkspaceFolder>> folders;
  final Drop<String> selectedFolderId;

  // Search state.
  final Drop<String> searchQuery;

  // Data state.
  final Drop<List<NoteItem>> notes;
  final Drop<String> selectedNoteId;

  // Editor state.
  final Drop<String> editorText;

  // Theme state.
  final Drop<AppThemeMode> themeMode;

  final Drop<ReminderConfig> reminder;

  late final Flow<List<NoteItem>> filteredNotes = Flow<List<NoteItem>>(() {
    final String folderId = selectedFolderId.value;
    final String query = searchQuery.value.toLowerCase().trim();
    return notes.value.where((NoteItem note) {
      final bool folderMatch = note.folderId == folderId || folderId == 'all';
      final bool queryMatch =
          query.isEmpty || note.title.toLowerCase().contains(query) || note.preview.toLowerCase().contains(query);
      return folderMatch && queryMatch;
    }).toList(growable: false);
  }, label: 'filtered_notes');

  late final Flow<NoteItem?> selectedNote = Flow<NoteItem?>(() {
    final String id = selectedNoteId.value;
    for (final NoteItem note in notes.value) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }, label: 'selected_note_model');

  void load() {
    folders.value = repository.getFolders();
    notes.value = repository.getNotes();
    final NoteItem? note = selectedNote.value;
    editorText.value = note?.content ?? '';
  }

  void toggleTheme() {
    themeMode.value = themeMode.value == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }

  void selectFolder(String id) {
    selectedFolderId.value = id;
    final List<NoteItem> visible = filteredNotes.value;
    if (visible.isNotEmpty) {
      selectedNoteId.value = visible.first.id;
      editorText.value = visible.first.content;
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    final List<NoteItem> visible = filteredNotes.value;
    if (visible.isNotEmpty) {
      selectedNoteId.value = visible.first.id;
      editorText.value = visible.first.content;
    }
  }

  void selectNote(String id) {
    selectedNoteId.value = id;
    final NoteItem? note = selectedNote.value;
    if (note != null) {
      editorText.value = note.content;
    }
  }

  void updateEditor(String content) {
    editorText.value = content;
  }

  void changeReminderDay(int day) {
    final ReminderConfig current = reminder.value;
    reminder.value = current.copyWith(date: DateTime(2023, 2, day));
  }
}

enum AppThemeMode { light, dark }
