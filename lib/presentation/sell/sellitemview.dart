import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'sellitemformstate.dart';
import '../../../data/models/item.dart';
import '../../../data/models/order_item.dart';
import '../../../data/services/item_repo.dart';
import '../../../data/services/order_item_repo.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/user_repo.dart';
import 'package:e_commerce/utils/logger.dart';

class SellItemVM extends ChangeNotifier {
  SellItemFormState formState = SellItemFormState();
  final ItemRepo _itemRepo;
  final OrderItemRepo _orderRepo;
  final FirebaseAuthService _firebaseAuthService;

  List<Item> _userItems = [];
  List<OrderItem> _myOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<Item>>? _itemsSubscription;
  StreamSubscription<List<OrderItem>>? _ordersSubscription;
  StreamSubscription<User?>? _userAuthSubscription;

  List<Item> get userItems => _userItems;
  List<OrderItem> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SellItemVM({
    ItemRepo? itemRepo,
    OrderItemRepo? orderRepo,
    FirebaseAuthService? firebaseAuthService,
  }) : _itemRepo = itemRepo ?? ItemRepo(),
       _orderRepo = orderRepo ?? OrderItemRepo(),
       _firebaseAuthService =
           firebaseAuthService ?? FirebaseAuthService(UserRepo()) {
    _initStreams();
  }

  void _initStreams() {
    _userAuthSubscription = _firebaseAuthService.authStateChanges.listen((
      user,
    ) {
      if (user != null) {
        appLogger.d(
          'SellItemVM: User logged in (${user.uid}), refreshing data.',
        );
        fetchUserItems();
        _fetchIncomingOrders();
      } else {
        appLogger.d(
          'SellItemVM: User logged out, clearing listings and orders.',
        );
        _userItems = [];
        _myOrders = [];
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    });

    final currentUserId = _firebaseAuthService.currentUser?.uid;
    if (currentUserId != null) {
      fetchUserItems();
      _fetchIncomingOrders();
    }
  }

  Future<void> _fetchIncomingOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _ordersSubscription?.cancel();

    final currentUserId = _firebaseAuthService.currentUser?.uid;
    if (currentUserId == null) {
      _errorMessage = "User not logged in to fetch incoming orders.";
      _myOrders = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      appLogger.d(
        'SellItemVM: Subscribing to incoming orders for seller: $currentUserId',
      );
      _ordersSubscription = _orderRepo
          .getOrdersBySeller(currentUserId)
          .listen(
            (orders) {
              appLogger.d(
                'SellItemVM: Received ${orders.length} incoming orders.',
              );
              _myOrders = orders;
              _isLoading = false;
              notifyListeners();
            },
            onError: (error, stack) {
              _errorMessage = "Failed to load incoming orders: $error";
              appLogger.e(
                'SellItemVM: Error fetching incoming orders: $error',
                error: error,
                stackTrace: stack,
              );
              _myOrders = [];
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e, stack) {
      _errorMessage = "Failed to set up incoming orders subscription: $e";
      appLogger.e(
        'SellItemVM: Error in _fetchIncomingOrders setup: $e',
        error: e,
        stackTrace: stack,
      );
      _myOrders = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _ordersSubscription?.cancel();
    _userAuthSubscription?.cancel();
    appLogger.d('SellItemVM: Disposed and subscriptions cancelled.');
    super.dispose();
  }

  void updateField(String key, String value) {
    switch (key) {
      case 'title':
        formState.title = value;
        break;
      case 'description':
        formState.description = value;
        break;
      case 'price':
        formState.price = value;
        break;
      case 'category':
        formState.category = value;
        break;
      case 'quantity':
        formState.quantity = value;
        break;
      case 'duration':
        formState.duration = value;
        break;
    }
    notifyListeners();
  }

  void setItemType(String type) {
    formState.itemType = type;
    notifyListeners();
  }

  void addImage(String imageUrl) {
    formState.imageUrls.add(imageUrl);
    notifyListeners();
  }

  void removeImage(String imageUrl) {
    formState.imageUrls.remove(imageUrl);
    notifyListeners();
  }

  Future<void> fetchUserItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final currentUserId = _firebaseAuthService.currentUser?.uid;
    if (currentUserId == null) {
      _errorMessage = "User not logged in.";
      _userItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      _userItems = await _itemRepo.getItemsBySeller(currentUserId);
    } catch (e) {
      _errorMessage = "Failed to load your listings: $e";
      _userItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _itemRepo.deleteItem(itemId);
      _userItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadItemForEdit(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final item = await _itemRepo.getItemById(itemId);
      if (item != null) {
        formState.title = item.name;
        formState.description = item.description;
        formState.price = item.price.toString();
        formState.category = item.category;
        formState.itemType =
            item.type == ItemType.product ? 'Product' : 'Service';
        if (item.type == ItemType.product) {
          formState.quantity = item.quantity?.toString();
          formState.duration = null;
        } else {
          formState.duration = item.duration;
          formState.quantity = null;
        }
        formState.imageUrls = item.imageUrls;
      } else {
        _errorMessage = "Item not found.";
      }
    } catch (e) {
      _errorMessage = "Failed to load item for editing: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitForm(String sellerId, [String? itemIdToUpdate]) async {
    if (!formState.isValid) {
      _errorMessage = "Please fill all required fields.";
      notifyListeners();
      return;
    }

    try {
      Item item;
      if (itemIdToUpdate != null) {
        item = Item(
          id: itemIdToUpdate,
          sellerId: sellerId,
          name: formState.title,
          description: formState.description,
          price: double.tryParse(formState.price) ?? 0.0,
          type:
              formState.itemType == 'Service'
                  ? ItemType.service
                  : ItemType.product,
          quantity:
              formState.itemType == 'Product'
                  ? int.tryParse(formState.quantity ?? '0')
                  : null,
          duration: formState.itemType == 'Service' ? formState.duration : null,
          category: formState.category,
          imageUrls: formState.imageUrls,
          listedAt:
              (await _itemRepo.getItemById(itemIdToUpdate))?.listedAt ??
              Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        await _itemRepo.updateItem(item);
      } else {
        item = Item(
          id: const Uuid().v4(),
          sellerId: sellerId,
          name: formState.title,
          description: formState.description,
          price: double.tryParse(formState.price) ?? 0.0,
          type:
              formState.itemType == 'Service'
                  ? ItemType.service
                  : ItemType.product,
          quantity:
              formState.itemType == 'Product'
                  ? int.tryParse(formState.quantity ?? '0')
                  : null,
          duration: formState.itemType == 'Service' ? formState.duration : null,
          category: formState.category,
          imageUrls: formState.imageUrls,
          listedAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        await _itemRepo.addItem(item);
      }

      _resetFormState();
      fetchUserItems();
    } catch (e) {
      _errorMessage = "Failed to submit listing: $e";
      notifyListeners();
      rethrow;
    }
  }

  void _resetFormState() {
    formState = SellItemFormState();
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final orderToUpdate = _myOrders.firstWhere(
        (order) => order.id == orderId,
      );
      final updatedOrder = orderToUpdate.copyWith(status: newStatus);

      await _orderRepo.updateOrder(updatedOrder);
      appLogger.i(
        'SellItemVM: Updated order $orderId status to ${newStatus.name}',
      );
    } catch (e) {
      _errorMessage = "Failed to update order status: $e";
      appLogger.e('SellItemVM: Error updating order status: $e', error: e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Public wrapper to fix the red underline
  Future<void> fetchMyOrders() async => _fetchIncomingOrders();
}
