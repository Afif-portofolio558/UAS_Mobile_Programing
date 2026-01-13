class Task {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        deadline: DateTime.parse(json['deadline']),
      );
}
