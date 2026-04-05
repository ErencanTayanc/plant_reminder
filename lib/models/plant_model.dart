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
      };

  int get daysSinceWatered => DateTime.now().difference(lastWatered).inDays;
  int get daysUntilWater => waterIntervalDays - daysSinceWatered;
  double get waterProgress =>
      (daysSinceWatered / waterIntervalDays).clamp(0.0, 1.0);

  WaterUrgency get urgency {
    if (daysUntilWater <= 0) return WaterUrgency.critical;
    if (daysUntilWater == 1) return WaterUrgency.soon;
    if (daysUntilWater <= 3) return WaterUrgency.upcoming;
    return WaterUrgency.ok;
  }

  String get statusLabel {
    if (daysUntilWater <= 0) return 'Water Now!';
    if (daysUntilWater == 1) return 'Tomorrow';
    return 'In $daysUntilWater days';
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
  }) =>
      Plant(
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
      );
}

enum WaterUrgency { critical, soon, upcoming, ok }
