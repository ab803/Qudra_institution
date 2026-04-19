
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_institution/Features/subscribtion/viewModel/subscribtion_institution_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/Models/subscribtionModel.dart';
import '../repo/SubscribtionInstitution.dart';

class SubscriptionInstitutionCubit
    extends Cubit<SubscribtionInstitutionState> {
  final SubscribtionInstitutionRepository _repository;

  SubscriptionInstitutionCubit(this._repository)
      : super(SubscribtionInstitutionInitial());

  Future<void> loadByInstitution(String institutionId) async {
    emit(SubscribtionInstitutionLoading());
    try {
      final subscriptions =
      await _repository.getByInstitution(institutionId);
      emit(SubscribtionInstitutionLoaded(subscriptions));
    } catch (e) {
      emit(SubscribtionInstitutionError(e.toString()));
    }
  }

  Future<void> createSubscription(
      SubscribtionInstitutionmodel model) async {
    emit(SubscribtionInstitutionLoading());
    try {
      final created = await _repository.create(model);
       await Supabase.instance.client
          .from('institutions')
          .update({'subscribed': true})
          .eq('id', model.institutionId)
          .select();
      emit(SubscribtionInstitutionSuccess(created));
    } catch (e) {
      emit(SubscribtionInstitutionError(e.toString()));
    }
  }

  Future<void> updateSubscribtion(
      int id, SubscribtionInstitutionmodel model) async {
    emit(SubscribtionInstitutionLoading());
    try {
      final updated = await _repository.update(id, model);
      emit(SubscribtionInstitutionSuccess(updated));
    } catch (e) {
      emit(SubscribtionInstitutionError(e.toString()));
    }
  }

  Future<void> deleteSubscribtion(int id) async {
    emit(SubscribtionInstitutionLoading());
    try {
      await _repository.delete(id);
      emit(SubscribtionInstitutionInitial());
    } catch (e) {
      emit(SubscribtionInstitutionError(e.toString()));
    }
  }
}