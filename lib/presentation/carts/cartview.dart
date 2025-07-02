import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:e_commerce/data/models/cart.dart'; // For CartItem type

//
//--------------------------------------------------------------------
// CartPage Widget
//--------------------------------------------------------------------
// This file defines the main user interface for the shopping cart.
// It is a StatefulWidget because it manages the state of several
// TextEditingControllers for the checkout dialog.
//

class CartPage extends StatefulWidget {
  /// An optional callback function that can be triggered to navigate the user
  /// back to the shopping page, typically when the cart is empty.
  final VoidCallback? onStartShopping;

  /// Constructor for the CartPage widget.
  const CartPage({super.key, this.onStartShopping});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // A controller to manage the text input for the delivery address.
  final TextEditingController _addressController = TextEditingController();
  // A controller to manage the text input for special delivery instructions.
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We fetch the ViewModel once and add a listener to it.
    // This is done in didChangeDependencies to ensure it runs after the context is fully available.
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    cartViewModel.addListener(_updateAddressField);
    // Initial call to pre-fill the address field if it's already available in the ViewModel.
    _updateAddressField();
  }

  /// A listener function that updates the address text field if the user's
  /// address changes in the ProfileViewModel.
  void _updateAddressField() {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    // Check if the user's address exists in the ViewModel and if it's different from the current text.
    if (cartViewModel.userAddress != null &&
        _addressController.text != cartViewModel.userAddress) {
      // If so, update the text field to pre-fill the address.
      _addressController.text = cartViewModel.userAddress!;
    } else if (cartViewModel.userAddress == null &&
        _addressController.text.isNotEmpty) {
      // If the address was removed from the profile, clear the text field.
      _addressController.clear();
    }
  }

  @override
  void dispose() {
    // It is crucial to dispose of controllers and remove listeners to prevent memory leaks.
    // Remove the listener from the ViewModel to avoid errors after the widget is removed.
    Provider.of<CartViewModel>(
      context,
      listen: false,
    ).removeListener(_updateAddressField);
    // Dispose of the text editing controllers to free up resources.
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- UI Color Definitions ---
    // Defining colors here for easy access and consistency throughout the build method.
    const Color primaryPink = Color.fromARGB(255, 200, 100, 163);
    const Color accentPurple = Colors.purpleAccent;
    final Color quantityButtonColor = const Color.fromARGB(
      255,
      204,
      80,
      159,
    ).withOpacity(0.9);
    final Color deleteButtonColor = Colors.redAccent.shade400;

    // The main layout widget for this page.
    return Scaffold(
      // --- AppBar Section ---
      // The top bar of the cart page.
      appBar: AppBar(
        // The title of the page.
        title: const Text(
          'My Cart',
          // Styling for the title text.
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // The flexibleSpace allows for a gradient background in the AppBar.
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPink, accentPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Elevation is set to 0 to make the AppBar seamless with the body.
        elevation: 0,
      ),
      // --- Body Section ---
      // The Consumer widget listens to changes in CartViewModel and rebuilds the UI accordingly.
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          // --- Loading State ---
          // If the ViewModel is loading and there are no items yet, show a progress indicator.
          if (viewModel.isLoading && viewModel.cartItems.isEmpty) {
            return Center(child: CircularProgressIndicator(color: primaryPink));
          }

          // --- Error State ---
          // If there's an error message and the cart is empty, display the error.
          if (viewModel.errorMessage != null && viewModel.cartItems.isEmpty) {
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

          // --- Empty Cart State ---
          // If the cart is empty, show a message and a button to encourage shopping.
          if (viewModel.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative icon for an empty state.
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  // Informational text for the user.
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
                  // A button that, when pressed, calls the onStartShopping callback.
                  ElevatedButton.icon(
                    onPressed: () {
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

          // --- Cart with Items State ---
          // If there are items in the cart, display them in a list.
          return Column(
            children: [
              // The Expanded widget ensures the ListView takes up all available vertical space.
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  // The number of items in the list is determined by the length of cartItems from the ViewModel.
                  itemCount: viewModel.cartItems.length,
                  // The itemBuilder builds each cart item card.
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
                            // --- Cart Item Image ---
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
                                // The errorBuilder provides a fallback UI if the image fails to load.
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
                              // If there is no image URL, show a placeholder icon.
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
                            // --- Cart Item Details ---
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item Name
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
                                  // Price per unit
                                  Text(
                                    'RM${cartItem.itemPrice.toStringAsFixed(2)} / unit',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // --- Quantity Controls and Subtotal ---
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Buttons to increase or decrease quantity.
                                      Row(
                                        children: [
                                          _QuantityButton(
                                            icon: Icons.remove,
                                            // The remove button is disabled if quantity is 1.
                                            onPressed:
                                            cartItem.quantity > 1
                                                ? () => viewModel
                                                .updateCartItemQuantity(
                                              cartItem.itemId,
                                              cartItem.quantity - 1,
                                            )
                                                : null,
                                            buttonColor: quantityButtonColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            // Display the current quantity.
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
                                            buttonColor: quantityButtonColor,
                                          ),
                                        ],
                                      ),
                                      // Subtotal for this specific cart item.
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
                            // --- Delete Item Button ---
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
              // --- Bottom Checkout Bar ---
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
                    // --- Total Price Display ---
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
                    const SizedBox(height: 10),
                    // Display an error message here if one exists from a failed checkout attempt.
                    if (viewModel.errorMessage != null && viewModel.cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    // --- Proceed to Checkout Button ---
                    ElevatedButton.icon(
                      // The button is disabled if the cart is empty or if an operation is already in progress.
                      onPressed:
                      viewModel.cartItems.isEmpty || viewModel.isLoading
                          ? null
                          : () {
                        // This opens the dialog to confirm address and place the order.
                        _showPlaceOrderDialog(context, viewModel);
                      },
                      // Show a loading indicator inside the button when processing.
                      icon: viewModel.isLoading
                          ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 26,
                      ),
                      label: Text(
                        viewModel.isLoading ? 'Processing...' : 'Proceed to Checkout',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Styling for the checkout button.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
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

  /// Displays a dialog to confirm the order and enter delivery details.
  void _showPlaceOrderDialog(BuildContext context, CartViewModel viewModel) {
    // Define a primary color for the dialog for styling.
    final Color dialogPrimaryColor = Color.fromARGB(255, 255, 120, 205);

    // Pre-fill the address from the user's profile if it exists.
    if (viewModel.userAddress != null) {
      _addressController.text = viewModel.userAddress!;
    } else {
      _addressController.clear();
    }
    // Always clear instructions for a new order.
    _instructionsController.clear();

    // Show the actual dialog.
    showDialog(
      context: context,
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
          // The content of the dialog, including text fields.
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text field for the delivery address.
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
                // Text field for optional delivery instructions.
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
          // Defines the buttons at the bottom of the dialog.
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            // The "Cancel" button.
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
                // Closes the dialog when pressed.
                Navigator.of(dialogContext).pop();
              },
            ),
            // The "Pay with Stripe" button.
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
                'Pay with Stripe',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // First, validate that the address field is not empty.
                if (_addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
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

                // Close the dialog before starting the payment process.
                Navigator.of(dialogContext).pop();

                // Call the ViewModel method to handle the entire payment and order placement logic.
                final success = await viewModel.processPaymentAndPlaceOrder(
                  _addressController.text.trim(),
                  _instructionsController.text.trim(),
                );

                // Show a confirmation or error message to the user based on the result.
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Payment successful and order placed!', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage ?? 'Payment failed. Please try again.', style: const TextStyle(color: Colors.white)),
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

  /// Displays a confirmation dialog before deleting an item from the cart.
  void _showDeleteConfirmationDialog(
      BuildContext context,
      CartViewModel viewModel,
      String itemId,
      String itemName,
      ) {
    showDialog(
      context: context,
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
            // The "Cancel" button.
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            // The "Remove" button, styled to indicate a destructive action.
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
                // Close the dialog.
                Navigator.of(dialogContext).pop();
                // Call the ViewModel to remove the item.
                viewModel.removeCartItem(itemId);
                // Show a confirmation SnackBar.
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

//
//--------------------------------------------------------------------
// _QuantityButton Helper Widget
//--------------------------------------------------------------------
// A reusable, styled button for incrementing or decrementing quantity.
//

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
        // The color changes to show a disabled state if onPressed is null.
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
        // The icon color also changes to indicate a disabled state.
        color: onPressed != null ? buttonColor : Colors.grey.shade400,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}