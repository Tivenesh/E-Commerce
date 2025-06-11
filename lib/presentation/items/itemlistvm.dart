import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart'; // To add items to cart
import 'package:e_commerce/utils/logger.dart';
import 'package:rxdart/rxdart.dart'; // For debounce on search 
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // For current user ID

/// ViewModel for the item listing screen (all items, products & services).
/// Manages the state and business logic related to displaying items, searching,
/// and adding to cart.
class ItemListViewModel extends ChangeNotifier {
  final ItemRepo _itemRepository;
  final AddItemToCartUseCase _addItemToCartUseCase;

  List<Item> _allItems = []; // All items fetched from repository
  List<Item> _filteredItems = []; // Items displayed after filtering/searching
  List<Item> get items => _filteredItems; // Exposed state for the View

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = ''; // Current search query

  // Stream for search query with debounce
  final _searchQueryController = BehaviorSubject<String>();
  Stream<String> get searchQueryStream => _searchQueryController.stream;

  ItemListViewModel(this._itemRepository, this._addItemToCartUseCase) {
    _isLoading = true;
    notifyListeners();

    // Listen to real-time updates from the repository
    _itemRepository.getItems().listen(
      (items) {
        _allItems = items;
        _filterItems(); // Re-filter whenever base data changes
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

    // Debounce search query to avoid excessive filtering on every keystroke
    _searchQueryController
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (query) {
            _searchQuery = query;
            _filterItems();
            notifyListeners(); // Notify listeners after filtering with new query
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

  /// Filters items based on the current search query.
  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_allItems); // Show all if no search query
    } else {
      _filteredItems =
          _allItems.where((item) {
            final queryLower = _searchQuery.toLowerCase();
            return item.name.toLowerCase().contains(queryLower) ||
                item.description.toLowerCase().contains(queryLower) ||
                item.category.toLowerCase().contains(queryLower);
          }).toList();
    }
  }

  /// Updates the search query. This is called from the View's search TextField.
  void updateSearchQuery(String query) {
    _searchQueryController.add(
      query,
    ); // Add to the stream, debounce will handle it
  }

  /// Adds a specific item to the current authenticated user's cart.
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
    _searchQueryController.close(); // Close the BehaviorSubject
    super.dispose();
  }
}
