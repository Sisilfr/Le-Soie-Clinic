class RoutineItem {
  final String id;
  String name;
  String duration; // e.g. "60s"
  bool isDone;

  RoutineItem({
    required this.id,
    required this.name,
    required this.duration,
    this.isDone = false,
  });
}
