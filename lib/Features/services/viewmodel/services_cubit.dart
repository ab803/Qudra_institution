import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Models/service_model.dart';

import '../services/services_service.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesService _servicesService;

  ServicesCubit(this._servicesService) : super(ServicesInitial());

  // Load all services for current institution
  Future<void> loadMyServices() async {
    emit(ServicesLoading());
    try {
      final services = await _servicesService.fetchMyServices();
      emit(ServicesLoaded(services: services));
    } catch (e) {
      emit(ServicesError(errorMessage: e.toString()));
    }
  }

  // Create a new service then reload the list
  Future<void> createService(ServiceModel service) async {
    emit(ServicesLoading());
    try {
      await _servicesService.addService(service);
      final services = await _servicesService.fetchMyServices();
      emit(ServicesLoaded(services: services));
    } catch (e) {
      emit(ServicesError(errorMessage: e.toString()));
    }
  }

  // Update existing service then reload the list
  Future<void> editService(ServiceModel service) async {
    emit(ServicesLoading());
    try {
      await _servicesService.updateService(service);
      final services = await _servicesService.fetchMyServices();
      emit(ServicesLoaded(services: services));
    } catch (e) {
      emit(ServicesError(errorMessage: e.toString()));
    }
  }

  // Toggle active/inactive then reload the list
  Future<void> changeServiceStatus({
    required String serviceId,
    required bool isActive,
  }) async {
    emit(ServicesLoading());
    try {
      await _servicesService.toggleServiceStatus(
        serviceId: serviceId,
        isActive: isActive,
      );
      final services = await _servicesService.fetchMyServices();
      emit(ServicesLoaded(services: services));
    } catch (e) {
      emit(ServicesError(errorMessage: e.toString()));
    }
  }
}
