/// Модель подзадачи. Сериализуется вручную в JSON (см. репозиторий).
class Subtask {
  final String title;
  bool isCompleted;

  Subtask({
    required this.title,
    this.isCompleted = false,
  });
}
