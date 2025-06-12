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
import 'package:e_commerce/presentation/authscreen.dart';
import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:e_commerce/presentation/orders/orderlistvm.dart';
import 'package:e_commerce/presentation/seller/seller_dashboard_vm.dart';
import 'package:e_commerce/presentation/seller/seller_registration_vm.dart';
import 'package:e_commerce/presentation/testhome.dart';
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
    // --- Data Layer Services / Repositories ---
    final UserRepo userRepo = UserRepo();
    final ItemRepo itemRepo = ItemRepo();
    final CartRepo cartRepo = CartRepo();
    final OrderItemRepo orderItemRepo = OrderItemRepo();
    final PaymentRepo paymentRepo = PaymentRepo();
    final FirebaseAuthService firebaseAuthService = FirebaseAuthService(
      userRepo,
    );

    // --- Domain Layer Use Cases ---
    final SignUpUseCase signUpUseCase = SignUpUseCase(firebaseAuthService);
    final SignInUseCase signInUseCase = SignInUseCase(firebaseAuthService);
    final SignOutUseCase signOutUseCase = SignOutUseCase(firebaseAuthService);
    final AddItemToCartUseCase addItemToCartUseCase = AddItemToCartUseCase(
      cartRepo,
      itemRepo,
    );
    final PlaceOrderUseCase placeOrderUseCase = PlaceOrderUseCase(
      cartRepo,
      orderItemRepo,
      itemRepo,
      userRepo,
    );
    final GetAllItemsUseCase getAllItemsUseCase = GetAllItemsUseCase(itemRepo);
    final UpgradeToSellerUseCase upgradeToSellerUseCase =
        UpgradeToSellerUseCase(userRepo);

    return MultiProvider(
      providers: [
        // --- Repositories & Services ---
        Provider<UserRepo>.value(value: userRepo),
        Provider<ItemRepo>.value(value: itemRepo),
        Provider<CartRepo>.value(value: cartRepo),
        Provider<OrderItemRepo>.value(value: orderItemRepo),
        Provider<PaymentRepo>.value(value: paymentRepo),
        Provider<FirebaseAuthService>.value(value: firebaseAuthService),

        // --- Use Cases ---
        Provider<SignUpUseCase>.value(value: signUpUseCase),
        Provider<SignInUseCase>.value(value: signInUseCase),
        Provider<SignOutUseCase>.value(value: signOutUseCase),
        Provider<AddItemToCartUseCase>.value(value: addItemToCartUseCase),
        Provider<PlaceOrderUseCase>.value(value: placeOrderUseCase),
        Provider<GetAllItemsUseCase>.value(value: getAllItemsUseCase),
        Provider<UpgradeToSellerUseCase>.value(value: upgradeToSellerUseCase),

        // --- ViewModels (globally accessible) ---
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(context.read<UserRepo>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => ItemListViewModel(
                context.read<ItemRepo>(),
                context.read<AddItemToCartUseCase>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => CartViewModel(
                context.read<CartRepo>(),
                context.read<ItemRepo>(),
                context.read<PlaceOrderUseCase>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => OrderListViewModel(context.read<OrderItemRepo>()),
        ),
        ChangeNotifierProvider(create: (context) => SellerDashboardViewModel()),
        // SellerRegistrationViewModel is provided on its specific route in AppRouter
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
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.authRoute,
      ),
    );
  }
}
