// subscription_institution_state.dart
import '../../../core/Models/subscribtionModel.dart';


abstract class SubscribtionInstitutionState {}

class SubscribtionInstitutionInitial extends SubscribtionInstitutionState {}

class SubscribtionInstitutionLoading extends SubscribtionInstitutionState {}

class SubscribtionInstitutionLoaded extends SubscribtionInstitutionState {
  final List<SubscribtionInstitutionmodel> subscribtions;
  SubscribtionInstitutionLoaded(this.subscribtions);
}

class SubscribtionInstitutionSuccess extends SubscribtionInstitutionState {
  final SubscribtionInstitutionmodel subscription;
  SubscribtionInstitutionSuccess(this.subscription);
}

class SubscribtionInstitutionError extends SubscribtionInstitutionState {
  final String message;
  SubscribtionInstitutionError(this.message);
}