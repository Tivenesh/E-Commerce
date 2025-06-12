import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/items/item_detail_vm.dart';
import 'package:e_commerce/data/models/item.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch item details when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemDetailViewModel>(context, listen: false)
          .fetchItem(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: Consumer<ItemDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.item == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          final item = viewModel.item;
          if (item == null) {
            return const Center(child: Text('Item not available.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageCarousel(item.imageUrls),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(item.category),
                        backgroundColor: Colors.blueGrey[100],
                      ),
                      const SizedBox(height: 16),
                      if (item.type == ItemType.product)
                        Text(
                          'In Stock: ${item.quantity}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      if (item.type == ItemType.service)
                        Text(
                          'Duration: ${item.duration}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  /// Builds the image carousel with the image crash fix.
  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 250,
        color: Colors.blueGrey[50],
        child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
      );
    }
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          // Here is the image crash fix
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            // This errorBuilder prevents the app from crashing if an image fails to load.
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.blueGrey[50],
                child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              );
            },
            // You can also add a loading indicator while the image loads.
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Consumer<ItemDetailViewModel>(
      builder: (context, viewModel, child) {
        bool canAddToCart = false;
        if (viewModel.item != null) {
          canAddToCart = viewModel.item!.type == ItemType.service || (viewModel.item!.type == ItemType.product && (viewModel.item!.quantity ?? 0) > 0);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: canAddToCart && !viewModel.isLoading
                ? () async {
              final success = await viewModel.addItemToCart(1);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${viewModel.item!.name} to cart!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? 'Could not add item.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
                : null,
            icon: viewModel.isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.add_shopping_cart),
            label: viewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Add to Cart', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      },
    );
  }
}