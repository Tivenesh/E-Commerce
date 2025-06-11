import 'package:e_commerce/data/models/cart.dart';
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // For Timestamp in Item model
import 'package:e_commerce/utils/logger.dart';

/// A use case that handles adding an item to a user's cart.
/// It interacts with the CartRepository and ItemRepository to ensure
/// business rules (e.g., checking item existence, price, quantity) are met.
class AddItemToCartUseCase {
  final CartRepo _cartRepository;
  final ItemRepo _itemRepository; // Dependency to get item details

  AddItemToCartUseCase(this._cartRepository, this._itemRepository);

  /// Executes the use case to add or update an item in the cart.
  ///
  /// [userId]: The ID of the user whose cart is being modified.
  /// [itemId]: The ID of the item to add.
  /// [quantity]: The quantity of the item to add.
  Future<void> call(String userId, String itemId, int quantity) async {
    if (quantity <= 0) {
      appLogger.e('AddItemToCartUseCase: Attempted to add 0 or negative quantity for item $itemId.');
      throw ArgumentError('Quantity must be greater than zero.');
    }

    try {
      // 1. Get item details to ensure it exists and to get its current price/name/image.
      final item = await _itemRepository.getItemById(itemId);
      if (item == null) {
        appLogger.w('AddItemToCartUseCase: Item $itemId not found.');
        throw Exception('Item not found.');
      }
      if (item.type == ItemType.product && item.quantity != null && item.quantity! < quantity) {
        appLogger.w('AddItemToCartUseCase: Not enough stock for ${item.name} (ID: ${item.id}). Available: ${item.quantity}. Requested: $quantity.');
        throw Exception('Not enough stock for ${item.name}. Available: ${item.quantity}.');
      }

      // 2. Create a CartItem based on fetched item details.
      final cartItem = CartItem(
        itemId: item.id,
        itemName: item.name,
        itemPrice: item.price, // Use current item price
        quantity: quantity,
        itemImageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
      );

      // 3. Add or update the cart item via the repository.
      await _cartRepository.addOrUpdateCartItem(userId, cartItem);
      appLogger.i('AddItemToCartUseCase: Item ${item.name} (ID: ${item.id}) added/updated to cart for user $userId with quantity $quantity.');

      // Optional: If you want to decrement stock immediately (consider transaction for robustness)
      // if (item.type == ItemType.product) {
      //   final updatedItem = item.copyWith(quantity: item.quantity! - quantity);
      //   await _itemRepository.updateItem(updatedItem);
      //   appLogger.d('AddItemToCartUseCase: Decremented stock for ${item.name} by $quantity.');
      // }

    } catch (e, stack) {
      appLogger.e('AddItemToCartUseCase: Error adding item to cart for user $userId, item $itemId: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
