class Service {
  final int id;
  final String name;
  final String description;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  // Factory method untuk membuat Service dari JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  // Method untuk mengonversi Service ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}