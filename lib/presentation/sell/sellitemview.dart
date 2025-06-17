import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sellitemformstate.dart';
import '../../../data/models/item.dart';
import '../../../data/services/item_repo.dart';

class SellItemVM extends ChangeNotifier {
  final SellItemFormState formState = SellItemFormState();
  final ItemRepo _itemRepo = ItemRepo();

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

  Future<void> submitForm(String sellerId) async {
    final item = Item(
      id: const Uuid().v4(),
      sellerId: sellerId,
      name: formState.title,
      description: formState.description,
      price: double.tryParse(formState.price) ?? 0.0,
      type:
          formState.itemType == 'Service' ? ItemType.service : ItemType.product,
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
}
