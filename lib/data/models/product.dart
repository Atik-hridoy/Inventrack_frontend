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
        quantity: json['quantity'],
        price: double.parse(json['price'].toString()),
        image: json['image'] ?? '',
      );
}
