import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For StreamSubscription

import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Import FirebaseAuthService
import 'package:e_commerce/data/services/user_repo.dart'; // Needed for FirebaseAuthService

class ItemListViewModel extends ChangeNotifier {
  final ItemRepo _itemRepository;
  final AddItemToCartUseCase _addItemToCartUseCase;
  final FirebaseAuthService
  _firebaseAuthService; // NEW: Auth service dependency

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  List<Item> get items => _filteredItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String _filterType = 'All'; // Retained: Filter type functionality

  final _searchQueryController = BehaviorSubject<String>();
  Stream<String> get searchQueryStream => _searchQueryController.stream;

  final Map<String, String> _sellerNamesCache = {};

  StreamSubscription<List<Item>>?
  _itemsStreamSubscription; // To manage item stream
  StreamSubscription<firebase_auth.User?>?
  _userAuthSubscription; // NEW: To listen to auth state changes

  String get filterType => _filterType; // Retained: Getter for filter type

  ItemListViewModel(
    this._itemRepository,
    this._addItemToCartUseCase,
    this._firebaseAuthService, // NEW: Require FirebaseAuthService in constructor
  ) {
    appLogger.d('ItemListViewModel: Constructor called. Initializing streams.');
    _initStreams(); // NEW: Call _initStreams to set up auth and item listeners
  }

  // NEW: Centralized stream initialization and management
  void _initStreams() {
    _isLoading = true;
    notifyListeners();

    // Listen to Firebase Auth state changes
    _userAuthSubscription = _firebaseAuthService.authStateChanges.listen((
      firebase_auth.User? user,
    ) async {
      if (user != null) {
        appLogger.d(
          'ItemListViewModel: Auth state changed - User logged IN: ${user.uid}',
        );
        // User logged in, refresh all data
        await _fetchAndFilterAllItems(); // Re-fetch and filter for the new user
      } else {
        appLogger.d(
          'ItemListViewModel: Auth state changed - User logged OUT. Clearing item data.',
        );
        // User logged out, clear all items and reset state
        _allItems = [];
        _filteredItems = [];
        _isLoading = false;
        _errorMessage = null;
        _itemsStreamSubscription?.cancel(); // Cancel any existing item stream
        _itemsStreamSubscription = null; // Clear subscription reference
        notifyListeners();
      }
    });

    // Initial fetch of items when ViewModel is created.
    // This handles the initial state (whether logged in or not).
    // The `_userAuthSubscription` will then handle subsequent login/logout events.
    _fetchAndFilterAllItems();

    _searchQueryController
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (query) {
            _searchQuery = query;
            _filterItems(); // Re-filter when search query changes
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

  // Consolidated method to fetch all items and then filter them
  Future<void> _fetchAndFilterAllItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _itemsStreamSubscription
        ?.cancel(); // Cancel previous subscription before setting up new one
    appLogger.d('ItemListViewModel: Subscribing to all items stream.');
    _itemsStreamSubscription = _itemRepository.getItems().listen(
      (items) async {
        _allItems = items;
        await _fetchSellerNames(); // Ensure seller names are fetched
        _filterItems(); // Filter items based on current search/filter and user
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        appLogger.d(
          'ItemListViewModel: All items updated and filtered. Total: ${items.length}, Filtered: ${_filteredItems.length}',
        );
      },
      onError: (error, stack) {
        _isLoading = false;
        _errorMessage = 'Failed to load items: ${error.toString()}';
        notifyListeners();
        appLogger.e(
          'ItemListViewModel: Error fetching items stream: $error',
          error: error,
          stackTrace: stack,
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
          appLogger.d(
            'ItemListViewModel: Fetched seller name for $sellerId: $name',
          );
        } catch (e) {
          _sellerNamesCache[sellerId] = 'Unknown';
          appLogger.e(
            'ItemListViewModel: Error fetching seller name for $sellerId: $e',
          );
        }
      }
    }
  }

  String getSellerName(String sellerId) {
    return _sellerNamesCache[sellerId] ?? 'Unknown';
  }

  void _filterItems() {
    appLogger.d(
      'ItemListViewModel: Filter Debug: Entering _filterItems. Query: "$_searchQuery", FilterType: "$_filterType"',
    );
    // MODIFIED: Use _firebaseAuthService to get current user ID
    final currentUserId = _firebaseAuthService.currentUser?.uid;

    // Only show items not sold by the current user
    List<Item> visibleItems =
        _allItems.where((item) => item.sellerId != currentUserId).toList();
    appLogger.d(
      'ItemListViewModel: Filter Debug: ${visibleItems.length} visible items before query filtering.',
    );

    if (_searchQuery.isEmpty) {
      _filteredItems = visibleItems;
      appLogger.d(
        'ItemListViewModel: Filter Debug: Search query empty, showing all visible items.',
      );
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _filteredItems =
          visibleItems.where((item) {
            final sellerName = getSellerName(item.sellerId).toLowerCase();
            final itemNameLower = item.name.toLowerCase();
            final itemDescriptionLower = item.description.toLowerCase();
            final itemCategoryLower = item.category.toLowerCase();

            bool matches = false;
            // Retained: Filter logic based on _filterType
            switch (_filterType) {
              case 'All':
                matches =
                    itemNameLower.contains(queryLower) ||
                    itemDescriptionLower.contains(queryLower) ||
                    itemCategoryLower.contains(queryLower) ||
                    sellerName.contains(queryLower);
                break;
              case 'Seller':
                matches = sellerName.contains(queryLower);
                break;
              case 'Item':
                matches =
                    itemNameLower.contains(queryLower) ||
                    itemDescriptionLower.contains(queryLower);
                break;
              case 'Category':
                matches = itemCategoryLower.contains(queryLower);
                break;
              default:
                matches = true; // Should not happen with defined types
                appLogger.w(
                  'ItemListViewModel: Filter Debug: Unknown filter type: $_filterType',
                );
            }
            appLogger.d(
              'ItemListViewModel: Filter Debug: Item "${item.name}" (Seller: "$sellerName", Category: "${item.category}") - Matches: $matches for query "$queryLower" with filter "$_filterType"',
            );
            return matches;
          }).toList();
      appLogger.d(
        'ItemListViewModel: Filter Debug: Filtered down to ${_filteredItems.length} items.',
      );
    }
    notifyListeners(); // Ensure listeners are notified after filtering
  }

  void updateSearchQuery(String query) {
    _searchQueryController.add(query);
  }

  void updateFilterType(String type) {
    if (_filterType != type) {
      _filterType = type;
      _filterItems(); // Re-filter items based on new filter type
      notifyListeners();
      appLogger.d('ItemListViewModel: Filter type updated to: $_filterType');
    }
  }

  Future<void> addItemToCart(String itemId, int quantity) async {
    // MODIFIED: Use _firebaseAuthService to get current user ID
    final String? userId = _firebaseAuthService.currentUser?.uid;
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
    appLogger.d(
      'ItemListViewModel: dispose() called. Cancelling all subscriptions.',
    );
    _searchQueryController.close();
    _itemsStreamSubscription?.cancel(); // NEW: Cancel item stream subscription
    _userAuthSubscription?.cancel(); // NEW: Cancel auth state subscription
    super.dispose();
  }
}
