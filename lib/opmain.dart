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
import 'package:e_commerce/data/usecases/user/upgrade_to_seller_usecase.dart';
import 'package:e_commerce/presentation/auth_gate.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
// import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:e_commerce/presentation/orders/orderlistvm.dart';
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- DATA LAYER: REPOSITORIES & SERVICES ---
        Provider<UserRepo>(create: (_) => UserRepo()),
        Provider<ItemRepo>(create: (_) => ItemRepo()),
        Provider<CartRepo>(create: (_) => CartRepo()),
        Provider<OrderItemRepo>(create: (_) => OrderItemRepo()),
        Provider<PaymentRepo>(create: (_) => PaymentRepo()),
        Provider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(context.read<UserRepo>()),
        ),

        // --- DOMAIN LAYER: USE CASES ---
        Provider<SignUpUseCase>(
          create:
              (context) => SignUpUseCase(context.read<FirebaseAuthService>()),
        ),
        Provider<SignInUseCase>(
          create:
              (context) => SignInUseCase(context.read<FirebaseAuthService>()),
        ),
        Provider<SignOutUseCase>(
          create:
              (context) => SignOutUseCase(context.read<FirebaseAuthService>()),
        ),
        Provider<GetAllItemsUseCase>(
          create: (context) => GetAllItemsUseCase(context.read<ItemRepo>()),
        ),
        Provider<AddItemToCartUseCase>(
          create:
              (context) => AddItemToCartUseCase(
                context.read<CartRepo>(),
                context.read<ItemRepo>(),
              ),
        ),
        Provider<PlaceOrderUseCase>(
          create:
              (context) => PlaceOrderUseCase(
                context.read<CartRepo>(),
                context.read<OrderItemRepo>(),
                context.read<ItemRepo>(),
                context.read<UserRepo>(),
              ),
        ),
        // ** NEW: Provide the UpgradeToSellerUseCase **
        Provider<UpgradeToSellerUseCase>(
          create: (context) => UpgradeToSellerUseCase(context.read<UserRepo>()),
        ),

        // // --- PRESENTATION LAYER: VIEW MODELS ---
        // ChangeNotifierProvider<ProfilePage>(
        //   create:
        //       (context) => ProfileViewModel(
        //         userRepository: context.read<UserRepo>(),
        //         signOutUseCase: context.read<SignOutUseCase>(),
        //       ),
        // ),
        // ChangeNotifierProvider<ItemListViewModel>(
        //   create:
        //       (context) => ItemListViewModel(
        //         context.read<ItemRepo>(),
        //         context.read<AddItemToCartUseCase>(),
        //       ),
        // ),
        ChangeNotifierProvider<CartViewModel>(
          create:
              (context) => CartViewModel(
                context.read<CartRepo>(),
                context.read<ItemRepo>(),
                context.read<PlaceOrderUseCase>(),
              ),
        ),
        ChangeNotifierProvider<OrderListViewModel>(
          create:
              (context) => OrderListViewModel(context.read<OrderItemRepo>()),
        ),
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
        // Use an AuthGate to handle the initial screen logic
        home: const AuthGate(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
