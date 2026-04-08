import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Features/Auth/ViewModel/auth_cubit.dart';
import '../../Features/Auth/forget a password/ForgetPassword.dart';
import '../../Features/Auth/forget a password/ResetPassword.dart';
import '../../Features/Auth/login/login.dart';
import '../../Features/Auth/signup/signup.dart';
import '../../Features/Dashboard/DashboardView.dart';
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
      GoRoute(
        path: '/Dashboard',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context, state,  Dashboardview(),
        ),
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