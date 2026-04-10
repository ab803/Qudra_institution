import 'package:get_it/get_it.dart';

import '../../Features/Auth/repo/InstitutionRepository.dart';
import '../../Features/Auth/repo/InstitutionRepositoryImpl.dart';
import '../../Features/Auth/ViewModel/auth_cubit.dart';
import '../../Features/Services/services/services_service.dart';
import '../../Features/Services/viewmodel/services_cubit.dart';
import '../supabase/institutionservice.dart';

final sl = GetIt.instance;

void setupLocator() {
  // Register institution auth service
  sl.registerLazySingleton<InstitutionService>(
        () => InstitutionService(),
  );

  // Register institution auth repository
  sl.registerLazySingleton<IInstitutionRepository>(
        () => InstitutionRepositoryImpl(
      service: sl<InstitutionService>(),
    ),
  );

  // Register auth cubit
  sl.registerLazySingleton<InstitutionAuthCubit>(
        () => InstitutionAuthCubit(sl<IInstitutionRepository>()),
  );

  // Register services feature service
  sl.registerLazySingleton<ServicesService>(
        () => ServicesService(),
  );

  // Register services cubit
  sl.registerFactory<ServicesCubit>(
        () => ServicesCubit(sl<ServicesService>()),
  );
}