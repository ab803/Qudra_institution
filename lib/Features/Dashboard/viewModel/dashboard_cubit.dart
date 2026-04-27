import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/DashboardRepository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;
  String? _loadedInstitutionId;

  DashboardCubit(this._repo) : super(DashboardInitial());

  // This loads dashboard stats only when needed and avoids full-screen reloading for cached data.
  Future<void> loadStats(
      String institutionId, {
        bool forceRefresh = false,
      }) async {
    final hasCachedData =
        state is DashboardLoaded && _loadedInstitutionId == institutionId;

    if (!forceRefresh && hasCachedData) {
      return;
    }

    if (!hasCachedData) {
      emit(DashboardLoading());
    }

    try {
      final stats = await _repo.fetchStats(institutionId);
      _loadedInstitutionId = institutionId;
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
