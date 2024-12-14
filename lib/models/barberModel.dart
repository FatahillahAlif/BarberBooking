class Barber {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String position;
  final List<BarberSchedule> schedules;

  Barber({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.position,
    required this.schedules,
  });

  // Factory method untuk membuat Barber dari JSON
  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      position: json['position'] ?? '',
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((schedule) => BarberSchedule.fromJson(schedule))
              .toList() ??
          [],
    );
  }

  // Method untuk mengonversi Barber ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'position': position,
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
    };
  }
}

class BarberSchedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  BarberSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // Factory method untuk membuat BarberSchedule dari JSON
  factory BarberSchedule.fromJson(Map<String, dynamic> json) {
    return BarberSchedule(
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  // Method untuk mengonversi BarberSchedule ke JSON
  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}