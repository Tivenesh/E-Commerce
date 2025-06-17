import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'sellitemformstate.dart';
import '../../../data/models/item.dart'; // Assuming this path is correct
import '../../../data/services/item_repo.dart'; // Assuming this path is correct

class SellItemVM extends ChangeNotifier {
  SellItemFormState formState =
      SellItemFormState(); // Make sure this is not final if you want to reset it
  final ItemRepo _itemRepo = ItemRepo();

  List<Item> _userItems = []; // List to hold items sold by the current user
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get userItems => _userItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SellItemVM() {
    // Constructor: NO LONGER CALLING fetchUserItems() here.
    // It will be called explicitly by the UI layer (SellItemsListPage's create method).
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

  // New method to load item data for editing
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
    // itemIdToUpdate is optional
    // Basic validation before submission
    if (!formState.isValid) {
      _errorMessage = "Please fill all required fields.";
      notifyListeners();
      return;
    }

    try {
      Item item;
      if (itemIdToUpdate != null) {
        // Editing an existing item
        item = Item(
          id: itemIdToUpdate, // Use the existing ID
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
              Timestamp.now(), // Preserve original listedAt
          updatedAt: Timestamp.now(),
        );
        await _itemRepo.updateItem(item); // Update the item
      } else {
        // Adding a new item
        item = Item(
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
      }

      _resetFormState(); // Call a new method to reset the form
    } catch (e) {
      _errorMessage = "Failed to submit listing: $e";
      notifyListeners();
      rethrow; // Re-throw to allow UI to show snackbar
    }
  }

  void _resetFormState() {
    formState = SellItemFormState(); // Re-initialize to clear all fields
    notifyListeners();
  }
}
