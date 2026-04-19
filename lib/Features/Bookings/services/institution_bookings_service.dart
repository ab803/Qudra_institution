import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/institution_booking_item_model.dart';

// This service loads all bookings related to the current institution's uploaded services.
class InstitutionBookingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // This method returns all bookings belonging to services uploaded by the current institution.
  Future<List<InstitutionBookingItemModel>> getCurrentInstitutionBookings() async {
    final currentInstitution = _supabase.auth.currentUser;
    if (currentInstitution == null) {
      throw Exception('Institution is not logged in.');
    }

    // This block loads all active services uploaded by the current institution.
    final serviceRows = List<Map<String, dynamic>>.from(
      await _supabase
          .from('services')
          .select('id, name')
          .eq('institution_id', currentInstitution.id)
          .order('created_at', ascending: false),
    );

    if (serviceRows.isEmpty) return [];

    final serviceIds = serviceRows
        .map((row) => row['id'].toString())
        .toList();

    final serviceNameById = <String, String>{
      for (final row in serviceRows)
        row['id'].toString(): row['name'].toString(),
    };

    // This block loads all bookings related to the institution services.
    final bookingRows = List<Map<String, dynamic>>.from(
      await _supabase
          .from('bookings')
          .select(
        'id, service_id, requested_date, requested_time, amount, booking_status, payment_status, payment_method, created_at',
      )
          .inFilter('service_id', serviceIds)
          .order('created_at', ascending: false),
    );

    // This block maps raw booking rows into UI-friendly portal booking items.
    return bookingRows.map((row) {
      return InstitutionBookingItemModel(
        id: row['id'].toString(),
        serviceId: row['service_id'].toString(),
        serviceName:
        serviceNameById[row['service_id'].toString()] ??
            'Unknown Service',
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