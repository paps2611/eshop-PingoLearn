class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;
  final double discountPercentage;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.discountPercentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['images'][0],
      price: json['price'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
    );
  }
}
