import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/utils/logger.dart';

/// A simple read-only use case to get all products (items of type product).
/// It filters the items obtained from the ItemRepository.
class GetAllItemsUseCase {
  final ItemRepo _itemRepository;

  GetAllItemsUseCase(this._itemRepository);

  /// Executes the use case to get a stream of all products.
  Stream<List<Item>> call() {
    appLogger.d('GetAllItemsUseCase: Fetching all items from repository to filter products.');
    return _itemRepository.getItems().map(
      (items) {
        final products = items.where((item) => item.type == ItemType.product).toList();
        appLogger.d('GetAllItemsUseCase: Found ${products.length} products.');
        return products;
      }
    ).handleError((error, stack) {
      appLogger.e('GetAllItemsUseCase: Error fetching products: $error', error: error, stackTrace: stack);
      throw error; // Re-throw to be handled by ViewModel
    });
  }
}
