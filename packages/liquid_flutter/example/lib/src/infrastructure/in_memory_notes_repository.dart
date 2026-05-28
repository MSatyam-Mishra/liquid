import '../domain/models.dart';
import '../domain/notes_repository.dart';

class InMemoryNotesRepository implements NotesRepository {
  @override
  List<WorkspaceFolder> getFolders() {
    return const <WorkspaceFolder>[
      WorkspaceFolder(
        id: 'homework',
        name: 'Homework',
        children: <WorkspaceFolder>[
          WorkspaceFolder(id: 'math', name: 'Math'),
          WorkspaceFolder(id: 'science', name: 'Science'),
        ],
      ),
      WorkspaceFolder(id: 'workout', name: 'Workout'),
      WorkspaceFolder(
        id: 'sports',
        name: 'Sports',
        children: <WorkspaceFolder>[
          WorkspaceFolder(id: 'football', name: 'Football'),
        ],
      ),
    ];
  }

  @override
  List<NoteItem> getNotes() {
    return const <NoteItem>[
      NoteItem(
        id: 'voice',
        folderId: 'homework',
        title: 'Voice note',
        preview: 'A quick update from class discussion.',
        content: 'Voice note transcript goes here.',
      ),
      NoteItem(
        id: 'vacation',
        folderId: 'workout',
        title: 'List plans for the next vacation.',
        preview: 'Explore vibrant local markets and try exotic foods.',
        content: '1. Explore vibrant local markets to immerse in the culture and try exotic foods.\n'
            '2. Embark on a thrilling outdoor adventure, perhaps hiking in picturesque landscapes.\n'
            '3. Relax and rejuvenate at a luxurious spa to complete the trip.',
      ),
      NoteItem(
        id: 'grocery',
        folderId: 'sports',
        title: 'Grocery lists',
        preview: 'Apple, French coconut, spicy clove and more.',
        content: '- Apple\n- French coconut\n- Spicy clove\n- Campari tomato\n- Vegetables',
      ),
    ];
  }
}
