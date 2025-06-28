import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';
import 'dart:async'; // For StreamSubscription

import 'package:e_commerce/data/services/firebase_auth_service.dart'; // New: Auth Service

/// ViewModel for the user's order history screen.
/// Displays orders made by the current authenticated buyer.
class OrderListViewModel extends ChangeNotifier {
  final OrderItemRepo _orderRepository;
  final FirebaseAuthService _firebaseAuthService; // New: Auth Service Field

  List<OrderItem> _orders = [];
  List<OrderItem> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<firebase_auth.User?>?
  _userAuthSubscription; // New: Auth state listener
  StreamSubscription<List<OrderItem>>?
  _ordersStreamSubscription; // New: Orders stream listener

  OrderListViewModel(this._orderRepository, this._firebaseAuthService) {
    appLogger.d(
      'OrderListViewModel: Constructor called. Initializing auth listener.',
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
          'OrderListViewModel: Auth state changed - User logged IN: ${user.uid}',
        );
        // User logged in, set up subscription for their orders
        _listenToOrders(user.uid);
      } else {
        appLogger.d(
          'OrderListViewModel: Auth state changed - User logged OUT. Clearing order data and cancelling subscription.',
        );
        // User logged out, clear current data and cancel all subscriptions
        _orders = [];
        _isLoading = false;
        _errorMessage = null;

        _ordersStreamSubscription?.cancel(); // Cancel any existing order stream
        _ordersStreamSubscription = null; // Clear subscription reference

        notifyListeners();
      }
    });

    // Perform an initial check in case a user is already logged in when the VM is created
    final initialUser = _firebaseAuthService.currentUser;
    if (initialUser != null) {
      appLogger.d(
        'OrderListViewModel: Initial check - User already logged in: ${initialUser.uid}. Fetching data.',
      );
      _listenToOrders(initialUser.uid);
    } else {
      appLogger.d('OrderListViewModel: Initial check - No user logged in.');
      _isLoading = false;
      _errorMessage = 'No authenticated user. Orders not loaded.';
      notifyListeners();
    }
  }

  /// Starts listening to real-time order changes for the given buyer.
  void _listenToOrders(String buyerId) {
    _ordersStreamSubscription?.cancel(); // Cancel previous subscription if any
    appLogger.d(
      'OrderListViewModel: Subscribing to orders for buyerId: $buyerId',
    );

    _ordersStreamSubscription = _orderRepository
        .getOrdersByBuyer(buyerId)
        .listen(
          (orders) {
            _orders = orders;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
            appLogger.d(
              'OrderListViewModel: Orders updated. Total: ${orders.length}',
            );
          },
          onError: (error, stack) {
            _isLoading = false;
            _errorMessage = 'Failed to load orders: ${error.toString()}';
            notifyListeners();
            appLogger.e(
              'OrderListViewModel: Error fetching orders stream for $buyerId: $error',
              error: error,
              stackTrace: stack,
            );
          },
        );
  }

  // You could add methods here for:
  // - Filtering orders by status
  // - Reordering
  // - Cancelling an order (requires a use case)

  @override
  void dispose() {
    appLogger.d(
      'OrderListViewModel: dispose() called. Cancelling all subscriptions.',
    );
    _userAuthSubscription?.cancel();
    _ordersStreamSubscription?.cancel();
    super.dispose();
  }
}
