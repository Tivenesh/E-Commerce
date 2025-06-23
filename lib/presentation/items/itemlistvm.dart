import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListViewModel extends ChangeNotifier {
  final ItemRepo _itemRepository;
  final AddItemToCartUseCase _addItemToCartUseCase;

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  List<Item> get items => _filteredItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';

  final _searchQueryController = BehaviorSubject<String>();
  Stream<String> get searchQueryStream => _searchQueryController.stream;

  final Map<String, String> _sellerNamesCache = {};

  ItemListViewModel(this._itemRepository, this._addItemToCartUseCase) {
    _isLoading = true;
    notifyListeners();

    _itemRepository.getItems().listen(
      (items) async {
        _allItems = items;
        await _fetchSellerNames(); // Ensure seller names are fetched before filtering
        _filterItems();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        appLogger.d(
          'ItemListViewModel: All items updated. Total: ${items.length}',
        );
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load items: ${error.toString()}';
        notifyListeners();
        appLogger.e(
          'ItemListViewModel: Error fetching items stream: $error',
          error: error,
        );
      },
    );

    _searchQueryController
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (query) {
            _searchQuery = query;
            _filterItems();
            notifyListeners();
            appLogger.d(
              'ItemListViewModel: Search query updated: $_searchQuery',
            );
          },
          onError: (error) {
            appLogger.e(
              'ItemListViewModel: Error in search query stream: $error',
              error: error,
            );
          },
        );
  }

  Future<void> _fetchSellerNames() async {
    final uniqueSellerIds = _allItems.map((item) => item.sellerId).toSet();
    for (final sellerId in uniqueSellerIds) {
      if (!_sellerNamesCache.containsKey(sellerId)) {
        try {
          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(sellerId)
                  .get();
          final name = doc.data()?['username'] ?? 'Unknown';
          _sellerNamesCache[sellerId] = name;
        } catch (_) {
          _sellerNamesCache[sellerId] = 'Unknown';
        }
      }
    }
  }

  String getSellerName(String sellerId) {
    return _sellerNamesCache[sellerId] ?? 'Unknown';
  }

  void _filterItems() {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    // Only show items not sold by the current user
    List<Item> visibleItems =
        _allItems.where((item) => item.sellerId != currentUserId).toList();

    if (_searchQuery.isEmpty) {
      _filteredItems = visibleItems;
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _filteredItems =
          visibleItems.where((item) {
            final sellerName =
                getSellerName(
                  item.sellerId,
                ).toLowerCase(); // Include seller name in search
            return item.name.toLowerCase().contains(queryLower) ||
                item.description.toLowerCase().contains(queryLower) ||
                item.category.toLowerCase().contains(queryLower) ||
                sellerName.contains(
                  queryLower,
                ); // Allow searching by seller name
          }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQueryController.add(query);
  }

  Future<void> addItemToCart(String itemId, int quantity) async {
    final String? userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _errorMessage =
          'User not authenticated. Please log in to add items to cart.';
      notifyListeners();
      appLogger.w(
        'ItemListViewModel: Attempted to add to cart without authenticated user.',
      );
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _addItemToCartUseCase(userId, itemId, quantity);
      _isLoading = false;
      notifyListeners();
      appLogger.i(
        'ItemListViewModel: Added item $itemId to cart for user $userId.',
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add item to cart: ${e.toString()}';
      notifyListeners();
      appLogger.e('ItemListViewModel: Error adding item to cart: $e', error: e);
    }
  }

  @override
  void dispose() {
    _searchQueryController.close();
    super.dispose();
  }
}
