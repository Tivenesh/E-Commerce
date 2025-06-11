import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';

/// ViewModel for the user's order history screen.
/// Displays orders made by the current authenticated buyer.
class OrderListViewModel extends ChangeNotifier {
  final OrderItemRepo _orderRepository;

  List<OrderItem> _orders = [];
  List<OrderItem> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentUserId; // Authenticated user's ID

  OrderListViewModel(this._orderRepository) {
    _currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _listenToOrders(_currentUserId!);
    } else {
      _errorMessage = 'User not authenticated. Cannot load orders.';
      notifyListeners();
      appLogger.w('OrderListViewModel: No authenticated user to load orders.');
    }
  }

  /// Starts listening to real-time order changes for the given buyer.
  void _listenToOrders(String buyerId) {
    _isLoading = true;
    notifyListeners();

    _orderRepository
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
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load orders: ${error.toString()}';
            notifyListeners();
            appLogger.e(
              'OrderListViewModel: Error fetching orders stream: $error',
              error: error,
            );
          },
        );
  }

  // You could add methods here for:
  // - Filtering orders by status
  // - Reordering
  // - Cancelling an order (requires a use case)
}
