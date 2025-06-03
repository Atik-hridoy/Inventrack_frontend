class Product {
  final int id;
  final String name;
  final String sku;
  final String description;
  final int quantity;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.price,
    this.image = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        sku: json['sku'],
        description: json['description'] ?? '',
        quantity: json['quantity'] ?? 0,
        price: _parsePrice(json['price']),
        image: json['image'] ?? '',
      );

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'description': description,
        'quantity': quantity,
        'price': price,
        'image': image,
      };

  @override
  String toString() {
    return 'Product{id: $id, name: $name, sku: $sku, description: $description, quantity: $quantity, price: $price, image: $image}';
  }
}
