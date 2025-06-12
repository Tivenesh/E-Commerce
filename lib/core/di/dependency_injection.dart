import 'package:e_commerce/domain/models/user.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/user_repo.dart';
import '../../data/usecases/auth/register_seller_usecase.dart';
import '../../presentation/users/profilevm.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  // Repositories
  getIt.registerLazySingleton<UserRepo>(() => UserRepo());

  // Use Cases
  getIt.registerLazySingleton<RegisterSellerUseCase>(
    () => RegisterSellerUseCase(getIt<UserRepo>()),
  );

  // ViewModels
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(getIt<UserRepo>(), getIt<RegisterSellerUseCase>()),
  );
}

// Alternative setup if you're not using get_it
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  // Repositories
  late final UserRepo _UserRepo = UserRepo();

  // Use Cases
  late final RegisterSellerUseCase _registerSellerUseCase =
      RegisterSellerUseCase(_UserRepo);

  // Getters
  UserRepo get userRepositUory => _UserRepo;
  RegisterSellerUseCase get registerSellerUseCase => _registerSellerUseCase;

  // ViewModels factory
  ProfileViewModel createProfileViewModel() {
    return ProfileViewModel(_UserRepo, _registerSellerUseCase);
  }
}
