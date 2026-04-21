import 'package:supabase_flutter/supabase_flutter.dart';
import 'Models/service_model.dart';

class ServicesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current logged-in institution id
  String? get currentInstitutionId => _supabase.auth.currentUser?.id;

  // Load all services for the current institution
  Future<List<ServiceModel>> fetchMyServices() async {
    final institutionId = currentInstitutionId;
    if (institutionId == null) {
      throw Exception('No logged-in institution found');
    }

    final result = await _supabase
        .from('services')
        .select()
        .eq('institution_id', institutionId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result)
        .map(ServiceModel.fromJson)
        .toList();
  }

  // Add a new service for the current institution
  Future<void> addService(ServiceModel service) async {
    await _supabase.from('services').insert(service.toInsertJson());
  }

  // Update an existing service
  Future<void> updateService(ServiceModel service) async {
    if (service.id == null) {
      throw Exception('Service id is missing for update');
    }

    await _supabase
        .from('services')
        .update(service.toUpdateJson())
        .eq('id', service.id!);
  }

  // Delete a service that belongs to the current institution.
  Future<void> deleteService(String serviceId) async {
    final institutionId = currentInstitutionId;
    if (institutionId == null) {
      throw Exception('No logged-in institution found');
    }

    await _supabase
        .from('services')
        .delete()
        .eq('id', serviceId)
        .eq('institution_id', institutionId);
  }

  // Change active/inactive status
  Future<void> toggleServiceStatus({
    required String serviceId,
    required bool isActive,
  }) async {
    await _supabase
        .from('services')
        .update({'is_active': isActive})
        .eq('id', serviceId);
  }
}