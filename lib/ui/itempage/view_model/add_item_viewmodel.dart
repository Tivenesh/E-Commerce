import 'package:flutter/material.dart';
import '../../../data/models/item.dart';
import '../../../data//services/item_repository.dart';

class AddItemViewModel extends ChangeNotifier {
  final ItemRepository repository;

  AddItemViewModel({required this.repository});

  String name = '';
  String description = '';
  int quantity = 0;
  String pic = '';
  double price = 0.0;

  String? nameError;
  String? quantityError;
  String? priceError;

  bool isLoading = false;

  void updateName(String val) {
    name = val;
    nameError = null;
    notifyListeners();
  }

  void updateDescription(String val) {
    description = val;
    notifyListeners();
  }

  void updateQuantity(String val) {
    quantity = int.tryParse(val) ?? 0;
    quantityError = null;
    notifyListeners();
  }

  void updatePic(String val) {
    pic = val;
    notifyListeners();
  }

  void updatePrice(String val) {
    price = double.tryParse(val) ?? 0.0;
    priceError = null;
    notifyListeners();
  }

  bool validate() {
    bool valid = true;

    if (name.isEmpty) {
      nameError = 'Name cannot be empty';
      valid = false;
    } else {
      nameError = null;
    }

    if (quantity <= 0) {
      quantityError = 'Quantity must be greater than zero';
      valid = false;
    } else {
      quantityError = null;
    }

    if (price <= 0) {
      priceError = 'Price must be greater than zero';
      valid = false;
    } else {
      priceError = null;
    }

    notifyListeners();
    return valid;
  }

  Future<bool> submit() async {
    if (!validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final item = Item(
        name: name,
        description: description,
        quantity: quantity,
        pic: pic,
        price: price,
      );
      await repository.addItem(item);
      return true;
    } catch (e) {
      // handle error, e.g. log or set error message
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
