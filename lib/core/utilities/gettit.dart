import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Features/Auth/repo/InstitutionRepository.dart';
import '../../Features/Auth/repo/InstitutionRepositoryImpl.dart';
import '../../Features/Auth/ViewModel/auth_cubit.dart'; // ← lowercase 'v'
import '../../Features/Dashboard/repo/DashboardRepository.dart';
import '../../Features/Dashboard/viewModel/dashboard_cubit.dart';
import '../../Features/subscribers/repo/SubscriberRepository.dart';
import '../../Features/subscribers/viewModel/subscribers_cubit.dart';
import '../../Features/subscribtion/repo/BundleRepo.dart';
import '../../Features/subscribtion/repo/SubscribtionInstitution.dart';
import '../../Features/subscribtion/viewModel/bundle_cubit.dart';
import '../../Features/subscribtion/viewModel/subscribtion_institution_cubit.dart';
import '../supabase/BundleService.dart';
import '../supabase/SubscriberService.dart';
import '../supabase/institutionservice.dart';
import '../supabase/subscribtionService.dart';
import '../../Features/Services/services/services_service.dart';
import '../../Features/Services/viewmodel/services_cubit.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<SupabaseClient>(
        () => Supabase.instance.client, // ← ADD THIS FIRST
  );

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
  sl.registerLazySingleton<InstitutionAuthCubit>(
    // ✅ singleton, not factory
        () => InstitutionAuthCubit(sl<IInstitutionRepository>()),
  );

  // In your service_locator.dart
  sl.registerLazySingleton<SubscriptionInstitutionService>(
        () => SubscriptionInstitutionService(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<SubscribtionInstitutionRepository>(
        () => SubscribtionInstitutionRepository(
      sl<SubscriptionInstitutionService>(),
    ),
  );

  // Factory since it holds transient UI state
  sl.registerFactory<SubscriptionInstitutionCubit>(
        () => SubscriptionInstitutionCubit(
      sl<SubscribtionInstitutionRepository>(),
    ),
  );

  // Register services feature service
  sl.registerLazySingleton<ServicesService>(
        () => ServicesService(),
  );

// This creates a fresh services cubit for each services route to avoid using a closed instance.
  sl.registerFactory<ServicesCubit>(
        () => ServicesCubit(sl<ServicesService>()),
  );


  // This keeps the dashboard repository available through GetIt.
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepository(sl<SupabaseClient>()),
  );

  // This keeps the dashboard cubit alive to avoid full dashboard reloads on every return.
  sl.registerLazySingleton<DashboardCubit>(
        () => DashboardCubit(sl<DashboardRepository>()),
  );

  // ─────────────── BUNDLE ─────────────────
  sl.registerLazySingleton<BundleService>(
        () => BundleService(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<BundleRepository>(
        () => BundleRepository(sl<BundleService>()),
  );

  sl.registerFactory<BundleCubit>(
        () => BundleCubit(sl<BundleRepository>()),
  );

  // ── Add to your existing injection_container.dart / service_locator.dart ──
  // 1. Service
  sl.registerLazySingleton<SubscriberService>(
        () => SubscriberService(sl<SupabaseClient>()),
  );

  // 2. Repository
  sl.registerLazySingleton<SubscriberRepository>(
        () => SubscriberRepository(sl<SubscriberService>()),
  );

  // 3. Cubit ← registerFactory so each navigation creates a fresh instance
  sl.registerFactory<SubscriberCubit>(
        () => SubscriberCubit(sl<SubscriberRepository>()),
  );
}