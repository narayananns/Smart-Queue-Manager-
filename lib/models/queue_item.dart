enum QueueStatus { waiting, inProgress, completed }

class QueueItem {
  final String id;
  final String name;
  final String type; // e.g., "Physique", "Consultation"
  final DateTime joinedAt;
  QueueStatus status;

  QueueItem({
    required this.id,
    required this.name,
    required this.type,
    required this.joinedAt,
    this.status = QueueStatus.waiting,
  });

  // Mock data generator
  static List<QueueItem> generateMockData({int count = 10}) {
    return List.generate(
      count,
      (index) => QueueItem(
        id: 'Q-${100 + index}',
        name: 'Guest ${index + 1}',
        type: index % 2 == 0 ? 'General' : 'Priority',
        joinedAt: DateTime.now().add(Duration(minutes: index * 5)),
      ),
    );
  }
}
