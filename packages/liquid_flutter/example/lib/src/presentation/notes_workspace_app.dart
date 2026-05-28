import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import '../application/notes_workspace_module.dart';
import '../domain/models.dart';
import '../infrastructure/in_memory_notes_repository.dart';

class NotesWorkspaceApp extends StatefulWidget {
  const NotesWorkspaceApp({super.key});

  @override
  State<NotesWorkspaceApp> createState() => _NotesWorkspaceAppState();
}

class _NotesWorkspaceAppState extends State<NotesWorkspaceApp> {
  late final NotesWorkspaceModule module;
  late final TextEditingController searchController;
  late final TextEditingController editorController;

  @override
  void initState() {
    super.initState();
    module = NotesWorkspaceModule(InMemoryNotesRepository())..load();
    searchController = TextEditingController();
    editorController = TextEditingController(text: module.editorText.value);
    module.editorText.addListener(_syncEditorText);
  }

  @override
  void dispose() {
    module.editorText.removeListener(_syncEditorText);
    module.tub.dispose();
    searchController.dispose();
    editorController.dispose();
    super.dispose();
  }

  void _syncEditorText() {
    if (editorController.text == module.editorText.value) {
      return;
    }
    editorController.value = TextEditingValue(
      text: module.editorText.value,
      selection: TextSelection.collapsed(offset: module.editorText.value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidScope(
      tub: module.tub,
      child: WatchDrop<AppThemeMode, AppThemeMode>(
        source: module.themeMode,
        select: (AppThemeMode mode) => mode,
        builder: (BuildContext context, AppThemeMode mode, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: mode == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF80D9FF)),
              scaffoldBackgroundColor: const Color(0xFFE0E4EB),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: <Widget>[
                      _phoneFrame(_foldersScreen()),
                      _phoneFrame(_editorScreen()),
                      _phoneFrame(_reminderScreen()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _phoneFrame(Widget child) {
    return Container(
      width: 290,
      height: 600,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 24)],
      ),
      child: child,
    );
  }

  Widget _foldersScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const CircleAvatar(radius: 13, backgroundColor: Color(0xFFD1E6FF)),
            const SizedBox(width: 10),
            const Text('My folders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.brightness_6_outlined),
              onPressed: module.toggleTheme,
            ),
          ],
        ),
        TextField(
          controller: searchController,
          onChanged: module.updateSearch,
          decoration: InputDecoration(
            hintText: 'Filter by / Search notes',
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF3F5F8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Folder hierarchy', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: Column(
            children: <Widget>[
              WatchDrop<List<WorkspaceFolder>, List<WorkspaceFolder>>(
                source: module.folders,
                select: (List<WorkspaceFolder> list) => list,
                builder: (BuildContext context, List<WorkspaceFolder> folders, Widget? child) {
                  return Expanded(
                    child: ListView(
                      children: <Widget>[
                        _folderTile('all', 'All'),
                        for (final WorkspaceFolder folder in folders) ...<Widget>[
                          _folderTile(folder.id, folder.name),
                          for (final WorkspaceFolder child in folder.children)
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: _folderTile(child.id, child.name),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text('Recent note', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: WatchDrop<List<NoteItem>, List<NoteItem>>(
                  source: module.filteredNotes,
                  select: (List<NoteItem> value) => value,
                  builder: (BuildContext context, List<NoteItem> notes, Widget? child) {
                    return ListView(
                      children: notes
                          .map(
                            (NoteItem note) => GestureDetector(
                              onTap: () => module.selectNote(note.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: note.id == module.selectedNoteId.value
                                      ? const Color(0xFFE8F7FF)
                                      : const Color(0xFFF7F8FB),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(note.preview, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _folderTile(String id, String label) {
    return WatchDrop<String, String>(
      source: module.selectedFolderId,
      select: (String selected) => selected,
      builder: (BuildContext context, String selected, Widget? child) {
        final bool active = selected == id;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.folder, color: active ? const Color(0xFF79CFFF) : Colors.grey),
          title: Text(label, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
          onTap: () => module.selectFolder(id),
        );
      },
    );
  }

  Widget _editorScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Icon(Icons.arrow_back_ios_new, size: 16),
            SizedBox(width: 8),
            Text('Back', style: TextStyle(color: Colors.grey)),
            Spacer(),
            Icon(Icons.more_vert),
          ],
        ),
        const SizedBox(height: 12),
        WatchDrop<NoteItem?, NoteItem?>(
          source: module.selectedNote,
          select: (NoteItem? value) => value,
          builder: (BuildContext context, NoteItem? note, Widget? child) {
            return Text(
              note?.title ?? 'No selected note',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.1),
            );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: editorController,
            maxLines: null,
            expands: true,
            style: const TextStyle(height: 1.4),
            onChanged: module.updateEditor,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('Keyboard dock (editor state demo)')),
        ),
      ],
    );
  }

  Widget _reminderScreen() {
    return WatchDrop<ReminderConfig, ReminderConfig>(
      source: module.reminder,
      select: (ReminderConfig value) => value,
      builder: (BuildContext context, ReminderConfig reminder, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Text('Add reminder', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                Spacer(),
                Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Select Date & Time', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Text('February 2023', style: TextStyle(fontWeight: FontWeight.w700)),
                      Row(children: <Widget>[Icon(Icons.chevron_left), Icon(Icons.chevron_right)]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(12, (int index) {
                      final int day = index + 8;
                      final bool selected = day == reminder.date.day;
                      return GestureDetector(
                        onTap: () => module.changeReminderDay(day),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF8BD5FF) : Colors.white,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Center(child: Text('$day')),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Time for the reminding', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(child: _timeChip(reminder.primaryTime)),
                const SizedBox(width: 8),
                Expanded(child: _timeChip(reminder.secondaryTime)),
              ],
            ),
            const Spacer(),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(color: Color(0xFF0E1730), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _timeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF4F5F8), borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(label)),
    );
  }
}
