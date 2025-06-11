import 'package:e_commerce/data/models/cart.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/usecases/orders/place_order_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';

/// ViewModel for the user's shopping cart screen.
/// Manages cart items, quantities, total calculation, and placing orders.
class CartViewModel extends ChangeNotifier {
  final CartRepo _cartRepository;
  final ItemRepo _itemRepository; // Used for fetching item details if needed
  final PlaceOrderUseCase _placeOrderUseCase;

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + (item.quantity * item.itemPrice));

  String? _currentUserId; // Authenticated user's ID

  CartViewModel(this._cartRepository, this._itemRepository, this._placeOrderUseCase) {
    _currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _listenToCartChanges(_currentUserId!);
    } else {
      _errorMessage = 'User not authenticated. Cannot load cart.';
      notifyListeners();
      appLogger.w('CartViewModel: No authenticated user to load cart.');
    }
  }

  /// Starts listening to real-time cart changes for the given user.
  void _listenToCartChanges(String userId) {
    _isLoading = true;
    notifyListeners();

    _cartRepository.getCartItems(userId).listen((items) async {
      // Potentially fetch updated item details for display if CartItem doesn't hold all
      // For now, assuming CartItem has enough detail, but this is where you'd enrich it.
      _cartItems = items;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      appLogger.d('CartViewModel: Cart items updated. Total: ${items.length}');
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load cart: ${error.toString()}';
      notifyListeners();
      appLogger.e('CartViewModel: Error fetching cart stream: $error', error: error);
    });
  }

  /// Updates the quantity of a specific item in the cart.
  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    if (_currentUserId == null) return;
    if (newQuantity <= 0) {
      // If quantity is 0 or less, remove the item
      await removeCartItem(itemId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingItem = _cartItems.firstWhere((item) => item.itemId == itemId);
      final updatedCartItem = existingItem.copyWith(quantity: newQuantity);
      await _cartRepository.addOrUpdateCartItem(_currentUserId!, updatedCartItem); // Uses addOrUpdate for upsert
      _isLoading = false;
      notifyListeners(); // Will be triggered by stream
      appLogger.i('CartViewModel: Updated quantity for item $itemId to $newQuantity.');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update item quantity: ${e.toString()}';
      notifyListeners();
      appLogger.e('CartViewModel: Error updating cart item quantity: $e', error: e);
    }
  }

  /// Removes an item from the cart.
  Future<void> removeCartItem(String itemId) async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cartRepository.removeCartItem(_currentUserId!, itemId);
      _isLoading = false;
      notifyListeners(); // Will be triggered by stream
      appLogger.i('CartViewModel: Removed item $itemId from cart.');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to remove item from cart: ${e.toString()}';
      notifyListeners();
      appLogger.e('CartViewModel: Error removing cart item: $e', error: e);
    }
  }

  /// Places an order from the current cart.
  Future<OrderItem?> placeOrder(String deliveryAddress, {String? deliveryInstructions}) async {
    if (_currentUserId == null) {
      _errorMessage = 'User not authenticated. Cannot place order.';
      notifyListeners();
      return null;
    }
    if (_cartItems.isEmpty) {
      _errorMessage = 'Your cart is empty. Please add items before placing an order.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOrder = await _placeOrderUseCase(
        _currentUserId!,
        deliveryAddress,
        deliveryInstructions: deliveryInstructions,
      );
      _isLoading = false;
      notifyListeners(); // Cart will be cleared and UI will update
      appLogger.i('CartViewModel: Order placed successfully: ${newOrder.id}');
      return newOrder;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to place order: ${e.toString()}';
      notifyListeners();
      appLogger.e('CartViewModel: Error placing order: $e', error: e);
      return null;
    }
  }


}
