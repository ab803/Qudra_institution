
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Models/BundleModel.dart';
import '../repo/BundleRepo.dart';


part 'bundle_state.dart';

class BundleCubit extends Cubit<BundleState> {
  final BundleRepository _repository;

  BundleCubit(this._repository) : super(BundleInitial());

  Future<void> loadBundles() async {
    emit(BundleLoading());
    try {
      final bundles = await _repository.getAllBundles();
      emit(BundleLoaded(bundles));
    } catch (e) {
      emit(BundleError(e.toString()));
    }
  }

  Future<void> createBundle(BundleModel bundle) async {
    emit(BundleLoading());
    try {
      await _repository.createBundle(bundle);
      emit(BundleActionSuccess('Bundle created successfully'));
      await loadBundles();
    } catch (e) {
      emit(BundleError(e.toString()));
    }
  }

  Future<void> updateBundle(BundleModel bundle) async {
    emit(BundleLoading());
    try {
      await _repository.updateBundle(bundle);
      emit(BundleActionSuccess('Bundle updated successfully'));
      await loadBundles();
    } catch (e) {
      emit(BundleError(e.toString()));
    }
  }

  Future<void> deleteBundle(int id) async {
    emit(BundleLoading());
    try {
      await _repository.deleteBundle(id);
      emit(BundleActionSuccess('Bundle deleted successfully'));
      await loadBundles();
    } catch (e) {
      emit(BundleError(e.toString()));
    }
  }
}