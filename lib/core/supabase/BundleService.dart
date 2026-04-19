import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/BundleModel.dart';


class BundleService {
  final SupabaseClient _client;

  BundleService(this._client);

  static const String _table = 'bundles';

  Future<List<BundleModel>> fetchAllBundles() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BundleModel.fromJson(json))
        .toList();
  }

  Future<BundleModel> fetchBundleById(int id) async {
    final response =
    await _client.from(_table).select().eq('id', id).single();

    return BundleModel.fromJson(response);
  }

  Future<BundleModel> createBundle(BundleModel bundle) async {
    final response = await _client
        .from(_table)
        .insert(bundle.toJson())
        .select()
        .single();

    return BundleModel.fromJson(response);
  }

  Future<BundleModel> updateBundle(BundleModel bundle) async {
    final response = await _client
        .from(_table)
        .update(bundle.toJson())
        .eq('id', bundle.id)
        .select()
        .single();

    return BundleModel.fromJson(response);
  }

  Future<void> deleteBundle(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}