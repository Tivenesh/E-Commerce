// cartvm.dart
import 'package:e_commerce/data/models/cart.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart'; // THIS IMPORT IS CRUCIAL
import 'package:e_commerce/data/usecases/orders/place_order_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';
import 'dart:async'; // For StreamSubscription
import 'package:e_commerce/data/models/user.dart'; // Import your User model

import 'package:e_commerce/data/services/firebase_auth_service.dart'; // New: Auth Service

/// ViewModel for the user's shopping cart screen.
/// Manages cart items, quantities, total calculation, and placing orders.
class CartViewModel extends ChangeNotifier {
  final CartRepo _cartRepository;
  final ItemRepo _itemRepository;
  final PlaceOrderUseCase _placeOrderUseCase;
  final UserRepo _userRepository; // THIS FIELD IS CRUCIAL
  final FirebaseAuthService _firebaseAuthService; // New: Auth Service Field

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userAddress; // THIS FIELD IS CRUCIAL
  String? get userAddress => _userAddress; // THIS GETTER IS CRUCIAL

  double get subtotal => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.quantity * item.itemPrice),
  );

  StreamSubscription<firebase_auth.User?>?
  _userAuthSubscription; // New: Auth state listener
  StreamSubscription<List<CartItem>>?
  _cartItemsSubscription; // New: Cart stream listener
  StreamSubscription<User?>?
  _userProfileSubscription; // New: User profile stream listener

  CartViewModel(
    this._cartRepository,
    this._itemRepository,
    this._placeOrderUseCase,
    this._userRepository, // UserRepo MUST be injected here
    this._firebaseAuthService, // New: FirebaseAuthService MUST be injected here
  ) {
    appLogger.d(
      'CartViewModel: Constructor called. Initializing auth listener.',
    );
    _initAuthListener();
  }

  void _initAuthListener() {
    _isLoading = true;
    notifyListeners();

    _userAuthSubscription = _firebaseAuthService.authStateChanges.listen((
      firebase_auth.User? user,
    ) {
      if (user != null) {
        appLogger.d(
          'CartViewModel: Auth state changed - User logged IN: ${user.uid}',
        );
        // User logged in, set up subscriptions for their data
        _listenToCartChanges(user.uid);
        _listenToUserChanges(user.uid);
      } else {
        appLogger.d(
          'CartViewModel: Auth state changed - User logged OUT. Clearing cart data and cancelling subscriptions.',
        );
        // User logged out, clear current data and cancel all subscriptions
        _cartItems = [];
        _userAddress = null;
        _isLoading = false;
        _errorMessage = null;

        _cartItemsSubscription?.cancel();
        _userProfileSubscription?.cancel();
        _cartItemsSubscription = null; // Clear subscription reference
        _userProfileSubscription = null; // Clear subscription reference

        notifyListeners();
      }
    });

    // Perform an initial check in case a user is already logged in when the VM is created
    final initialUser = _firebaseAuthService.currentUser;
    if (initialUser != null) {
      appLogger.d(
        'CartViewModel: Initial check - User already logged in: ${initialUser.uid}. Fetching data.',
      );
      _listenToCartChanges(initialUser.uid);
      _listenToUserChanges(initialUser.uid);
    } else {
      appLogger.d('CartViewModel: Initial check - No user logged in.');
      _isLoading = false;
      _errorMessage = 'No authenticated user. Cart and user info not loaded.';
      notifyListeners();
    }
  }

  /// Starts listening to real-time cart changes for the given user.
  void _listenToCartChanges(String userId) {
    _cartItemsSubscription?.cancel(); // Cancel previous subscription if any
    appLogger.d(
      'CartViewModel: Subscribing to cart changes for userId: $userId',
    );

    _cartItemsSubscription = _cartRepository
        .getCartItems(userId)
        .listen(
          (items) async {
            _cartItems = items;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
            appLogger.d(
              'CartViewModel: Cart items updated. Total: ${items.length}',
            );
          },
          onError: (error, stack) {
            _isLoading = false;
            _errorMessage = 'Failed to load cart: ${error.toString()}';
            notifyListeners();
            appLogger.e(
              'CartViewModel: Error fetching cart stream for $userId: $error',
              error: error,
              stackTrace: stack,
            );
          },
        );
  }

  // THIS METHOD IS CRUCIAL FOR FETCHING ADDRESS
  void _listenToUserChanges(String userId) {
    _userProfileSubscription?.cancel(); // Cancel previous subscription if any
    appLogger.d(
      'CartViewModel: Subscribing to user profile changes for userId: $userId',
    );

    _userProfileSubscription = _userRepository
        .getUserStream(userId)
        .listen(
          (user) {
            if (user != null) {
              if (_userAddress != user.address) {
                // Only update if changed
                _userAddress = user.address;
                appLogger.i(
                  'CartViewModel: User address updated to: ${user.address}',
                );
                notifyListeners(); // Notify listeners if address changes
              }
            } else {
              _userAddress = null;
              appLogger.w('CartViewModel: User document not found for $userId');
              notifyListeners();
            }
          },
          onError: (error, stack) {
            appLogger.e(
              'CartViewModel: Error fetching user stream for $userId: $error',
              error: error,
              stackTrace: stack,
            );
            _errorMessage = 'Failed to load user address: ${error.toString()}';
            notifyListeners();
          },
        );
  }

  /// Updates the quantity of a specific item in the cart.
  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    final String? userId =
        _firebaseAuthService.currentUser?.uid; // Use current user ID
    if (userId == null) {
      _errorMessage = 'User not authenticated. Cannot update cart item.';
      notifyListeners();
      return;
    }

    if (newQuantity <= 0) {
      // If quantity is 0 or less, remove the item
      await removeCartItem(itemId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingItem = _cartItems.firstWhere(
        (item) => item.itemId == itemId,
      );
      final updatedCartItem = existingItem.copyWith(quantity: newQuantity);
      await _cartRepository.addOrUpdateCartItem(
        userId, // Use current user ID
        updatedCartItem,
      );
      _isLoading = false;
      notifyListeners();
      appLogger.i(
        'CartViewModel: Updated quantity for item $itemId to $newQuantity.',
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update item quantity: ${e.toString()}';
      notifyListeners();
      appLogger.e(
        'CartViewModel: Error updating cart item quantity: $e',
        error: e,
      );
    }
  }

  /// Removes an item from the cart.
  Future<void> removeCartItem(String itemId) async {
    final String? userId =
        _firebaseAuthService.currentUser?.uid; // Use current user ID
    if (userId == null) {
      _errorMessage = 'User not authenticated. Cannot remove cart item.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cartRepository.removeCartItem(
        userId,
        itemId,
      ); // Use current user ID
      _isLoading = false;
      notifyListeners();
      appLogger.i('CartViewModel: Removed item $itemId from cart.');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to remove item from cart: ${e.toString()}';
      notifyListeners();
      appLogger.e('CartViewModel: Error removing cart item: $e', error: e);
    }
  }

  /// Places an order from the current cart.
  Future<OrderItem?> placeOrder(
    String deliveryAddress, {
    String? deliveryInstructions,
  }) async {
    final String? userId =
        _firebaseAuthService.currentUser?.uid; // Use current user ID
    if (userId == null) {
      _errorMessage = 'User not authenticated. Cannot place order.';
      notifyListeners();
      return null;
    }
    if (_cartItems.isEmpty) {
      _errorMessage =
          'Your cart is empty. Please add items before placing an order.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOrder = await _placeOrderUseCase(
        userId, // Use current user ID
        deliveryAddress,
        deliveryInstructions: deliveryInstructions,
      );
      _isLoading = false;
      notifyListeners();
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

  @override
  void dispose() {
    appLogger.d(
      'CartViewModel: dispose() called. Cancelling all subscriptions.',
    );
    _userAuthSubscription?.cancel();
    _cartItemsSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
