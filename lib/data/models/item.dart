class Item {
  final String id; // Optional: Firestore doc ID (for updates/fetching)
  final String name;
  final String description;
  final int quantity;
  final String pic; // string identifier/url for now
  final double price;

  Item({
    this.id = '',
    required this.name,
    required this.description,
    required this.quantity,
    required this.pic,
    required this.price,
  });

  // Convert Item instance to Map<String, dynamic> for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'pic': pic,
      'price': price,
    };
  }

  // Factory constructor to create an Item from Firestore document snapshot
  factory Item.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      pic: map['pic'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
    );
  }
}
