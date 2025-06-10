import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

import 'package:e_commerce/data/models/cart.dart'; 
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/models/payment.dart';
import 'package:e_commerce/data/models/user.dart';


import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:e_commerce/data/services/payment_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce Data Population & Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey, // Customize app bar background
          foregroundColor: Colors.white, // Customize app bar text/icon color
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// The main screen that displays the data and handles dummy data creation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instantiate each specific service
  final UserRepo _userService = UserRepo();
  final ItemRepo _itemService = ItemRepo();
  final CartRepo _cartService = CartRepo();
  final OrderItemRepo _orderService = OrderItemRepo();
  final PaymentRepo _paymentService = PaymentRepo();

  String _currentTab = 'Users'; // Controls which data is displayed
  final Uuid _uuid = const Uuid(); // For generating unique IDs

  // Define fixed IDs for dummy data to ensure relationships
  late String _dummyUserId;
  late String _dummyProductId;
  late String _dummyServiceId;
  late String _dummyOrderId;
  late String _dummyPaymentId;

  @override
  void initState() {
    super.initState();
    // Initialize dummy IDs
    _dummyUserId = _uuid.v4();
    _dummyProductId = _uuid.v4();
    _dummyServiceId = _uuid.v4();
    _dummyOrderId = _uuid.v4();
    _dummyPaymentId = _uuid.v4();

    // Add some dummy data when the screen initializes
    _addDummyDataIfCollectionsEmpty();
  }

  /// Adds dummy data to Firestore collections if they are empty.
  /// This prevents adding duplicate data on every app restart during development.
  Future<void> _addDummyDataIfCollectionsEmpty() async {
    print('Checking for existing data and adding dummy data if needed...');

    // --- Add Dummy User ---
    final usersSnapshot = await firestore.FirebaseFirestore.instance.collection('users').get();
    if (usersSnapshot.docs.isEmpty) {
      final dummyUser = User(
        id: _dummyUserId,
        email: 'sellerbuyer@example.com',
        username: 'Ecom Seller/Buyer',
        profileImageUrl: 'https://placehold.co/100x100/A0D9F7/FFFFFF?text=User',
        address: '456 Market St, Commerce City, CA 90210',
        phoneNumber: '+1-555-123-4567',
        createdAt: firestore.Timestamp.now(),
        updatedAt: firestore.Timestamp.now(),
      );
      await _userService.addUser(dummyUser);
      print('Added dummy user: ${dummyUser.username}');
    } else {
      _dummyUserId = usersSnapshot.docs.first.id; // Use existing user ID if available
      print('Found existing users. Using first user ID: $_dummyUserId');
    }

    // --- Add Dummy Items (Product & Service) ---
    final itemsSnapshot = await firestore.FirebaseFirestore.instance.collection('items').get();
    if (itemsSnapshot.docs.isEmpty) {
      final dummyProduct = Item(
        id: _dummyProductId,
        sellerId: _dummyUserId,
        name: 'Smart Watch X',
        description: 'Advanced health tracking and notification features.',
        price: 199.99,
        type: ItemType.product,
        quantity: 100,
        category: 'Wearables',
        imageUrls: ['https://placehold.co/150x150/808080/FFFFFF?text=SmartWatch'],
        listedAt: firestore.Timestamp.now(),
        updatedAt: firestore.Timestamp.now(),
      );
      final dummyService = Item(
        id: _dummyServiceId,
        sellerId: _dummyUserId,
        name: 'Mobile App Development',
        description: 'Custom iOS/Android application development service.',
        price: 2500.00,
        type: ItemType.service,
        duration: '40 hours',
        category: 'Digital Services',
        imageUrls: ['https://placehold.co/150x150/32CD32/FFFFFF?text=Mobile+Dev'],
        listedAt: firestore.Timestamp.now(),
        updatedAt: firestore.Timestamp.now(),
      );
      await _itemService.addItem(dummyProduct);
      await _itemService.addItem(dummyService);
      print('Added dummy product and service.');
    } else {
      _dummyProductId = itemsSnapshot.docs.first.id;
      print('Found existing items.');
    }

    // --- Add Dummy Cart Item ---
    // Make sure to add a cart item for the specific _dummyUserId
    final cartSnapshot = await firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(_dummyUserId)
        .collection('cart')
        .get();
    if (cartSnapshot.docs.isEmpty) {
      final dummyCartItem = CartItem(
        itemId: _dummyProductId, // Link to the dummy product
        quantity: 1,
        itemPrice: 199.99,
        itemName: 'Smart Watch X',
        itemImageUrl: 'https://placehold.co/150x150/808080/FFFFFF?text=SmartWatch',
      );
      await _cartService.addOrUpdateCartItem(_dummyUserId, dummyCartItem);
      print('Added dummy cart item for $_dummyUserId.');
    } else {
      print('Found existing cart items for $_dummyUserId.');
    }

    // --- Add Dummy Order ---
    final ordersSnapshot = await firestore.FirebaseFirestore.instance.collection('orders').get();
    if (ordersSnapshot.docs.isEmpty) {
      final dummyOrder = OrderItem(
        id: _dummyOrderId,
        buyerId: _dummyUserId,
        sellerId: _dummyUserId, // Assuming the dummy user is both buyer and seller for this order
        items: [
          CartItem(
            itemId: _dummyProductId,
            quantity: 1,
            itemPrice: 199.99,
            itemName: 'Smart Watch X',
            itemImageUrl: 'https://placehold.co/150x150/808080/FFFFFF?text=SmartWatch',
          ),
          CartItem(
            itemId: _dummyServiceId,
            quantity: 1,
            itemPrice: 2500.00,
            itemName: 'Mobile App Development',
            itemImageUrl: 'https://placehold.co/150x150/32CD32/FFFFFF?text=Mobile+Dev',
          ),
        ],
        totalAmount: 199.99 + 2500.00,
        status: OrderStatus.pending,
        deliveryAddress: '456 Market St, Commerce City, CA 90210',
        deliveryInstructions: 'Leave package at front door.',
        orderDate: firestore.Timestamp.now(),
        estimatedDeliveryDate: firestore.Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      );
      await _orderService.addOrder(dummyOrder);
      print('Added dummy order: ${dummyOrder.id}');
    } else {
      _dummyOrderId = ordersSnapshot.docs.first.id;
      print('Found existing orders.');
    }

    // --- Add Dummy Payment ---
    final paymentsSnapshot = await firestore.FirebaseFirestore.instance.collection('payments').get();
    if (paymentsSnapshot.docs.isEmpty) {
      final dummyPayment = Payment(
        id: _dummyPaymentId,
        orderId: _dummyOrderId, // Link to the dummy order
        payerId: _dummyUserId, // Link to the dummy user
        amount: 2699.99, // Total amount from the dummy order
        paymentDate: firestore.Timestamp.now(),
        paymentMethod: 'Credit Card',
        transactionId: _uuid.v4(),
        isSuccessful: true,
      );
      await _paymentService.addPayment(dummyPayment);
      print('Added dummy payment: ${dummyPayment.id}');
    } else {
      print('Found existing payments.');
    }

    print('Dummy data check complete.');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce Data Overview'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton('Users'),
              _buildTabButton('Items'),
              _buildTabButton('Cart'),
              _buildTabButton('Orders'),
              _buildTabButton('Payments'),
            ],
          ),
        ),
      ),
      body: _buildCurrentDataList(),
    );
  }

  Widget _buildTabButton(String tabName) {
    final bool isSelected = _currentTab == tabName;
    return TextButton(
      onPressed: () {
        setState(() {
          _currentTab = tabName;
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.blueGrey[100],
        backgroundColor: isSelected ? Colors.blueGrey[700] : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(tabName, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCurrentDataList() {
    switch (_currentTab) {
      case 'Users':
        return StreamBuilder<List<User>>(
          stream: _userService.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users found.'));
            }
            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.blueGrey)
                          : null,
                      backgroundColor: Colors.blueGrey[50],
                    ),
                    title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        if (user.address != null && user.address!.isNotEmpty)
                          Text('Address: ${user.address}'),
                      ],
                    ),
                    trailing: Text('ID: ${user.id.substring(0, 6)}...'),
                  ),
                );
              },
            );
          },
        );
      case 'Items':
        return StreamBuilder<List<Item>>(
          stream: _itemService.getItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No items found.'));
            }
            final items = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: item.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(item.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(item.type == ItemType.product ? Icons.shopping_bag : Icons.miscellaneous_services, color: Colors.blueGrey),
                          ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${item.type.toString().split('.').last} | Category: ${item.category}'),
                        Text('Price: \$${item.price.toStringAsFixed(2)}'),
                        if (item.type == ItemType.product)
                          Text('Quantity: ${item.quantity}'),
                        if (item.type == ItemType.service)
                          Text('Duration: ${item.duration}'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey[300]),
                  ),
                );
              },
            );
          },
        );
      case 'Cart':
        return StreamBuilder<List<CartItem>>(
          stream: _cartService.getCartItems(_dummyUserId), // Uses the dummy user's ID
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No items in cart for user $_dummyUserId.'));
            }
            final cartItems = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: cartItem.itemImageUrl != null && cartItem.itemImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(cartItem.itemImageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.shopping_cart, color: Colors.blueGrey),
                          ),
                    title: Text(cartItem.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Quantity: ${cartItem.quantity} | Unit Price: \$${cartItem.itemPrice.toStringAsFixed(2)}'),
                    trailing: Text('Subtotal: \$${(cartItem.quantity * cartItem.itemPrice).toStringAsFixed(2)}'),
                  ),
                );
              },
            );
          },
        );
      case 'Orders':
        return StreamBuilder<List<OrderItem>>(
          stream: _orderService.getOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text('Order ID: ${order.id.substring(0, 6)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Total: \$${order.totalAmount.toStringAsFixed(2)} | Status: ${order.status.toString().split('.').last}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buyer ID: ${order.buyerId.substring(0, 6)}...'),
                            Text('Seller ID: ${order.sellerId.substring(0, 6)}...'),
                            Text('Delivery Address: ${order.deliveryAddress}'),
                            if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty)
                              Text('Instructions: ${order.deliveryInstructions}'),
                            Text('Order Date: ${order.orderDate.toDate().toLocal().toString().split(' ')[0]}'),
                            if (order.estimatedDeliveryDate != null)
                              Text('Est. Delivery: ${order.estimatedDeliveryDate!.toDate().toLocal().toString().split(' ')[0]}'),
                            if (order.deliveredDate != null)
                              Text('Delivered: ${order.deliveredDate!.toDate().toLocal().toString().split(' ')[0]}'),
                            const SizedBox(height: 8),
                            const Text('Items in Order:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ...order.items.map((item) =>
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                  child: Text('- ${item.itemName} (x${item.quantity}) @ \$${item.itemPrice.toStringAsFixed(2)}'),
                                )
                            ).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      case 'Payments':
        return StreamBuilder<List<Payment>>(
          stream: _paymentService.getPayments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No payments found.'));
            }
            final payments = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Icon(payment.isSuccessful ? Icons.check_circle_outline : Icons.cancel_outlined,
                        color: payment.isSuccessful ? Colors.green : Colors.red),
                    title: Text('Payment ID: ${payment.id.substring(0, 6)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Amount: \$${payment.amount.toStringAsFixed(2)} | Method: ${payment.paymentMethod}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Order: ${payment.orderId.substring(0, 6)}...'),
                        Text(payment.paymentDate.toDate().toLocal().toString().split(' ')[0], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      default:
        return const Center(child: Text('Select a tab to view data.'));
    }
  }
}
