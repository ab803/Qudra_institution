import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/DashboardRepository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repo;
  DashboardCubit(this._repo) : super(DashboardInitial());

  Future<void> loadStats(String institutionId) async {
    emit(DashboardLoading());
    try {
      final stats = await _repo.fetchStats(institutionId);
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}