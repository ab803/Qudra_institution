
import '../../../core/Models/subscriberModel.dart';

abstract class SubscriberState {}

class SubscriberInitial extends SubscriberState {}

class SubscriberLoading extends SubscriberState {}

class SubscriberLoaded extends SubscriberState {
  final List<SubscriberModel> subscribers;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String searchQuery;

  SubscriberLoaded({
    required this.subscribers,
    required this.totalCount,
    required this.currentPage,
    this.pageSize = 10,
    this.searchQuery = '',
  });

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);
  bool get hasPrev => currentPage > 1;
  bool get hasNext => currentPage < totalPages;

  SubscriberLoaded copyWith({
    List<SubscriberModel>? subscribers,
    int? totalCount,
    int? currentPage,
    String? searchQuery,
  }) {
    return SubscriberLoaded(
      subscribers: subscribers ?? this.subscribers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SubscriberError extends SubscriberState {
  final String message;
  SubscriberError(this.message);
}