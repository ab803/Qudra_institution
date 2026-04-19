import '../models/institution_booking_item_model.dart';

// This file defines the states used by the institution bookings page.
abstract class InstitutionBookingsState {}

// This state is emitted before any loading starts.
class InstitutionBookingsInitial extends InstitutionBookingsState {}

// This state is emitted while institution bookings are being loaded.
class InstitutionBookingsLoading extends InstitutionBookingsState {}

// This state is emitted after loading institution bookings successfully.
class InstitutionBookingsLoaded extends InstitutionBookingsState {
  final List<InstitutionBookingItemModel> bookings;

  InstitutionBookingsLoaded({
    required this.bookings,
  });
}

// This state is emitted when loading institution bookings fails.
class InstitutionBookingsError extends InstitutionBookingsState {
  final String errorMessage;

  InstitutionBookingsError({
    required this.errorMessage,
  });
}