import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/subscriberModel.dart';


class SubscriberService {
  final SupabaseClient _client;

  SubscriberService(this._client);

  /// Fetch all subscribers for the given institution, with optional search.
  Future<List<SubscriberModel>> getSubscribers({
    required String institutionId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final response = await _client
        .from('bookings')
        .select('created_at, people_with_disability!user_id(id, full_name, email, phone, disability_type, gender, age)')
    //                                             ↑ tell Supabase which FK to use
        .eq('institution_id', institutionId)
        .range(from, to);

    final List<dynamic> data = response as List<dynamic>;

    // Deduplicate — same person can have multiple bookings
    final seen = <String>{};
    List<SubscriberModel> subscribers = data
        .map((e) => SubscriberModel.fromMap(e as Map<String, dynamic>))
        .where((s) => seen.add(s.id))   // keeps first occurrence only
        .toList();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      subscribers = subscribers.where((s) {
        return (s.fullName?.toLowerCase().contains(q) ?? false) ||
            (s.email?.toLowerCase().contains(q) ?? false) ||
            (s.phone?.contains(q) ?? false);
      }).toList();
    }

    return subscribers;
  }

  Future<int> getSubscriberCount({required String institutionId}) async {
    final response = await _client
        .from('bookings')
        .select('id')
        .eq('institution_id', institutionId)   // ← was empty string
        .count(CountOption.exact);

    return response.count;
  }
  /// Fetch the institution ID belonging to the currently logged-in admin user.
  Future<String?> getCurrentInstitutionId() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('institutions')
        .select('id')
        .eq('email', user.email ?? '')
        .maybeSingle();

    return response?['id'] as String?;
  }
}