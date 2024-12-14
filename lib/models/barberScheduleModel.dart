class BarberSchedule {
  final int barberId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  BarberSchedule({
    required this.barberId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // Factory method untuk membuat BarberSchedule dari JSON
  factory BarberSchedule.fromJson(Map<String, dynamic> json) {
    return BarberSchedule(
      barberId: json['barber_id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  // Method untuk mengonversi BarberSchedule ke JSON
  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}