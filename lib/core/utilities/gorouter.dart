import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/subscribtion/repo/SubscribtionInstitution.dart';
import 'package:qudra_institution/Features/subscribtion/widgets/PaymentView.dart';
import '../../Features/Auth/ViewModel/auth_cubit.dart';
import '../../Features/Auth/forget a password/ForgetPassword.dart';
import '../../Features/Auth/forget a password/ResetPassword.dart';
import '../../Features/Auth/login/login.dart';
import '../../Features/Auth/signup/signup.dart';
import '../../Features/Dashboard/DashboardView.dart';
import '../../Features/Profile/views/institution_profile_view.dart';
import '../../Features/Services/services/Models/service_model.dart';
import '../../Features/Splash/View/splash_view.dart';
import '../../Features/subscribers/SubscribersView.dart';
import '../../Features/subscribers/widgets/Viewprofile.dart';
import '../../Features/subscribtion/subscribtionView.dart';
import '../../Features/subscribtion/viewModel/bundle_cubit.dart';
import '../../Features/subscribtion/viewModel/subscribtion_institution_cubit.dart';
import '../Models/BundleModel.dart';
import '../Models/subscriberModel.dart';
import 'gettit.dart';
import '../../Features/Services/viewmodel/services_cubit.dart';
import '../../Features/Services/views/add_edit_service_view.dart';
import '../../Features/Services/views/services_list_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/institutionSplash',
    routes: [
      // This route opens the custom institution splash experience before login or dashboard.
      GoRoute(
        path: '/institutionSplash',
        builder: (context, state) {
          return const InstitutionSplashView();
        },
      ),
      // Services list route
      GoRoute(
        path: '/services',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<ServicesCubit>(),
            child: const ServicesListView(),
          );
        },
      ),
      // Add service route
      GoRoute(
        path: '/services/add',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<ServicesCubit>(),
            child: const AddEditServiceView(),
          );
        },
      ),
      // Edit service route
      GoRoute(
        path: '/services/edit',
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          // This keeps using the shared ServicesCubit instance without allowing the route provider to close it.
          return BlocProvider.value(
            value: sl<ServicesCubit>(),
            child: AddEditServiceView(existingService: service),
          );
        },
      ),
      // ─────────────────────────────────────────
      // LOGIN
      // ─────────────────────────────────────────
      GoRoute(
        path: '/institutionLogin',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<InstitutionAuthCubit>(),
            child: const InstitutionLoginView(),
          );
        },
      ),
      // ─────────────────────────────────────────
      // SIGN UP
      // ─────────────────────────────────────────
      GoRoute(
        path: '/institutionSignUp',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<InstitutionAuthCubit>(),
            child: const InstitutionSignUpView(),
          );
        },
      ),
      GoRoute(
        path: '/ForgetPassword',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<InstitutionAuthCubit>(),
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: '/ResetPassword',
        builder: (context, state) {
          final email = state.extra as String;
          return BlocProvider.value(
            value: sl<InstitutionAuthCubit>(),
            child: ResetPasswordScreen(email: email),
          );
        },
      ),
      // ─────────────────────────────────────────
      // DASHBOARD
      // ─────────────────────────────────────────
      GoRoute(
        path: '/Dashboard',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const Dashboardview(),
        ),
      ),
      // ─────────────────────────────────────────
      // PROFILE
      // ─────────────────────────────────────────
      // This route opens the institution profile screen from the drawer.
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const InstitutionProfileView(),
        ),
      ),
      // ─────────────────────────────────────────
      // SUBSCRIBERS
      // ─────────────────────────────────────────
      GoRoute(
        path: '/subscribers',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const SubscribersView(),
        ),
      ),
      // router
      GoRoute(
        path: '/viewProfile',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          ViewProfileView(subscriber: state.extra as SubscriberModel),
        ),
      ),
      // In your GoRouter or wherever you push this screen
      GoRoute(
        path: '/subscription',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<BundleCubit>()),
            BlocProvider(create: (_) => sl<SubscriptionInstitutionCubit>()),
          ],
          child: const SubscriptionView(),
        ),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final bundle = state.extra as BundleModel;
          return BlocProvider(
            create: (_) => SubscriptionInstitutionCubit(
              sl<SubscribtionInstitutionRepository>(),
            ),
            child: PaymentView(bundle: bundle),
          );
        },
      ),
    ],
  );

  // ─────────────────────────────────────────
  // ANIMATION BUILDER
  // ─────────────────────────────────────────
  static CustomTransitionPage _buildPageWithAnimation(
      BuildContext context,
      GoRouterState state,
      Widget child,
      ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}