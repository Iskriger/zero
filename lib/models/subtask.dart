/// Модель подзадачи. Сериализуется вручную в JSON (см. репозиторий).
class Subtask {
  final String title;
  bool isCompleted;

  Subtask({
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'isCompleted': isCompleted,
      };

  factory Subtask.fromMap(Map<String, dynamic> map) => Subtask(
        title: map['title'] as String? ?? '',
        isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      );
}
