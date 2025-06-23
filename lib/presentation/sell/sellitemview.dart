import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:async'; // For StreamSubscription
import 'dart:io'; // For File when picking images

import 'package:image_picker/image_picker.dart'; // For image picking
import 'sellitemformstate.dart';
import '../../../data/models/item.dart';
import '../../../data/models/order_item.dart';
import '../../../data/services/item_repo.dart';
import '../../../data/services/order_item_repo.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/services/user_repo.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  StreamSubscription<fb_auth.User?>? _userAuthSubscription;

  List<dynamic> _selectedImages = [];

  List<Item> get userItems => _userItems;
  List<OrderItem> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get selectedImages => _selectedImages;

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
      fb_auth.User? user,
    ) {
      if (user != null) {
        appLogger.d(
          'SellItemVM: User logged in (${user.uid}), refreshing data.',
        );
        _subscribeToUserItems(user.uid);
        _fetchIncomingOrders();
      } else {
        appLogger.d(
          'SellItemVM: User logged out, clearing listings and orders.',
        );
        _userItems = [];
        _myOrders = [];
        _itemsSubscription?.cancel();
        _ordersSubscription?.cancel();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    });

    final currentUserId = _firebaseAuthService.currentUser?.uid;
    if (currentUserId != null) {
      _subscribeToUserItems(currentUserId);
      _fetchIncomingOrders();
    }
  }

  void _subscribeToUserItems(String userId) {
    _itemsSubscription?.cancel();
    _itemsSubscription = _itemRepo
        .getItemsBySellerStream(userId)
        .listen(
          (items) {
            appLogger.d('SellItemVM: Received ${items.length} user items.');
            _userItems = items;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error, stack) {
            _errorMessage = "Failed to load your listings: $error";
            appLogger.e(
              'SellItemVM: Error fetching user items stream: $error',
              error: error,
              stackTrace: stack,
            );
            _userItems = [];
            _isLoading = false;
            notifyListeners();
          },
        );
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
      _ordersSubscription = _orderRepo
          .getOrdersBySeller(currentUserId)
          .listen(
            (orders) {
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
    if (type == 'Product') {
      formState.duration = null;
    } else {
      formState.quantity = null;
    }
    notifyListeners();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to pick images: $e";
      notifyListeners();
      appLogger.e("Error picking images: $e", error: e);
    }
  }

  void removeImage(dynamic imageToRemove) {
    _selectedImages.remove(imageToRemove);
    notifyListeners();
  }

  Future<List<String>> _uploadImages() async {
    final supabase = Supabase.instance.client;
    List<String> imageUrls = [];
    final String userId = _firebaseAuthService.currentUser!.uid;

    for (final image in _selectedImages) {
      if (image is XFile) {
        final fileName = '${userId}_${const Uuid().v4()}_${image.name}';
        final fileBytes = await image.readAsBytes();

        try {
          await supabase.storage
              .from('images')
              .uploadBinary(
                fileName,
                fileBytes,
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );

          final publicUrl = supabase.storage
              .from('images')
              .getPublicUrl(fileName);
          imageUrls.add(publicUrl);
        } catch (e) {
          appLogger.e("⛔ Error uploading image to Supabase: $e");
          rethrow;
        }
      } else if (image is String) {
        imageUrls.add(image);
      }
    }
    return imageUrls;
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
    _subscribeToUserItems(currentUserId);
  }

  Future<void> deleteItem(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final itemToDelete = await _itemRepo.getItemById(itemId);
      if (itemToDelete != null) {
        final supabase = Supabase.instance.client;
        for (String imageUrl in itemToDelete.imageUrls) {
          try {
            final uri = Uri.parse(imageUrl);
            final segments = uri.pathSegments;
            final bucketPath = segments.sublist(1).join('/');
            await supabase.storage.from('images').remove([bucketPath]);
          } catch (e) {
            appLogger.w('⚠️ Failed to delete image from Supabase: $e');
          }
        }
      }
      await _itemRepo.deleteItem(itemId);
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      appLogger.e("Error deleting item: $e", error: e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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
        formState.quantity = item.quantity?.toString();
        formState.duration = item.duration;
        _selectedImages = List.from(item.imageUrls);
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!formState.isValid) {
      _errorMessage = "Please fill all required fields.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      List<String> uploadedImageUrls = await _uploadImages();
      formState.imageUrls = uploadedImageUrls;

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
    } catch (e) {
      _errorMessage = "Failed to submit listing: $e";
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetFormState() {
    formState = SellItemFormState();
    _selectedImages = [];
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
    } catch (e) {
      _errorMessage = "Failed to update order status: $e";
      appLogger.e('SellItemVM: Error updating order status: $e', error: e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders() async => _fetchIncomingOrders();
}
