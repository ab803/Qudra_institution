import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/subscribtionModel.dart';

class SubscriptionInstitutionService {
  final SupabaseClient _client;
  static const String _table = 'subscription_institution';

  SubscriptionInstitutionService(this._client);

  Future<List<SubscribtionInstitutionmodel>> getByInstitution(
      String institutionId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('institution_id', institutionId);

    return (response as List)
        .map((e) => SubscribtionInstitutionmodel.fromJson(e))
        .toList();
  }

  Future<SubscribtionInstitutionmodel> create(
      SubscribtionInstitutionmodel model) async {
    final response = await _client
        .from(_table)
        .insert(model.toJson())
        .select()
        .single();


    return SubscribtionInstitutionmodel.fromJson(response);
  }

  Future<SubscribtionInstitutionmodel> update(
      int id, SubscribtionInstitutionmodel model) async {
    final response = await _client
        .from(_table)
        .update(model.toJson())
        .eq('id', id)
        .select()
        .single();

    return SubscribtionInstitutionmodel.fromJson(response);
  }

  Future<void> delete(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}