import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/subscriberModel.dart';
import '../Models/subscriber_booking_item_model.dart';

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
        .select(
      'created_at, people_with_disability!user_id(id, full_name, email, phone, disability_type, gender, age)',
    )
    // ↑ tell Supabase which FK to use
        .eq('institution_id', institutionId)
        .range(from, to);

    final List<dynamic> data = response as List<dynamic>;

    // Deduplicate — same person can have multiple bookings
    final seen = <String>{};
    List<SubscriberModel> subscribers = data
        .map((e) => SubscriberModel.fromMap(e as Map<String, dynamic>))
        .where((s) => seen.add(s.id)) // keeps first occurrence only
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
        .eq('institution_id', institutionId)
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

  // This method fetches only the selected subscriber bookings for the current institution.
  Future<List<SubscriberBookingItemModel>> getSubscriberBookings({
    required String institutionId,
    required String subscriberId,
  }) async {
    final bookingsResponse = await _client
        .from('bookings')
        .select(
      'id, service_id, requested_date, requested_time, amount, booking_status, payment_status, payment_method, created_at',
    )
        .eq('institution_id', institutionId)
        .eq('user_id', subscriberId)
        .order('created_at', ascending: false);

    final bookingRows =
    List<Map<String, dynamic>>.from(bookingsResponse as List<dynamic>);

    if (bookingRows.isEmpty) return [];

    final serviceIds = bookingRows
        .map((row) => row['service_id'].toString())
        .toSet()
        .toList();

    final servicesResponse = await _client
        .from('services')
        .select('id, name')
        .inFilter('id', serviceIds);

    final serviceRows =
    List<Map<String, dynamic>>.from(servicesResponse as List<dynamic>);

    final serviceNameById = <String, String>{
      for (final row in serviceRows)
        row['id'].toString(): row['name'].toString(),
    };

    return bookingRows.map((row) {
      return SubscriberBookingItemModel(
        id: row['id'].toString(),
        serviceId: row['service_id'].toString(),
        serviceName:
        serviceNameById[row['service_id'].toString()] ?? 'Unknown Service',
        requestedDate: DateTime.parse(row['requested_date'].toString()),
        requestedTime: row['requested_time'].toString(),
        amount: (row['amount'] as num).toDouble(),
        bookingStatus: row['booking_status'].toString(),
        paymentStatus: row['payment_status'].toString(),
        paymentMethod: row['payment_method'].toString(),
        createdAt: row['created_at'] != null
            ? DateTime.tryParse(row['created_at'].toString())
            : null,
      );
    }).toList();
  }
}