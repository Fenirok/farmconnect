class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String farmerId;
  final String farmerName;
  final double weight;
  final String unit; // kg, g, piece, etc.
  final bool isOrganic;
  final String location;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.farmerId,
    required this.farmerName,
    required this.weight,
    required this.unit,
    this.isOrganic = false,
    this.location = 'Unknown',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      weight: json['weight'].toDouble(),
      unit: json['unit'],
      isOrganic: json['isOrganic'] ?? false,
      location: json['location'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'weight': weight,
      'unit': unit,
      'isOrganic': isOrganic,
      'location': location,
    };
  }
}
