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

//
//--------------------------------------------------------------------
// CartViewModel Class
//--------------------------------------------------------------------
// This class is the ViewModel for the shopping cart screen. It follows the
// MVVM (Model-View-ViewModel) architecture. Its main responsibilities are:
// - Managing the state of the shopping cart (items, totals).
// - Handling user interactions like updating quantities or removing items.
// - Orchestrating the entire checkout process, including payment.
// - Notifying the UI (the View) of any state changes so it can rebuild.
//

class CartViewModel extends ChangeNotifier {
  // --- Repositories and Use Cases (Dependencies) ---
  // These are the services and business logic units that the ViewModel depends on.
  // They are "injected" through the constructor for better testability and separation of concerns.
  final CartRepo _cartRepository;
  final ItemRepo _itemRepository;
  final PlaceOrderUseCase _placeOrderUseCase;
  final UserRepo _userRepository;
  final FirebaseAuthService _firebaseAuthService;

  // --- State Properties ---
  // These properties hold the current state of the cart page. The UI will listen
  // to changes in these properties and update itself.

  // The private list of items in the cart.
  List<CartItem> _cartItems = [];
  // The public getter for the list of cart items. The UI reads this.
  List<CartItem> get cartItems => _cartItems;

  // A flag to indicate if a long-running operation (like checkout) is in progress.
  bool _isLoading = false;
  // Public getter for the loading state.
  bool get isLoading => _isLoading;

  // A string to hold any error message that needs to be displayed to the user.
  String? _errorMessage;
  // Public getter for the error message.
  String? get errorMessage => _errorMessage;

  // A string to hold the user's pre-filled delivery address from their profile.
  String? _userAddress;
  // Public getter for the user's address.
  String? get userAddress => _userAddress;

  // --- Computed Properties ---
  // A getter that calculates the subtotal of all items in the cart on the fly.
  double get subtotal => _cartItems.fold(
    0.0,
        (sum, item) => sum + (item.quantity * item.itemPrice),
  );

  // --- Stream Subscriptions ---
  // These subscriptions are used to listen to real-time data changes from Firebase.
  // They must be cancelled when the ViewModel is disposed to prevent memory leaks.
  StreamSubscription<firebase_auth.User?>? _userAuthSubscription;
  StreamSubscription<List<CartItem>>? _cartItemsSubscription;
  StreamSubscription<User?>? _userProfileSubscription;

  /// The constructor for the ViewModel.
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
    // Start listening to authentication state changes as soon as the ViewModel is created.
    _initAuthListener();
  }

  /// Initializes a listener for Firebase authentication state changes.
  /// This is the entry point for loading all user-specific data.
  void _initAuthListener() {
    _isLoading = true;
    notifyListeners(); // Notify UI that we are starting to load data.

    _userAuthSubscription = _firebaseAuthService.authStateChanges.listen((
        firebase_auth.User? user,
        ) {
      // When the user logs in...
      if (user != null) {
        appLogger.d(
          'CartViewModel: Auth state changed - User logged IN: ${user.uid}',
        );
        // ...start listening to their cart items and profile information.
        _listenToCartChanges(user.uid);
        _listenToUserChanges(user.uid);
      }
      // When the user logs out...
      else {
        appLogger.d(
          'CartViewModel: Auth state changed - User logged OUT. Clearing cart data and cancelling subscriptions.',
        );
        // ...clear all local data and cancel any existing data streams.
        _cartItems = [];
        _userAddress = null;
        _isLoading = false;
        _errorMessage = null;
        _cartItemsSubscription?.cancel();
        _userProfileSubscription?.cancel();
        _cartItemsSubscription = null;
        _userProfileSubscription = null;
        notifyListeners(); // Notify the UI that all data has been cleared.
      }
    });

    // Check for an already logged-in user when the app starts.
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

  /// Subscribes to the real-time stream of cart items for a given user from Firestore.
  void _listenToCartChanges(String userId) {
    _cartItemsSubscription?.cancel(); // Cancel any old subscription first.
    appLogger.d(
      'CartViewModel: Subscribing to cart changes for userId: $userId',
    );
    _cartItemsSubscription = _cartRepository
        .getCartItems(userId)
        .listen(
          (items) async {
        // When new cart data arrives, update the local state.
        _cartItems = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners(); // Notify the UI to rebuild with the new cart items.
        appLogger.d(
          'CartViewModel: Cart items updated. Total: ${items.length}',
        );
      },
      // Handle any errors that occur on the stream.
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

  /// Subscribes to the real-time stream of the user's profile to get their address.
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
          // Only update and notify if the address has actually changed.
          if (_userAddress != user.address) {
            _userAddress = user.address;
            appLogger.i(
              'CartViewModel: User address updated to: ${user.address}',
            );
            notifyListeners();
          }
        } else {
          // Handle case where user profile might be deleted.
          _userAddress = null;
          appLogger.w('CartViewModel: User document not found for $userId');
          notifyListeners();
        }
      },
      onError: (error, stack) {
        _errorMessage = 'Failed to load user address: ${error.toString()}';
        notifyListeners();
        appLogger.e(
          'CartViewModel: Error fetching user stream for $userId: $error',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }

  /// The main function to handle the entire payment and order placement flow.
  Future<bool> processPaymentAndPlaceOrder(String deliveryAddress, String? deliveryInstructions) async {
    // Prevent checkout if the cart is empty.
    if (subtotal <= 0) {
      _errorMessage = "Cannot checkout with an empty cart.";
      notifyListeners();
      return false;
    }

    // Set loading state to true to show progress indicators in the UI.
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Call the backend Cloud Function to create a Stripe Payment Intent.
      // The amount must be in the smallest currency unit (e.g., cents, sen).
      final amountInCents = (subtotal * 100).round();
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
      final response = await callable.call<Map<String, dynamic>>({'amount': amountInCents});
      final clientSecret = response.data['clientSecret'];

      // If the backend fails to return a client secret, throw an exception.
      if (clientSecret == null) {
        throw Exception('Failed to get payment client secret from server.');
      }

      // Step 2: Initialize the Stripe payment sheet in the app with the client secret.
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LokaLaku E-Commerce', // Your store's name
        ),
      );
      // Present the payment sheet to the user. This will pause execution until the user completes or cancels the payment.
      await Stripe.instance.presentPaymentSheet();

      // Step 3: If presentPaymentSheet does not throw an error, the payment was successful.
      // Now, proceed to create the order document in Firestore.
      await placeOrder(deliveryAddress, deliveryInstructions: deliveryInstructions);

      // Reset loading state and return true for success.
      _isLoading = false;
      notifyListeners();
      return true;

    } on StripeException catch (e) {
      // Handle specific errors from the Stripe SDK (e.g., payment declined).
      _errorMessage = 'Payment failed: ${e.error.localizedMessage}';
      appLogger.e("Stripe Error: ${e.toString()}");
    } catch (e) {
      // Handle any other errors in the process (e.g., network issues).
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      appLogger.e("Payment Flow Error: ${e.toString()}");
    }

    // If any error occurred, reset loading state and return false for failure.
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Updates the quantity of a specific item in the user's cart.
  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    final String? userId = _firebaseAuthService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated. Cannot update cart item.';
      notifyListeners();
      return;
    }
    // If the new quantity is zero or less, remove the item instead.
    if (newQuantity <= 0) {
      await removeCartItem(itemId);
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Find the item in the local list to update its quantity.
      final existingItem = _cartItems.firstWhere(
            (item) => item.itemId == itemId,
      );
      final updatedCartItem = existingItem.copyWith(quantity: newQuantity);
      // Persist the change to Firestore.
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

  /// Removes an item completely from the user's cart.
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
      // Persist the deletion to Firestore.
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

  /// Creates an order document in Firestore after a successful payment.
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
      // Call the PlaceOrderUseCase to handle the complex logic of creating an order.
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
    // This method is called when the ViewModel is no longer needed.
    // It's crucial to cancel all stream subscriptions here to prevent memory leaks.
    appLogger.d(
      'CartViewModel: dispose() called. Cancelling all subscriptions.',
    );
    _userAuthSubscription?.cancel();
    _cartItemsSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}