class Parent {
  const Parent({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.role = 'parent',
    this.notificationsEnabled = true,
    this.practiceReminders = true,
    this.announcementAlerts = true,
  });

  final String id;
  final String name;
  final String mobile;
  final String email;
  final String role;
  final bool notificationsEnabled;
  final bool practiceReminders;
  final bool announcementAlerts;

  Parent copyWith({
    String? name,
    String? mobile,
    String? email,
    String? role,
    bool? notificationsEnabled,
    bool? practiceReminders,
    bool? announcementAlerts,
  }) {
    return Parent(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      role: role ?? this.role,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      practiceReminders: practiceReminders ?? this.practiceReminders,
      announcementAlerts: announcementAlerts ?? this.announcementAlerts,
    );
  }
}
