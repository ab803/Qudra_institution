// This model represents a single booking item shown inside a subscriber profile.
class SubscriberBookingItemModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final DateTime requestedDate;
  final String requestedTime;
  final double amount;
  final String bookingStatus;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;

  const SubscriberBookingItemModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.requestedDate,
    required this.requestedTime,
    required this.amount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.createdAt,
  });
}