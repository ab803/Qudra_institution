import '../../../core/Models/subscribtionModel.dart';
import '../../../core/supabase/subscribtionService.dart';


class SubscribtionInstitutionRepository {
  final SubscriptionInstitutionService _service;

  SubscribtionInstitutionRepository(this._service);

  Future<List<SubscribtionInstitutionmodel>> getByInstitution(
      String institutionId) async {
    try {
      return await _service.getByInstitution(institutionId);
    } catch (e) {
      throw Exception('Failed to fetch subscriptions: $e');
    }
  }

  Future<SubscribtionInstitutionmodel> create(
      SubscribtionInstitutionmodel model) async {
    try {
      return await _service.create(model);
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<SubscribtionInstitutionmodel> update(
      int id, SubscribtionInstitutionmodel model) async {
    try {
      return await _service.update(id, model);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      throw Exception('Failed to delete subscription: $e');
    }
  }
}