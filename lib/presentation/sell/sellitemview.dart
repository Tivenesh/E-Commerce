import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'sellitemformstate.dart';
import '../../../data/models/item.dart'; // Assuming this path is correct
import '../../../data/services/item_repo.dart'; // Assuming this path is correct

class SellItemVM extends ChangeNotifier {
  final SellItemFormState formState = SellItemFormState();
  final ItemRepo _itemRepo = ItemRepo();

  List<Item> _userItems = []; // List to hold items sold by the current user
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get userItems => _userItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SellItemVM() {
    // Constructor: Load user items when the ViewModel is created
    fetchUserItems();
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

  // --- New methods for listing management ---

  Future<void> fetchUserItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _errorMessage = "User not logged in.";
        _userItems = []; // Clear items if not logged in
        return;
      }
      _userItems = await _itemRepo.getItemsBySeller(currentUser.uid);
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
      // Remove from local list and notify listeners
      _userItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      notifyListeners();
      rethrow; // Re-throw to allow UI to show snackbar
    }
  }

  Future<void> submitForm(String sellerId) async {
    // Basic validation before submission
    if (!formState.isValid) {
      _errorMessage = "Please fill all required fields.";
      notifyListeners();
      return;
    }

    try {
      final item = Item(
        id: const Uuid().v4(), // Generate new ID for new items
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

      await _itemRepo.addItem(item); // Add the item to Firestore
      // After successful submission, refresh the list of user items
      await fetchUserItems();
      // Optionally clear the form state for next entry
      // formState = SellItemFormState(); // You'd need to re-initialize or reset fields
      // notifyListeners(); // Only if you clear the form here
    } catch (e) {
      _errorMessage = "Failed to submit listing: $e";
      notifyListeners();
      rethrow; // Re-throw to allow UI to show snackbar
    }
  }
}
