import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/feed/presentation/bloc/feed_bloc.dart';
import '../../features/ai_moderation/presentation/bloc/ai_moderation_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(getIt()));
  getIt.registerFactory(() => FeedBloc());
  getIt.registerFactory(() => AiModerationBloc());
}