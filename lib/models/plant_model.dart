class Plant {
  final int id;
  String name;
  String nickname;
  String emoji;
  String room;
  String light;
  int waterIntervalDays;
  DateTime lastWatered;
  String color;
  String? photoPath;
  double? waterAmountMl; // optional per-plant water amount in ml

  Plant({
    required this.id,
    required this.name,
    required this.nickname,
    required this.emoji,
    required this.room,
    required this.light,
    required this.waterIntervalDays,
    required this.lastWatered,
    this.color = '#2d6a4f',
    this.photoPath,
    this.waterAmountMl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as int,
    name: json['name'] as String,
    nickname: json['nickname'] as String,
    emoji: json['emoji'] as String,
    room: json['room'] as String,
    light: json['light'] as String,
    waterIntervalDays: json['waterIntervalDays'] as int,
    lastWatered: DateTime.parse(json['lastWatered'] as String),
    color: json['color'] as String? ?? '#2d6a4f',
    photoPath: json['photoPath'] as String?,
    waterAmountMl: (json['waterAmountMl'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nickname': nickname,
    'emoji': emoji,
    'room': room,
    'light': light,
    'waterIntervalDays': waterIntervalDays,
    'lastWatered': lastWatered.toIso8601String(),
    'color': color,
    'photoPath': photoPath,
    'waterAmountMl': waterAmountMl,
  };

  // ── Time helpers ──────────────────────────────────────────────────────────

  /// Exact date when next watering is due
  DateTime get nextWateringDate =>
      DateTime(lastWatered.year, lastWatered.month, lastWatered.day).add(Duration(days: waterIntervalDays));

  /// Hours elapsed since last watering (more precise than days)
  int get hoursSinceWatered => DateTime.now().difference(lastWatered).inHours;

  int get daysSinceWatered => DateTime.now().difference(lastWatered).inDays;

  /// Days remaining until next watering (can be negative = overdue)
  int get daysUntilWater {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return nextWateringDate.difference(today).inDays;
  }

  double get waterProgress => (daysSinceWatered / waterIntervalDays).clamp(0.0, 1.0);

  WaterUrgency get urgency {
    if (daysUntilWater <= 0) return WaterUrgency.critical;
    if (daysUntilWater == 1) return WaterUrgency.soon;
    if (daysUntilWater <= 3) return WaterUrgency.upcoming;
    return WaterUrgency.ok;
  }

  /// Short label for card badge
  String get statusLabel {
    if (daysUntilWater <= 0) return 'Water Now!';
    if (daysUntilWater == 1) return 'Tomorrow';
    return 'In $daysUntilWater days';
  }

  /// Human-readable "last watered" string
  String get lastWateredLabel {
    final hours = hoursSinceWatered;
    if (hours < 1) return 'Just now';
    if (hours < 24) return '${hours}h ago';
    final days = daysSinceWatered;
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  /// Human-readable next watering date
  String get nextWateringLabel {
    final d = daysUntilWater;
    if (d < 0) return 'Overdue by ${-d} day${-d == 1 ? '' : 's'}';
    if (d == 0) return 'Today';
    if (d == 1) return 'Tomorrow';
    // Show day name if within a week, otherwise show date
    if (d <= 6) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[nextWateringDate.weekday - 1];
    }
    return '${nextWateringDate.day}/${nextWateringDate.month}';
  }

  /// Water amount label respecting unit preference
  String waterAmountLabel(String unit) {
    if (waterAmountMl == null) return '—';
    if (unit == 'ml') return '${waterAmountMl!.toStringAsFixed(0)} ml';
    if (unit == 'oz') {
      final oz = waterAmountMl! / 29.5735;
      return '${oz.toStringAsFixed(1)} oz';
    }
    return '—';
  }

  Plant copyWith({
    String? name,
    String? nickname,
    String? emoji,
    String? room,
    String? light,
    int? waterIntervalDays,
    DateTime? lastWatered,
    String? color,
    String? photoPath,
    bool clearPhoto = false,
    double? waterAmountMl,
    bool clearWaterAmount = false,
  }) => Plant(
    id: id,
    name: name ?? this.name,
    nickname: nickname ?? this.nickname,
    emoji: emoji ?? this.emoji,
    room: room ?? this.room,
    light: light ?? this.light,
    waterIntervalDays: waterIntervalDays ?? this.waterIntervalDays,
    lastWatered: lastWatered ?? this.lastWatered,
    color: color ?? this.color,
    photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    waterAmountMl: clearWaterAmount ? null : (waterAmountMl ?? this.waterAmountMl),
  );
}

enum WaterUrgency { critical, soon, upcoming, ok }
