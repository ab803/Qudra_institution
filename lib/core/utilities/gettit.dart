import 'package:get_it/get_it.dart';
import '../../Features/Auth/repo/InstitutionRepository.dart';
import '../../Features/Auth/repo/InstitutionRepositoryImpl.dart';
import '../../Features/Auth/ViewModel/auth_cubit.dart';  // ← lowercase 'v'
import '../supabase/institutionservice.dart';

final sl = GetIt.instance;

void setupLocator() {
  // ─────────────── SERVICES ───────────────
  sl.registerLazySingleton<InstitutionService>(
        () => InstitutionService(),
  );

  // ─────────────── REPOSITORY ─────────────
  sl.registerLazySingleton<IInstitutionRepository>(
        () => InstitutionRepositoryImpl(
      service: sl<InstitutionService>(),
    ),
  );

  // ─────────────── CUBIT ──────────────────
  sl.registerLazySingleton<InstitutionAuthCubit>(   // ✅ singleton, not factory
        () => InstitutionAuthCubit(sl<IInstitutionRepository>()),
  );
}