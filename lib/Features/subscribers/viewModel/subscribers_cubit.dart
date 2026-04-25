import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_institution/Features/subscribers/viewModel/subscribers_state.dart';

import '../repo/SubscriberRepository.dart';


class SubscriberCubit extends Cubit<SubscriberState> {
  final SubscriberRepository _repository;
  String? _institutionId;

  SubscriberCubit(this._repository) : super(SubscriberInitial());

  // ─── Bootstrap ───────────────────────────────────────────────

  /// Call once from the UI's initState.
  Future<void> init() async {
    emit(SubscriberLoading());
    try {
      _institutionId = await _repository.getCurrentInstitutionId();
      if (_institutionId == null) {
        emit(SubscriberError('Could not resolve institution. Please log in again.'));
        return;
      }
      await _loadPage(page: 1);
    } catch (e) {
      emit(SubscriberError(e.toString()));
    }
  }

  // ─── Public Actions ──────────────────────────────────────────

  Future<void> search(String query) async {
    if (_institutionId == null) return;
    emit(SubscriberLoading());
    await _loadPage(page: 1, searchQuery: query);
  }

  Future<void> goToPage(int page) async {
    final current = state;
    if (current is! SubscriberLoaded) return;
    if (page < 1 || page > current.totalPages) return;
    emit(SubscriberLoading());
    await _loadPage(page: page, searchQuery: current.searchQuery);
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is SubscriberLoaded && current.hasNext) {
      await goToPage(current.currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    final current = state;
    if (current is SubscriberLoaded && current.hasPrev) {
      await goToPage(current.currentPage - 1);
    }
  }

  // ─── Private ─────────────────────────────────────────────────

  Future<void> _loadPage({required int page, String searchQuery = ''}) async {
    try {
      final results = await Future.wait([
        _repository.getSubscribers(
          institutionId: _institutionId!,
          searchQuery: searchQuery,
          page: page,
        ),
        _repository.getSubscriberCount(institutionId: _institutionId!),
      ]);

      emit(SubscriberLoaded(
        subscribers: results[0] as dynamic,
        totalCount: results[1] as int,
        currentPage: page,
        searchQuery: searchQuery,
      ));
    } catch (e) {
      emit(SubscriberError(e.toString()));
    }
  }
}