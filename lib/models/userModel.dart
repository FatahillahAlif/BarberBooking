class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? token; // Menyimpan token sebagai atribut opsional

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.token, // Menambahkan parameter token (opsional)
  });

  // Factory method untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'], // Mengambil token dari JSON jika ada
    );
  }

  // Method untuk mengonversi User ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'token': token,
    };
  }
}