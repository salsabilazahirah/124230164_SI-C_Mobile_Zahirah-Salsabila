class Cake {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;
  final double rating;
  final int reviews;
  final String sweetness;
  final String size;
  final int servings;

  Cake({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.sweetness,
    required this.size,
    required this.servings,
  });

  factory Cake.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] ?? 0;
    return Cake(
      id: id,
      title: json['title'] ?? '',
      description:
          json['previewDescription'] ?? json['detailDescription'] ?? '',
      image: json['image'] ?? '',
      price: 15.0 + (id % 10) * 2.5, // Generate price based on ID
      rating: 4.0 + ((id % 5) * 0.2), // Generate rating 4.0-4.8
      reviews: 50 + (id % 20) * 10, // Generate reviews 50-240
      sweetness: id % 3 == 0
          ? 'Sweet'
          : id % 3 == 1
          ? 'Medium'
          : 'Light',
      size: id % 2 == 0 ? 'Large' : 'Medium',
      servings: 4 + (id % 4), // Generate servings 4-7
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'sweetness': sweetness,
      'size': size,
      'servings': servings,
    };
  }
}
