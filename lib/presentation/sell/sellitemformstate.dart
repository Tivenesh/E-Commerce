// File: lib/presentation/sell/sellitemformstate.dart

class SellItemFormState {
  String itemType = 'Product'; // or 'Service'
  String title = '';
  String description = '';
  String price = '';
  String category = '';
  String? quantity; // For product only
  String? duration; // For service only
  List<String> imageUrls = []; // Placeholder for uploaded image URLs

  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        price.isNotEmpty &&
        category.isNotEmpty &&
        (itemType == 'Product' ? quantity != null : duration != null);
  }
}
