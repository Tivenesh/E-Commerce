import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:e_commerce/data/services/firebase_auth_service.dart';
import 'package:e_commerce/data/services/user_repo.dart';

// An enum to represent the different sorting options available.
// This provides a type-safe way to handle sort logic.
enum SortType {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
  nameZA
}

class ItemListViewModel extends ChangeNotifier {
  // Dependencies are injected for testability and separation of concerns.
  final ItemRepo _itemRepository;
  final AddItemToCartUseCase _addItemToCartUseCase;
  final FirebaseAuthService _firebaseAuthService;

  // --- State Properties ---
  List<Item> _allItems = []; // Holds the original, unsorted list of all items from the database.
  List<Item> _filteredItems = []; // Holds the final list to be displayed after filtering and sorting.
  List<Item> get items => _filteredItems; // Public getter for the UI to read.

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';

  // Holds the currently selected sort order. It defaults to 'newest'.
  SortType _currentSortType = SortType.newest;
  SortType get currentSortType => _currentSortType;

  // A stream controller to handle search queries with a debounce to avoid excessive filtering.
  final _searchQueryController = BehaviorSubject<String>();
  Stream<String> get searchQueryStream => _searchQueryController.stream;

  // A cache to store seller names to avoid repeated database lookups.
  final Map<String, String> _sellerNamesCache = {};

  // Stream subscriptions to manage real-time data listeners.
  StreamSubscription<List<Item>>? _itemsStreamSubscription;
  StreamSubscription<firebase_auth.User?>? _userAuthSubscription;


  ItemListViewModel(
      this._itemRepository,
      this._addItemToCartUseCase,
      this._firebaseAuthService,
      ) {
    appLogger.d('ItemListViewModel: Constructor called. Initializing streams.');
    _initStreams();
  }

  /// Sets up all the real-time listeners for the ViewModel.
  void _initStreams() {
    _isLoading = true;
    notifyListeners();

    // Listens for changes in user authentication (login/logout).
    _userAuthSubscription = _firebaseAuthService.authStateChanges.listen((
        firebase_auth.User? user,
        ) async {
      if (user != null) {
        await _fetchAndSortAllItems();
      } else {
        // If the user logs out, clear all data.
        _allItems = [];
        _filteredItems = [];
        _isLoading = false;
        _errorMessage = null;
        _itemsStreamSubscription?.cancel();
        _itemsStreamSubscription = null;
        notifyListeners();
      }
    });

    // Initial data fetch when the app starts.
    _fetchAndSortAllItems();

    // Listens to the search query stream with a 300ms debounce.
    _searchQueryController
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (query) {
        _searchQuery = query;
        _applyFiltersAndSorting(); // Re-run the filter/sort logic when the query changes.
      },
    );
  }

  /// Fetches all items from the repository and triggers the filtering/sorting process.
  Future<void> _fetchAndSortAllItems() async {
    _isLoading = true;
    notifyListeners();

    _itemsStreamSubscription?.cancel();
    _itemsStreamSubscription = _itemRepository.getItems().listen(
          (items) async {
        _allItems = items;
        await _fetchSellerNames();
        _applyFiltersAndSorting();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error, stack) {
        _errorMessage = 'Failed to load items: ${error.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Fetches and caches the usernames of sellers for display on the item cards.
  Future<void> _fetchSellerNames() async {
    final uniqueSellerIds = _allItems.map((item) => item.sellerId).toSet();
    for (final sellerId in uniqueSellerIds) {
      if (!_sellerNamesCache.containsKey(sellerId)) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
          _sellerNamesCache[sellerId] = doc.data()?['username'] ?? 'Unknown';
        } catch (e) {
          _sellerNamesCache[sellerId] = 'Unknown';
        }
      }
    }
  }

  String getSellerName(String sellerId) {
    return _sellerNamesCache[sellerId] ?? 'Unknown';
  }

  /// This is the core method that handles both searching and sorting.
  void _applyFiltersAndSorting() {
    List<Item> tempItems;

    // 1. Apply the search query filter first.
    if (_searchQuery.isEmpty) {
      tempItems = List.from(_allItems);
    } else {
      final queryLower = _searchQuery.toLowerCase();
      tempItems = _allItems.where((item) {
        final sellerName = getSellerName(item.sellerId).toLowerCase();
        final itemNameLower = item.name.toLowerCase();
        return itemNameLower.contains(queryLower) || sellerName.contains(queryLower);
      }).toList();
    }

    // 2. Apply the selected sort order on the filtered list.
    switch (_currentSortType) {
      case SortType.newest:
        tempItems.sort((a, b) => b.listedAt.compareTo(a.listedAt));
        break;
      case SortType.oldest:
        tempItems.sort((a, b) => a.listedAt.compareTo(b.listedAt));
        break;
      case SortType.priceLowToHigh:
        tempItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceHighToLow:
        tempItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.nameAZ:
        tempItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortType.nameZA:
        tempItems.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    // Update the final list that the UI displays.
    _filteredItems = tempItems;
    notifyListeners(); // Tell the UI to rebuild.
  }

  /// Public method called by the UI when the user chooses a new sort option.
  void updateSortOrder(SortType sortType) {
    if (_currentSortType != sortType) {
      _currentSortType = sortType;
      _applyFiltersAndSorting(); // Re-apply the logic with the new sort type.
    }
  }

  /// Called by the UI's search field to update the search query stream.
  void updateSearchQuery(String query) {
    _searchQueryController.add(query);
  }

  /// Handles the business logic of adding an item to the cart.
  Future<void> addItemToCart(String itemId, int quantity) async {
    final String? userId = _firebaseAuthService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated. Please log in to add items to cart.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _addItemToCartUseCase(userId, itemId, quantity);
    } catch (e) {
      _errorMessage = 'Failed to add item to cart: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cleans up resources when the ViewModel is no longer needed.
  @override
  void dispose() {
    appLogger.d('ItemListViewModel: dispose() called. Cancelling all subscriptions.');
    _searchQueryController.close();
    _itemsStreamSubscription?.cancel();
    _userAuthSubscription?.cancel();
    super.dispose();
  }
}