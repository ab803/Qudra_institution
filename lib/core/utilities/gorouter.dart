import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Features/Auth/ViewModel/auth_cubit.dart';
import '../../Features/Auth/forget a password/ForgetPassword.dart';
import '../../Features/Auth/forget a password/ResetPassword.dart';
import '../../Features/Auth/login/login.dart';
import '../../Features/Auth/signup/signup.dart';
import '../../Features/Dashboard/DashboardView.dart';
import '../../Features/Services/viewmodel/services_cubit.dart';
import '../../Features/Services/views/add_edit_service_view.dart';
import '../../Features/Services/views/services_list_view.dart';
import '../Models/service_model.dart';
import 'gettit.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/institutionLogin',
    routes: [
      GoRoute(
        path: '/institutionLogin',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<InstitutionAuthCubit>(),
            child: const InstitutionLoginView(),
          );
        },
      ),
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
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPageWithAnimation(
          context,
          state,
          const Dashboardview(),
        ),
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
          return BlocProvider(
            create: (_) => sl<ServicesCubit>(),
            child: AddEditServiceView(existingService: service),
          );
        },
      ),
    ],
  );

  // Build animated page transition
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