import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

import 'package:e_commerce/utils/logger.dart';

import 'package:e_commerce/data/models/cart.dart'; 
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/models/payment.dart';
import 'package:e_commerce/data/models/user.dart';

import 'package:e_commerce/data/services/firebase_auth_service.dart';

import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:e_commerce/data/services/payment_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';

import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signout.dart';


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
      title: 'E-commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),
      // Use a StreamBuilder to listen for authentication state changes
      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // User is signed in
            return const HomeScreen();
          } else {
            // User is signed out
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

/// A simple authentication screen for Sign In and Sign Up.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLogin = true; // Toggle between login and signup

  late final FirebaseAuthService _authService;
  late final SignUpUseCase _signUpUseCase;
  late final SignInUseCase _signInUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize services and use cases
    final UserRepo userService = UserRepo(); // Concrete implementation of UserRepository
    _authService = FirebaseAuthService(userService); // Inject FirebaseUserService
    _signUpUseCase = SignUpUseCase(_authService);
    _signInUseCase = SignInUseCase(_authService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _authenticate() async {
    try {
      if (_isLogin) {
        await _signInUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
      } else {
        await _signUpUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed up and logged in successfully!')),
        );
      }
    } catch (e) {
      appLogger.e('Authentication failed in AuthScreen: $e', error: e); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Your Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blueGrey[700]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (!_isLogin) // Show username field only for sign-up
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isLogin ? 'Login' : 'Sign Up',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                  style: TextStyle(color: Colors.blueGrey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The main screen that displays the data, now accessible after authentication.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instantiate services and use cases (in a real app, these would be injected)
  late final UserRepo _userService;
  late final ItemRepo _itemService;
  late final CartRepo _cartService;
  late final OrderItemRepo _orderService;
  late final PaymentRepo _paymentService;
  late final FirebaseAuthService _authService; // Auth service for sign out
  late final SignOutUseCase _signOutUseCase;

  String _currentTab = 'Users';
  final Uuid _uuid = const Uuid();

  // Use the current authenticated user's UID for data operations
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    // Initialize services
    _userService = UserRepo(); // Concrete implementation of UserRepository
    _itemService = ItemRepo();
    _cartService = CartRepo();
    _orderService = OrderItemRepo();
    _paymentService = PaymentRepo();
    _authService = FirebaseAuthService(_userService); // Inject FirebaseUserService into FirebaseAuthService
    _signOutUseCase = SignOutUseCase(_authService);

    // Ensure there's a current user from Firebase Auth
    _currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

    // Add some dummy data (only if collections are empty)
    _addDummyDataIfCollectionsEmpty();
  }

  /// Adds dummy data to Firestore collections if they are empty.
  /// Uses the currently logged-in user's ID for data association.
  Future<void> _addDummyDataIfCollectionsEmpty() async {
    appLogger.d('Checking for existing data and adding dummy data if needed...'); // Using logger

    // If _currentUserId is 'unknown_user', it means no user was logged in
    // or Firebase Auth hasn't resolved yet. In a real app, dummy data
    // should probably only be added after a user is logged in.
    if (_currentUserId == 'unknown_user') {
      appLogger.w('No authenticated user found for dummy data creation. Skipping dummy data addition.'); // Using logger
      return;
    }

    // --- Add Dummy User (only if it doesn't exist for the current UID) ---
    final userDoc = await firestore.FirebaseFirestore.instance.collection('users').doc(_currentUserId).get();
    if (!userDoc.exists) {
      final dummyUser = User(
        id: _currentUserId,
        email: firebase_auth.FirebaseAuth.instance.currentUser?.email ?? 'authenticated_user@example.com',
        username: firebase_auth.FirebaseAuth.instance.currentUser?.displayName ?? 'Authenticated User',
        profileImageUrl: 'https://placehold.co/100x100/A0D9F7/FFFFFF?text=User',
        address: 'Authenticated Address',
        phoneNumber: 'N/A',
        createdAt: firestore.Timestamp.now(),
        updatedAt: firestore.Timestamp.now(),
      );
      await _userService.addUser(dummyUser);
      appLogger.i('Created Firestore profile for authenticated user: ${dummyUser.username}'); // Using logger
    } else {
      appLogger.i('Firestore profile already exists for user: $_currentUserId'); // Using logger
    }

    // --- Add Dummy Items (Product & Service) ---
    final itemsSnapshot = await firestore.FirebaseFirestore.instance.collection('items').get();
    if (itemsSnapshot.docs.isEmpty) {
      final dummyProduct = Item(
        id: _uuid.v4(),
        sellerId: _currentUserId, // Link to current user as seller
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
        id: _uuid.v4(),
        sellerId: _currentUserId, // Link to current user as seller
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
      appLogger.i('Added dummy product and service.'); // Using logger
    } else {
      appLogger.i('Found existing items.'); // Using logger
    }

    // --- Add Dummy Cart Item ---
    final cartSnapshot = await firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('cart')
        .get();
    if (cartSnapshot.docs.isEmpty) {
      final dummyCartItem = CartItem(
        itemId: itemsSnapshot.docs.isNotEmpty ? itemsSnapshot.docs.first.id : _uuid.v4(), // Use an actual item ID
        quantity: 1,
        itemPrice: 199.99,
        itemName: 'Dummy Cart Item (Smart Watch)',
        itemImageUrl: 'https://placehold.co/150x150/808080/FFFFFF?text=SmartWatch',
      );
      await _cartService.addOrUpdateCartItem(_currentUserId, dummyCartItem);
      appLogger.i('Added dummy cart item for $_currentUserId.'); // Using logger
    } else {
      appLogger.i('Found existing cart items for $_currentUserId.'); // Using logger
    }

    // --- Add Dummy Order ---
    final ordersSnapshot = await firestore.FirebaseFirestore.instance.collection('orders').get();
    if (ordersSnapshot.docs.isEmpty) {
      final orderItems = [
        CartItem(
          itemId: itemsSnapshot.docs.isNotEmpty ? itemsSnapshot.docs.first.id : _uuid.v4(),
          quantity: 1,
          itemPrice: 199.99,
          itemName: 'Smart Watch X',
        ),
      ];
      final dummyOrder = OrderItem(
        id: _uuid.v4(),
        buyerId: _currentUserId,
        sellerId: _currentUserId,
        items: orderItems,
        totalAmount: orderItems.fold(0.0, (sum, item) => sum + (item.itemPrice * item.quantity)),
        status: OrderStatus.pending,
        deliveryAddress: '123 Test St, Authenticated City',
        orderDate: firestore.Timestamp.now(),
      );
      await _orderService.addOrder(dummyOrder);
      appLogger.i('Added dummy order: ${dummyOrder.id}'); // Using logger
    } else {
      appLogger.i('Found existing orders.'); // Using logger
    }

    // --- Add Dummy Payment ---
    final paymentsSnapshot = await firestore.FirebaseFirestore.instance.collection('payments').get();
    if (paymentsSnapshot.docs.isEmpty) {
      final dummyPayment = Payment(
        id: _uuid.v4(),
        orderId: ordersSnapshot.docs.isNotEmpty ? ordersSnapshot.docs.first.id : _uuid.v4(), // Link to an existing order
        payerId: _currentUserId,
        amount: 2699.99,
        paymentDate: firestore.Timestamp.now(),
        paymentMethod: 'Credit Card',
        transactionId: _uuid.v4(),
        isSuccessful: true,
      );
      await _paymentService.addPayment(dummyPayment);
      appLogger.i('Added dummy payment: ${dummyPayment.id}'); // Using logger
    } else {
      appLogger.i('Found existing payments.'); // Using logger
    }

    appLogger.d('Dummy data check complete.'); // Using logger
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce Data Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOutUseCase(); // Call the sign-out use case
              // AuthStreamBuilder in MyApp will automatically navigate to AuthScreen
            },
            tooltip: 'Sign Out',
          ),
        ],
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
          stream: _cartService.getCartItems(_currentUserId), // Uses the current user's ID
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No items in cart for user $_currentUserId.'));
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
                            ),
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
