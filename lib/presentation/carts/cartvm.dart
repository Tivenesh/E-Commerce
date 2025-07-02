import 'package:e_commerce/data/models/cart.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/data/usecases/orders/place_order_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';
import 'dart:async';
import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/firebase_auth_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// ViewModel for the user's shopping cart screen.
class CartViewModel extends ChangeNotifier {
  final CartRepo _cartRepository;
  final ItemRepo _itemRepository;
  final PlaceOrderUseCase _placeOrderUseCase;
  final UserRepo _userRepository;
  final FirebaseAuthService _firebaseAuthService;

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userAddress;
  String? get userAddress => _userAddress;

  double get subtotal => _cartItems.fold(
    0.0,
        (sum, item) => sum + (item.quantity * item.itemPrice),
  );

  StreamSubscription<firebase_auth.User?>? _userAuthSubscription;
  StreamSubscription<List<CartItem>>? _cartItemsSubscription;
  StreamSubscription<User?>? _userProfileSubscription;

  CartViewModel(
      this._cartRepository,
      this._itemRepository,
      this._placeOrderUseCase,
      this._userRepository,
      this._firebaseAuthService,
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
        _listenToCartChanges(user.uid);
        _listenToUserChanges(user.uid);
      } else {
        appLogger.d(
          'CartViewModel: Auth state changed - User logged OUT. Clearing cart data and cancelling subscriptions.',
        );
        _cartItems = [];
        _userAddress = null;
        _isLoading = false;
        _errorMessage = null;
        _cartItemsSubscription?.cancel();
        _userProfileSubscription?.cancel();
        _cartItemsSubscription = null;
        _userProfileSubscription = null;
        notifyListeners();
      }
    });

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

  void _listenToCartChanges(String userId) {
    _cartItemsSubscription?.cancel();
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

  void _listenToUserChanges(String userId) {
    _userProfileSubscription?.cancel();
    appLogger.d(
      'CartViewModel: Subscribing to user profile changes for userId: $userId',
    );
    _userProfileSubscription = _userRepository
        .getUserStream(userId)
        .listen(
          (user) {
        if (user != null) {
          if (_userAddress != user.address) {
            _userAddress = user.address;
            appLogger.i(
              'CartViewModel: User address updated to: ${user.address}',
            );
            notifyListeners();
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

  Future<bool> processPaymentAndPlaceOrder(String deliveryAddress, String? deliveryInstructions) async {
    if (subtotal <= 0) {
      _errorMessage = "Cannot checkout with an empty cart.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create Payment Intent on the backend
      final amountInCents = (subtotal * 100).round();
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
      final response = await callable.call<Map<String, dynamic>>({'amount': amountInCents});
      final clientSecret = response.data['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Failed to get payment client secret from server.');
      }

      // 2. Initialize and Present Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LokaLaku E-Commerce',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 3. If payment is successful, place the order in Firestore
      await placeOrder(deliveryAddress, deliveryInstructions: deliveryInstructions);

      _isLoading = false;
      notifyListeners();
      return true;

    } on StripeException catch (e) {
      _errorMessage = 'Payment failed: ${e.error.localizedMessage}';
      appLogger.e("Stripe Error: ${e.toString()}");
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      appLogger.e("Payment Flow Error: ${e.toString()}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    final String? userId = _firebaseAuthService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated. Cannot update cart item.';
      notifyListeners();
      return;
    }
    if (newQuantity <= 0) {
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
        userId,
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

  Future<void> removeCartItem(String itemId) async {
    final String? userId = _firebaseAuthService.currentUser?.uid;
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
      );
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

  Future<OrderItem?> placeOrder(
      String deliveryAddress, {
        String? deliveryInstructions,
      }) async {
    final String? userId = _firebaseAuthService.currentUser?.uid;
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
        userId,
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