import 'models.dart';

abstract interface class NotesRepository {
  List<WorkspaceFolder> getFolders();
  List<NoteItem> getNotes();
}
