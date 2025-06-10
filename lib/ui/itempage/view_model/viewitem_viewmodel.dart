import 'package:flutter/material.dart';
import 'package:e_commerce/data/models/item.dart';
import '../../../data/services/old_item_repository.dart';
import 'dart:async'; // For StreamSubscription
class ItemListViewModel extends ChangeNotifier {
  final ItemRepository _repo;
  List<Item> items = [];
  bool isLoading = true;
  late final StreamSubscription _subscription;

  ItemListViewModel(this._repo) {
    _listenItems();
  }

  void _listenItems() {
    _subscription = _repo.streamItems().listen((data) {
      items = data;
      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      // print("Stream error: $error");
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addItem(Item item) async {
    try {
      await _repo.addItem(item);
    } catch (e) {
      // print("Add item error: $e");
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _repo.updateItem(item);
    } catch (e) {
      // print("Update item error: $e");
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deleteItem(id);
    } catch (e) {
      // print("Delete item error: $e");
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}