import '../models/item.dart';
import 'firebase_service.dart';

class ItemRepository {
  final FirebaseService _firebaseService;

  ItemRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final String _collectionPath = 'items';

  Future<void> addItem(Item item) {
    return _firebaseService.addDocument(_collectionPath, item.toMap());
  }

  Future<void> updateItem(Item item) {
    if (item.id.isEmpty) {
      throw Exception('Document ID is required to update an item');
    }
    return _firebaseService.updateDocument(_collectionPath, item.id, item.toMap());
  }

  Future<void> deleteItem(String id) {
    return _firebaseService.deleteDocument(_collectionPath, id);
  }

  Stream<List<Item>> streamItems() {
    return _firebaseService.streamCollection(_collectionPath).map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
          .toList();
    });
  }
}
