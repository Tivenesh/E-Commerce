import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:e_commerce/data/models/cart.dart'; // For CartItem type

/// The user's shopping cart page (View).
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
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
          if (viewModel.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty. Start shopping!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: viewModel.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = viewModel.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child:
                                  (cartItem.itemImageUrl != null &&
                                          cartItem.itemImageUrl!.isNotEmpty)
                                      ? Image.network(
                                        cartItem.itemImageUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        // Error builder for when Image.network fails to load
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.0,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ), // Broken image icon
                                                ),
                                      )
                                      : Container(
                                        // Fallback if no URL is provided at all
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50],
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart,
                                          color: Colors.blueGrey,
                                        ), // Generic cart icon
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'RM${cartItem.itemPrice.toStringAsFixed(2)} / unit',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed:
                                            () => viewModel
                                                .updateCartItemQuantity(
                                                  cartItem.itemId,
                                                  cartItem.quantity - 1,
                                                ),
                                      ),
                                      Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed:
                                            () => viewModel
                                                .updateCartItemQuantity(
                                                  cartItem.itemId,
                                                  cartItem.quantity + 1,
                                                ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'RM${(cartItem.quantity * cartItem.itemPrice).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed:
                                  () =>
                                      viewModel.removeCartItem(cartItem.itemId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RM${viewModel.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          viewModel.cartItems.isEmpty || viewModel.isLoading
                              ? null
                              : () {
                                _showPlaceOrderDialog(context, viewModel);
                              },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context, CartViewModel viewModel) {
    final TextEditingController addressController = TextEditingController(
      // text: '123 My Street, My City',
    ); // Pre-fill for demo
    final TextEditingController instructionsController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Place Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                  ),
                ),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Instructions (Optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm Order'),
              onPressed: () async {
                if (addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Delivery address cannot be empty!'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(); // Close dialog

                final order = await viewModel.placeOrder(
                  addressController.text.trim(),
                  deliveryInstructions: instructionsController.text.trim(),
                );

                if (order != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Order ${order.id.substring(0, 6)}... placed successfully!',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.errorMessage ?? 'Failed to place order.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
