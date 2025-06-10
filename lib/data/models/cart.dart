/// Represents an item within a user's shopping cart.
class CartItem {
  final String itemId; // Reference to the Item document
  final int quantity; // Quantity of this specific item in the cart
  final double itemPrice; // Price of the item at the time it was added to cart
  final String itemName; // Name of the item
  final String? itemImageUrl; // Image of the item

  CartItem({
    required this.itemId,
    required this.quantity,
    required this.itemPrice,
    required this.itemName,
    this.itemImageUrl,
  });

  /// Converts a CartItem object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
      'itemPrice': itemPrice,
      'itemName': itemName,
      'itemImageUrl': itemImageUrl,
    };
  }

  /// Creates a CartItem object from a JSON map (typically from an Order's item list).
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] ?? '',
      quantity: json['quantity'] ?? 1,
      itemPrice: (json['itemPrice'] as num?)?.toDouble() ?? 0.0,
      itemName: json['itemName'] ?? '',
      itemImageUrl: json['itemImageUrl'],
    );
  }
}
