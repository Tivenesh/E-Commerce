
import 'package:cloud_firestore/cloud_firestore.dart';
/// Represents an Item available for sale, which can be a product or a service.

// Helper enum for Item type
enum ItemType {
  product,
  service,
}


class Item {
  final String id;
  final String sellerId; // ID of the user selling this item
  final String name;
  final String description;
  final double price;
  final ItemType type; // 'product' or 'service'
  final int? quantity; // For products (e.g., number of units in stock)
  final String? duration; // For services (e.g., '1 hour', '30 mins')
  final String category;
  final List<String> imageUrls; // List of image URLs
  final Timestamp listedAt;
  final Timestamp updatedAt;

  Item({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.quantity,
    this.duration,
    required this.category,
    this.imageUrls = const [],
    required this.listedAt,
    required this.updatedAt,
  }) : assert(
            (type == ItemType.product && quantity != null && quantity >= 0) ||
                (type == ItemType.service && duration != null),
            'Products must have a quantity; Services must have a duration');

  /// Converts an Item object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last, // Store as string 'product' or 'service'
      'quantity': quantity,
      'duration': duration,
      'category': category,
      'imageUrls': imageUrls,
      'listedAt': listedAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates an Item object from a Firestore DocumentSnapshot.
  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      type: (data['type'] == 'service') ? ItemType.service : ItemType.product,
      quantity: data['quantity'] as int?,
      duration: data['duration'] as String?,
      category: data['category'] ?? 'Uncategorized',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      listedAt: data['listedAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}
