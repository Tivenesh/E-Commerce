import 'package:e_commerce/data/models/cart.dart';
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:uuid/uuid.dart'; // Ensure you have this in pubspec.yaml
import 'package:cloud_firestore/cloud_firestore.dart'
    as firestore; // Alias for Timestamp

import 'package:e_commerce/utils/logger.dart';

/// A complex use case that orchestrates the process of placing an order.
/// It interacts with multiple repositories to:
/// 1. Fetch current cart items.
/// 2. Validate stock (for products).
/// 3. Create an order document.
/// 4. Clear the user's cart.
/// 5. Update item quantities (decrement stock).
class PlaceOrderUseCase {
  final CartRepo _cartRepository;
  final OrderItemRepo _orderRepository;
  final ItemRepo _itemRepository;
  final UserRepo
  _userRepository; // To get seller/buyer info for order (if needed)

  PlaceOrderUseCase(
    this._cartRepository,
    this._orderRepository,
    this._itemRepository,
    this._userRepository, // Injected for potential use, currently not directly used in the core logic below
  );

  /// Executes the order placement process.
  ///
  /// [buyerId]: The ID of the user placing the order.
  /// [deliveryAddress]: The address for delivery.
  /// [deliveryInstructions]: Optional instructions.
  Future<OrderItem> call(
    String buyerId,
    String deliveryAddress, {
    String? deliveryInstructions,
  }) async {
    try {
      // 1. Get current cart items for the buyer
      final cartItemsStream = _cartRepository.getCartItems(buyerId);
      final List<CartItem> cartItems =
          await cartItemsStream.first; // Get current state of cart

      if (cartItems.isEmpty) {
        appLogger.w(
          'PlaceOrderUseCase: Cart is empty for buyer $buyerId. Cannot place an order.',
        );
        throw Exception('Cart is empty. Cannot place an order.');
      }

      // Prepare for stock validation and total calculation
      double totalAmount = 0.0;
      String?
      sellerId; // Assuming all items in a single order are from one seller for simplicity
      final List<CartItem> confirmedOrderItems =
          []; // To store items with confirmed prices/details

      // Use a Firestore transaction for atomicity in a real application
      // (This specific pattern does separate updates, but for critical stock, use a transaction)
      // await firestore.FirebaseFirestore.instance.runTransaction((transaction) async { ... });

      // 2. Validate stock and confirm prices for all items in the cart
      for (final cartItem in cartItems) {
        final actualItem = await _itemRepository.getItemById(cartItem.itemId);

        if (actualItem == null) {
          appLogger.e(
            'PlaceOrderUseCase: Item ${cartItem.itemName} (ID: ${cartItem.itemId}) not found during order placement.',
          );
          throw Exception(
            'Item ${cartItem.itemName} not found. Please review your cart.',
          );
        }

        // For products, check stock
        if (actualItem.type == ItemType.product &&
            actualItem.quantity != null) {
          if (actualItem.quantity! < cartItem.quantity) {
            appLogger.w(
              'PlaceOrderUseCase: Insufficient stock for ${actualItem.name}. Available: ${actualItem.quantity}, Requested: ${cartItem.quantity}.',
            );
            throw Exception(
              'Not enough stock for ${actualItem.name}. Available: ${actualItem.quantity}.',
            );
          }
        }

        // Use the current price from the item master data (business decision)
        final confirmedPrice = actualItem.price;
        totalAmount += confirmedPrice * cartItem.quantity;

        confirmedOrderItems.add(
          CartItem(
            itemId: actualItem.id,
            itemName: actualItem.name,
            itemPrice: confirmedPrice,
            quantity: cartItem.quantity,
            itemImageUrl:
                actualItem.imageUrls.isNotEmpty
                    ? actualItem.imageUrls.first
                    : null,
          ),
        );

        // Assuming a single seller for the entire order
        if (sellerId == null) {
          sellerId = actualItem.sellerId;
        } else if (sellerId != actualItem.sellerId) {
          // If you want to support multiple sellers per order, this logic needs adjustment
          // For now, it assumes a single seller for simplicity
          appLogger.w(
            'PlaceOrderUseCase: Order contains items from multiple sellers. Using first seller ID.',
          );
        }
      }

      if (sellerId == null) {
        appLogger.e(
          'PlaceOrderUseCase: Could not determine seller for the order for buyer $buyerId. Cart might be malformed.',
        );
        throw Exception(
          'Could not determine seller for the order. Cart might be malformed.',
        );
      }

      // 3. Create the Order object
      final String orderId = const Uuid().v4();
      final newOrder = OrderItem(
        id: orderId,
        buyerId: buyerId,
        sellerId: sellerId,
        items: confirmedOrderItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending, // Initial status after placement
        deliveryAddress: deliveryAddress,
        deliveryInstructions: deliveryInstructions,
        orderDate: firestore.Timestamp.now(),
        estimatedDeliveryDate: firestore.Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 5)),
        ), // Example estimate
      );

      // 4. Save the order to the repository
      await _orderRepository.addOrder(newOrder);
      appLogger.i(
        'PlaceOrderUseCase: Order ${newOrder.id} created for buyer $buyerId.',
      );

      // 5. Decrement item quantities (only for products)
      for (final cartItem in cartItems) {
        final actualItem = await _itemRepository.getItemById(cartItem.itemId);
        if (actualItem != null &&
            actualItem.type == ItemType.product &&
            actualItem.quantity != null) {
          final updatedItem = actualItem.copyWith(
            quantity: actualItem.quantity! - cartItem.quantity,
            updatedAt: firestore.Timestamp.now(), // Update timestamp
          );
          await _itemRepository.updateItem(updatedItem);
          appLogger.d(
            'PlaceOrderUseCase: Decremented stock for ${actualItem.name} (ID: ${actualItem.id}) by ${cartItem.quantity}.',
          );
        }
      }

      // 6. Clear the user's cart after successful order placement
      await _cartRepository.clearCart(buyerId);
      appLogger.i(
        'PlaceOrderUseCase: Cart cleared for buyer $buyerId after successful order.',
      );

      return newOrder;
    } catch (e, stack) {
      appLogger.e(
        'PlaceOrderUseCase: Error placing order for buyer $buyerId: $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
