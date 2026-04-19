// bundle_state.dart
part of 'bundle_cubit.dart';

sealed class BundleState {}

final class BundleInitial extends BundleState {}

final class BundleLoading extends BundleState {}

final class BundleLoaded extends BundleState {
  final List<BundleModel> bundles;
  BundleLoaded(this.bundles);
}

final class BundleActionSuccess extends BundleState {
  final String message;
  BundleActionSuccess(this.message);
}

final class BundleError extends BundleState {
  final String message;
  BundleError(this.message);
}