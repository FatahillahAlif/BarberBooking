class Booking {
  final int id;
  final int userId;
  final int barberId;
  final int serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String status;
  final User user;
  final Barber barber;
  final Service service;

  Booking({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.user,
    required this.barber,
    required this.service,
  });

  // Factory constructor untuk parsing dari JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      barberId: json['barber_id'],
      serviceId: json['service_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      bookingTime: json['booking_time'],
      status: json['status'],
      user: User.fromJson(json['user']),
      barber: Barber.fromJson(json['barber']),
      service: Service.fromJson(json['service']),
    );
  }

  // Fungsi copy untuk update state booking
  Booking copyWith({
    int? id,
    int? userId,
    int? barberId,
    int? serviceId,
    DateTime? bookingDate,
    String? bookingTime,
    String? status,
    User? user,
    Barber? barber,
    Service? service,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      user: user ?? this.user,
      barber: barber ?? this.barber,
      service: service ?? this.service,
    );
  }
}

class User {
  final String fullName;
  final String email;

  User({
    required this.fullName,
    required this.email,
  });

  // Factory constructor untuk parsing dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'],
      email: json['email'],
    );
  }
}

class Barber {
  final String name;

  Barber({required this.name});

  // Factory constructor untuk parsing dari JSON
  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      name: json['name'],
    );
  }
}

class Service {
  final String name;
  final String price;

  Service({
    required this.name,
    required this.price,
  });

  // Factory constructor untuk parsing dari JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'],
      price: json['price'],
    );
  }
}
