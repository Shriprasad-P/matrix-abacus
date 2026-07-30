class Certificate {
  const Certificate({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
    this.earnedDate,
    this.childId,
  });

  final String id;
  final String title;
  final String description;
  final bool earned;
  final DateTime? earnedDate;
  final String? childId;
}
