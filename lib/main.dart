// lib/main.dart (Final Corrected Version)

import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/firebase_auth_service.dart';
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:e_commerce/data/services/payment_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/data/usecases/items/get_all_item_usecase.dart';
import 'package:e_commerce/data/usecases/orders/place_order_usecase.dart';
import 'package:e_commerce/presentation/authscreen.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:e_commerce/presentation/orders/orderlistvm.dart';
import 'package:e_commerce/presentation/testhome.dart';
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with your Publishable Key
  //Stripe.publishableKey = 'pk_test_51RgRX7Q00D5aT2cEnv5Ks2vPnc2X8FLLILma4WN9wxd11dz0G1SafCLaQMyH16NjtxGRZhlW8g6sQ8YNk0sPg9AF00VZjZ2hO0';

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uhhemalhxfozystsqcfl.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVoaGVtYWxoeGZvenlzdHNxY2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0Mzk3MjYsImV4cCI6MjA2NjAxNTcyNn0.Xg7oXIKlS6Zn2wmLwQwQDul4MYiftk3J9yLr2gkvthY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final UserRepo firebaseUserService = UserRepo();
    final ItemRepo firebaseItemService = ItemRepo();
    final CartRepo firebaseCartService = CartRepo();
    final OrderItemRepo firebaseOrderService = OrderItemRepo();
    final PaymentRepo firebasePaymentService = PaymentRepo();
    final FirebaseAuthService firebaseAuthService = FirebaseAuthService(firebaseUserService);
    final SignUpUseCase signUpUseCase = SignUpUseCase(firebaseAuthService);
    final SignInUseCase signInUseCase = SignInUseCase(firebaseAuthService);
    final SignOutUseCase signOutUseCase = SignOutUseCase(firebaseAuthService);
    final AddItemToCartUseCase addItemToCartUseCase = AddItemToCartUseCase(firebaseCartService, firebaseItemService);
    final PlaceOrderUseCase placeOrderUseCase = PlaceOrderUseCase(firebaseCartService, firebaseOrderService, firebaseItemService, firebaseUserService);
    final GetAllItemsUseCase getAllProductsUseCase = GetAllItemsUseCase(firebaseItemService);

    return MultiProvider(
      providers: [
        Provider<UserRepo>(create: (_) => firebaseUserService),
        Provider<ItemRepo>(create: (_) => firebaseItemService),
        Provider<CartRepo>(create: (_) => firebaseCartService),
        Provider<OrderItemRepo>(create: (_) => firebaseOrderService),
        Provider<PaymentRepo>(create: (_) => firebasePaymentService),
        Provider<FirebaseAuthService>(create: (_) => firebaseAuthService),
        Provider<SignUpUseCase>(create: (_) => signUpUseCase),
        Provider<SignInUseCase>(create: (_) => signInUseCase),
        Provider<SignOutUseCase>(create: (_) => signOutUseCase),
        Provider<AddItemToCartUseCase>(create: (_) => addItemToCartUseCase),
        Provider<PlaceOrderUseCase>(create: (_) => placeOrderUseCase),
        Provider<GetAllItemsUseCase>(create: (_) => getAllProductsUseCase),
        ChangeNotifierProvider(create: (context) => ProfileViewModel(Provider.of<UserRepo>(context, listen: false), Provider.of<FirebaseAuthService>(context, listen: false))),
        ChangeNotifierProvider(create: (context) => ItemListViewModel(Provider.of<ItemRepo>(context, listen: false), Provider.of<AddItemToCartUseCase>(context, listen: false), Provider.of<FirebaseAuthService>(context, listen: false))),
        ChangeNotifierProvider(create: (context) => CartViewModel(Provider.of<CartRepo>(context, listen: false), Provider.of<ItemRepo>(context, listen: false), Provider.of<PlaceOrderUseCase>(context, listen: false), Provider.of<UserRepo>(context, listen: false), Provider.of<FirebaseAuthService>(context, listen: false))),
        ChangeNotifierProvider(create: (context) => OrderListViewModel(Provider.of<OrderItemRepo>(context, listen: false), Provider.of<FirebaseAuthService>(context, listen: false))),
      ],
      child: MaterialApp(
        title: 'E-commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const AuthScreen();
      },
    );
  }
}