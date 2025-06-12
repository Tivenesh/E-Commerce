import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ItemDetailViewModel extends ChangeNotifier {
  final ItemRepo _itemRepository;
  final AddItemToCartUseCase _addItemToCartUseCase;

  Item? _item;
  Item? get item => _item;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ItemDetailViewModel(this._itemRepository, this._addItemToCartUseCase);

  Future<void> fetchItem(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _item = await _itemRepository.getItemById(itemId);
      if (_item == null) {
        _errorMessage = 'Item not found.';
        appLogger.w('ItemDetailViewModel: Item with ID $itemId not found.');
      }
    } catch (e) {
      _errorMessage = 'Failed to load item details: ${e.toString()}';
      appLogger.e('ItemDetailViewModel: Error fetching item $itemId: $e', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addItemToCart(int quantity) async {
    if (_item == null) {
      _errorMessage = 'No item to add.';
      notifyListeners();
      return false;
    }

    final String? userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'You must be logged in to add items to your cart.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _addItemToCartUseCase(userId, _item!.id, quantity);
      appLogger.i('ItemDetailViewModel: Added ${_item!.name} to cart.');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add item to cart: ${e.toString()}';
      appLogger.e('ItemDetailViewModel: Error adding item to cart: $e', error: e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}