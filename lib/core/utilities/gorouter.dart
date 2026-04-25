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
import '../../Features/Services/services/Models/service_model.dart';
import '../../Features/services/views/ServiceView.dart';
import '../../Features/subscribers/SubscribersView.dart';
import '../../Features/subscribers/widgets/Viewprofile.dart';
import '../../Features/subscribtion/subscribtionView.dart';
import '../../Features/subscribtion/viewModel/bundle_cubit.dart';
import '../../Features/subscribtion/viewModel/subscribtion_institution_cubit.dart';
import '../Models/BundleModel.dart';
import '../Models/subscriberModel.dart';
import 'gettit.dart';
import '../../Features/Bookings/viewmodel/institution_bookings_cubit.dart';
import '../../Features/Bookings/views/institution_bookings_view.dart';


import '../../Features/Services/viewmodel/services_cubit.dart';
import '../../Features/Services/views/add_edit_service_view.dart';
import '../../Features/Services/views/services_list_view.dart';



class AppRouter {
  static final router = GoRouter(
    initialLocation: '/institutionLogin',
    routes: [




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

// Institution bookings route
      GoRoute(
        path: '/bookings',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<InstitutionBookingsCubit>(),
            child: const InstitutionBookingsView(),
          );
        },
      ),

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
          const  ServicesView(),
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