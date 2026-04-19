import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/institution_bookings_service.dart';
import 'institution_bookings_state.dart';

// This cubit loads all bookings related to the current institution services.
class InstitutionBookingsCubit extends Cubit<InstitutionBookingsState> {
  final InstitutionBookingsService _service;

  InstitutionBookingsCubit(this._service)
      : super(InstitutionBookingsInitial());

  // This method fetches all bookings for the current institution services.
  Future<void> loadInstitutionBookings() async {
    emit(InstitutionBookingsLoading());

    try {
      final bookings = await _service.getCurrentInstitutionBookings();

      emit(
        InstitutionBookingsLoaded(bookings: bookings),
      );
    } catch (e) {
      emit(
        InstitutionBookingsError(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}