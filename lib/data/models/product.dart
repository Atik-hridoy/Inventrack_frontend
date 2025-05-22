class Product {
  final int id;
  final String name;
  final int quantity;

  Product({required this.id, required this.name, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}
