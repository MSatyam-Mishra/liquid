class WorkspaceFolder {
  const WorkspaceFolder({
    required this.id,
    required this.name,
    this.children = const <WorkspaceFolder>[],
  });

  final String id;
  final String name;
  final List<WorkspaceFolder> children;
}

class NoteItem {
  const NoteItem({
    required this.id,
    required this.folderId,
    required this.title,
    required this.preview,
    required this.content,
  });

  final String id;
  final String folderId;
  final String title;
  final String preview;
  final String content;
}

class ReminderConfig {
  const ReminderConfig({
    required this.date,
    required this.primaryTime,
    required this.secondaryTime,
  });

  final DateTime date;
  final String primaryTime;
  final String secondaryTime;

  ReminderConfig copyWith({
    DateTime? date,
    String? primaryTime,
    String? secondaryTime,
  }) {
    return ReminderConfig(
      date: date ?? this.date,
      primaryTime: primaryTime ?? this.primaryTime,
      secondaryTime: secondaryTime ?? this.secondaryTime,
    );
  }
}
