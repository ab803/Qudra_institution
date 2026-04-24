import '../../../core/Models/dashboard_stats_model.dart';


abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  DashboardLoaded(this.stats);
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}