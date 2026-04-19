import '../../../core/Models/BundleModel.dart';
import '../../../core/supabase/BundleService.dart';


class BundleRepository {
  final BundleService _service;

  BundleRepository(this._service);

  Future<List<BundleModel>> getAllBundles() async {
    try {
      return await _service.fetchAllBundles();
    } catch (e) {
      throw Exception('Failed to fetch bundles: $e');
    }
  }

  Future<BundleModel> getBundleById(int id) async {
    try {
      return await _service.fetchBundleById(id);
    } catch (e) {
      throw Exception('Failed to fetch bundle: $e');
    }
  }

  Future<BundleModel> createBundle(BundleModel bundle) async {
    try {
      return await _service.createBundle(bundle);
    } catch (e) {
      throw Exception('Failed to create bundle: $e');
    }
  }

  Future<BundleModel> updateBundle(BundleModel bundle) async {
    try {
      return await _service.updateBundle(bundle);
    } catch (e) {
      throw Exception('Failed to update bundle: $e');
    }
  }

  Future<void> deleteBundle(int id) async {
    try {
      await _service.deleteBundle(id);
    } catch (e) {
      throw Exception('Failed to delete bundle: $e');
    }
  }
}