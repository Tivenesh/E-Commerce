// cartview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:e_commerce/data/models/cart.dart'; // For CartItem type

/// The user's shopping cart page (View).
class CartPage extends StatefulWidget {
  final VoidCallback? onStartShopping; // New callback

  const CartPage({super.key, this.onStartShopping}); // Update constructor

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    cartViewModel.addListener(_updateAddressField);
    _updateAddressField();
  }

  void _updateAddressField() {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    if (cartViewModel.userAddress != null &&
        _addressController.text != cartViewModel.userAddress) {
      _addressController.text = cartViewModel.userAddress!;
    } else if (cartViewModel.userAddress == null &&
        _addressController.text.isNotEmpty) {
      _addressController.clear();
    }
  }

  @override
  void dispose() {
    Provider.of<CartViewModel>(
      context,
      listen: false,
    ).removeListener(_updateAddressField);
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color.fromARGB(255, 200, 100, 163);
    const Color accentPurple = Colors.purpleAccent;
    final Color buttonColor = const Color.fromARGB(
      255,
      204,
      80,
      159,
    ).withOpacity(0.9);
    final Color deleteButtonColor = Colors.redAccent.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPink, accentPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryPink));
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty. Let\'s find some amazing items!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Call the callback to switch to the Shop tab
                      widget.onStartShopping?.call();
                    },
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Start Shopping',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: viewModel.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = viewModel.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.black.withOpacity(0.15),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child:
                                  (cartItem.itemImageUrl != null &&
                                          cartItem.itemImageUrl!.isNotEmpty)
                                      ? Image.network(
                                        cartItem.itemImageUrl!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 90,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15.0,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey.shade400,
                                                    size: 40,
                                                  ),
                                                ),
                                      )
                                      : Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            15.0,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.grey.shade400,
                                          size: 40,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'RM${cartItem.itemPrice.toStringAsFixed(2)} / unit',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _QuantityButton(
                                            icon: Icons.remove,
                                            onPressed:
                                                cartItem.quantity > 1
                                                    ? () => viewModel
                                                        .updateCartItemQuantity(
                                                          cartItem.itemId,
                                                          cartItem.quantity - 1,
                                                        )
                                                    : null,
                                            buttonColor: buttonColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          _QuantityButton(
                                            icon: Icons.add,
                                            onPressed:
                                                () => viewModel
                                                    .updateCartItemQuantity(
                                                      cartItem.itemId,
                                                      cartItem.quantity + 1,
                                                    ),
                                            buttonColor: buttonColor,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Text(
                                          'RM${(cartItem.quantity * cartItem.itemPrice).toStringAsFixed(2)}',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: primaryPink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                                color: deleteButtonColor,
                                size: 28,
                              ),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                  context,
                                  viewModel,
                                  cartItem.itemId,
                                  cartItem.itemName,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${viewModel.cartItems.length} items):',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'RM${viewModel.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed:
                          viewModel.cartItems.isEmpty || viewModel.isLoading
                              ? null
                              : () {
                                _showPlaceOrderDialog(context, viewModel);
                              },
                      icon: const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 26,
                      ),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
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
    final Color dialogPrimaryColor = Color.fromARGB(255, 255, 120, 205);

    if (viewModel.userAddress != null) {
      _addressController.text = viewModel.userAddress!;
    } else {
      _addressController.clear();
    }

    showDialog(
      context: context, // Corrected from dialogContext to context
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Your Order',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: dialogPrimaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'Enter your full delivery address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dialogPrimaryColor.withOpacity(0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dialogPrimaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: dialogPrimaryColor,
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Instructions (Optional)',
                    hintText: 'e.g., "Leave at door", "Call upon arrival"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dialogPrimaryColor.withOpacity(0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dialogPrimaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.notes, color: dialogPrimaryColor),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                elevation: 5,
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                if (_addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // Corrected from dialogContext to context
                    const SnackBar(
                      content: Text(
                        'Delivery address cannot be empty!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();

                final order = await viewModel.placeOrder(
                  _addressController.text.trim(),
                  deliveryInstructions: _instructionsController.text.trim(),
                );

                if (order != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Order ${order.id.substring(0, 6)}... placed successfully!',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.errorMessage ??
                            'Failed to place order. Please try again.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CartViewModel viewModel,
    String itemId,
    String itemName,
  ) {
    showDialog(
      context: context, // Corrected from dialogContext to context
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Remove Item',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Text(
            'Are you sure you want to remove "$itemName" from your cart?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.removeCartItem(itemId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$itemName" removed from cart.'),
                    backgroundColor: Colors.orange.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color buttonColor;

  const _QuantityButton({
    required this.icon,
    this.onPressed,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? buttonColor.withOpacity(0.15)
                : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              onPressed != null
                  ? buttonColor.withOpacity(0.5)
                  : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: onPressed != null ? buttonColor : Colors.grey.shade400,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
