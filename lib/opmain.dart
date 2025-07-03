import 'package:e_commerce/data/services/cart_repo.dart';
import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Your specific Auth Service
import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/order_item_repo.dart';
import 'package:e_commerce/data/services/payment_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart'; // <<<--- THIS IS THE KEY IMPORT
import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/data/usecases/items/get_all_item_usecase.dart';
import 'package:e_commerce/data/usecases/orders/place_order_usecase.dart';
import 'package:e_commerce/presentation/authscreen.dart'; // Your AuthScreen
import 'package:e_commerce/presentation/carts/cartvm.dart'; // Your CartViewModel
import 'package:e_commerce/presentation/items/itemlistvm.dart'; // Your ItemListViewModel
import 'package:e_commerce/presentation/orders/orderlistvm.dart'; // Your OrderListViewModel
import 'package:e_commerce/presentation/testhome.dart'; // Your TestHome
import 'package:e_commerce/presentation/users/profilevm.dart'; // Your ProfileViewModel
import 'package:e_commerce/routing/routes.dart'; // Your AppRouter and AppRoutes
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias for Firebase Auth's User
import 'package:provider/provider.dart'; // For Provider, Consumer, Selector
import 'package:supabase_flutter/supabase_flutter.dart';
// Firebase options
import 'firebase_options.dart';

// Models (assuming these are in your project)

// Utils
import 'package:e_commerce/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    // Initialize all your concrete services (Data Layer implementations)
    // These are often instantiated once and provided throughout the app.
    final UserRepo firebaseUserService = UserRepo();
    final ItemRepo firebaseItemService = ItemRepo();
    final CartRepo firebaseCartService = CartRepo();
    final OrderItemRepo firebaseOrderService = OrderItemRepo();
    final PaymentRepo firebasePaymentService =
        PaymentRepo(); // Unused for now, but available

    // Initialize your FirebaseAuthService, injecting its dependencies
    final FirebaseAuthService firebaseAuthService = FirebaseAuthService(
      firebaseUserService,
    );

    // Initialize all Use Cases, injecting their dependencies (repositories/other services)
    final SignUpUseCase signUpUseCase = SignUpUseCase(firebaseAuthService);
    final SignInUseCase signInUseCase = SignInUseCase(firebaseAuthService);
    final SignOutUseCase signOutUseCase = SignOutUseCase(firebaseAuthService);
    final AddItemToCartUseCase addItemToCartUseCase = AddItemToCartUseCase(
      firebaseCartService,
      firebaseItemService,
    );
    final PlaceOrderUseCase placeOrderUseCase = PlaceOrderUseCase(
      firebaseCartService,
      firebaseOrderService,
      firebaseItemService,
      firebaseUserService, // <<<--- Ensure firebaseUserService is passed here
    );
    final GetAllItemsUseCase getAllProductsUseCase = GetAllItemsUseCase(
      firebaseItemService,
    ); // Used by ItemListViewModel

    return MultiProvider(
      providers: [
        // Provide concrete Repository implementations (as their abstract types)
        // This is crucial for dependency injection into ViewModels.
        Provider<UserRepo>(create: (_) => firebaseUserService),
        Provider<ItemRepo>(create: (_) => firebaseItemService),
        Provider<CartRepo>(create: (_) => firebaseCartService),
        Provider<OrderItemRepo>(create: (_) => firebaseOrderService),
        Provider<PaymentRepo>(create: (_) => firebasePaymentService),

        // Provide Services (like FirebaseAuthService)
        Provider<FirebaseAuthService>(create: (_) => firebaseAuthService),

        // Provide Use Cases
        Provider<SignUpUseCase>(create: (_) => signUpUseCase),
        Provider<SignInUseCase>(create: (_) => signInUseCase),
        Provider<SignOutUseCase>(create: (_) => signOutUseCase),
        Provider<AddItemToCartUseCase>(create: (_) => addItemToCartUseCase),
        Provider<PlaceOrderUseCase>(create: (_) => placeOrderUseCase),
        Provider<GetAllItemsUseCase>(create: (_) => getAllProductsUseCase),

        // Corrected ProfileViewModel instantiation
        ChangeNotifierProvider(
          create:
              (context) => ProfileViewModel(
                Provider.of<UserRepo>(context, listen: false), // First argument
                Provider.of<FirebaseAuthService>(
                  context,
                  listen: false,
                ), // Second argument
              ),
        ),
        // ItemListViewModel instantiation - CORRECTED TO PASS FIREBASEAUTHSERVICE
        ChangeNotifierProvider(
          create:
              (context) => ItemListViewModel(
                Provider.of<ItemRepo>(context, listen: false),
                Provider.of<AddItemToCartUseCase>(context, listen: false),
                Provider.of<FirebaseAuthService>(
                  context,
                  listen: false,
                ), // ADDED THIS ARGUMENT
              ),
        ),
        // CORRECTED CartViewModel instantiation
        ChangeNotifierProvider(
          create:
              (context) => CartViewModel(
                Provider.of<CartRepo>(context, listen: false),
                Provider.of<ItemRepo>(
                  context,
                  listen: false,
                ), // Dependency needed for CartViewModel
                Provider.of<PlaceOrderUseCase>(
                  context,
                  listen: false,
                ), // Dependency needed for CartViewModel
                Provider.of<UserRepo>(context, listen: false),
                Provider.of<FirebaseAuthService>(
                  context,
                  listen: false,
                ), // Add FirebaseAuthService
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => OrderListViewModel(
                Provider.of<OrderItemRepo>(context, listen: false),
                Provider.of<FirebaseAuthService>(
                  context,
                  listen: false,
                ), // Add FirebaseAuthService
              ),
        ),
        // Add more providers here if you have other global services or view models that aren't tied to a specific route.
        // Page-specific ViewModels will be provided in onGenerateRoute as shown in app_router.dart
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
        // Use onGenerateRoute for centralized routing
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.authRoute, // Start at the authentication screen
      ),
    );
  }
}