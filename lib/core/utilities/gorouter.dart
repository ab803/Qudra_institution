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
import '../../Features/Setting/SettingView.dart';
import '../../Features/services/ServiceView.dart';
import '../../Features/subscribers/SubscribersView.dart';
import '../../Features/subscribtion/subscribtionView.dart';
import '../../Features/subscribtion/viewModel/bundle_cubit.dart';
import '../../Features/subscribtion/viewModel/subscribtion_institution_cubit.dart';
import '../Models/BundleModel.dart';
import 'gettit.dart';



class AppRouter {
  static final router = GoRouter(
    initialLocation: '/institutionLogin',
    routes: [

      // ─────────────────────────────────────────
      // LOGIN
      // ─────────────────────────────────────────
      GoRoute(
          path: '/institutionLogin',
          builder: (context, state) {

            return BlocProvider.value(
              value: sl<InstitutionAuthCubit>(), // pulled from GetIt
              child: const InstitutionLoginView(),
            );
          }),

      // ─────────────────────────────────────────
      // SIGN UP
      // ─────────────────────────────────────────
      GoRoute(
          path: '/institutionSignUp',
          builder: (context, state) {

            return BlocProvider.value(
              value: sl<InstitutionAuthCubit>(), // pulled from GetIt
              child: const InstitutionSignUpView(),
            );
          }
      ),

      GoRoute(
          path: '/ForgetPassword',
          builder: (context, state) {

            return BlocProvider.value(
              value: sl<InstitutionAuthCubit>(), // pulled from GetIt
              child: const ForgotPasswordScreen(),
            );
          }),
      GoRoute(
          path: '/ResetPassword',
          builder: (context, state) {
            final email = state.extra as String;

            return BlocProvider.value(
              value: sl<InstitutionAuthCubit>(), // pulled from GetIt
              child: ResetPasswordScreen(email: email,),
            );
          }),



      // ─────────────────────────────────────────
      // HOME  (uncomment when view is ready)
      // ─────────────────────────────────────────
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
// SERVICES
// ─────────────────────────────────────────
      GoRoute(
        path: '/services',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const ServicesView(),
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

// ─────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const SettingsView(),
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
        )
      ),

      GoRoute(
        path: "/payment",
        builder: (context, state) {
          final bundle = state.extra as BundleModel;
          return BlocProvider(
            create: (_) => SubscriptionInstitutionCubit(sl<SubscribtionInstitutionRepository                      >()),
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