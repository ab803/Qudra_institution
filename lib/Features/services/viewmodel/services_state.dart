import '../services/Models/service_model.dart';


abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  ServicesLoaded({required this.services});
}

class ServicesActionSuccess extends ServicesState {
  final String message;
  ServicesActionSuccess({required this.message});
}

class ServicesError extends ServicesState {
  final String errorMessage;
  ServicesError({required this.errorMessage});
}