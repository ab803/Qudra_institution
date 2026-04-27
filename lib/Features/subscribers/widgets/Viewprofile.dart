import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/Models/subscriberModel.dart';
import '../../../core/Models/subscriber_booking_item_model.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PortalDrawer.dart';

import '../repo/SubscriberRepository.dart';


class ViewProfileView extends StatefulWidget {
  final SubscriberModel subscriber;

  const ViewProfileView({super.key, required this.subscriber});

  @override
  State<ViewProfileView> createState() => _ViewProfileViewState();
}

class _ViewProfileViewState extends State<ViewProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SubscriberRepository _repository = GetIt.I<SubscriberRepository>();

  SubscriberModel get s => widget.subscriber;

  bool _loadingBookings = true;
  String? _bookingsError;
  List<SubscriberBookingItemModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // This loads the current subscriber bookings inside the profile screen.
  Future<void> _loadBookings() async {
    try {
      final institutionId = await _repository.getCurrentInstitutionId();

      if (institutionId == null) {
        setState(() {
          _bookingsError = 'Could not resolve institution for this profile.';
          _loadingBookings = false;
        });
        return;
      }

      final bookings = await _repository.getSubscriberBookings(
        institutionId: institutionId,
        subscriberId: s.id,
      );

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _loadingBookings = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _bookingsError = e.toString();
        _loadingBookings = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const PortalDrawer(currentRoute: '/subscribers'),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 24),
          _buildHeroCard(),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'CONTACT',
            items: [
              _InfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: s.email,
              ),
              _InfoItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: s.phone,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'PERSONAL',
            items: [
              _InfoItem(
                icon: Icons.accessible_outlined,
                label: 'Disability Type',
                value: s.disabilityType,
              ),
              _InfoItem(
                icon: Icons.person_outline,
                label: 'Gender',
                value: s.gender,
              ),
              _InfoItem(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: s.age?.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'SUBSCRIPTION',
            items: [
              _InfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Joined',
                value: s.subscribedAt != null
                    ? _formatDate(s.subscribedAt!)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // This card renders the bookings that belong only to the selected subscriber.
          _buildBookingsSection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFF2A2A2A),
            child: Text(
              s.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (s.disabilityType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC5CEFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s.disabilityType!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildInfoRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    final value = item.value?.isNotEmpty == true ? item.value! : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Icon(item.icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This section shows loading, error, empty state, or the booking list for the selected subscriber.
  Widget _buildBookingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOOKINGS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_bookingsError != null)
            Text(
              _bookingsError!,
              style: const TextStyle(color: AppColors.error),
            )
          else if (_bookings.isEmpty)
              const Text(
                'No bookings found for this subscriber.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              ..._bookings.map((booking) => _buildBookingCard(booking)).toList(),
        ],
      ),
    );
  }

  // This card renders a single booking item inside the selected subscriber profile.
  Widget _buildBookingCard(SubscriberBookingItemModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildBookingInfoRow('Date', _formatDate(booking.requestedDate)),
          _buildBookingInfoRow('Time', booking.requestedTime),
          _buildBookingInfoRow(
            'Amount',
            'EGP ${booking.amount.toStringAsFixed(2)}',
          ),
          _buildBookingInfoRow('Method', booking.paymentMethod),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(
                label: 'Booking: ${booking.bookingStatus}',
                color: _statusColor(booking.bookingStatus),
              ),
              _buildStatusChip(
                label: 'Payment: ${booking.paymentStatus}',
                color: _statusColor(booking.paymentStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This row shows a compact booking field inside the subscriber booking card.
  Widget _buildBookingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // This helper maps booking statuses to consistent profile chip colors.
  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value == 'confirmed' || value == 'success') {
      return AppColors.success;
    }

    if (value == 'failed') {
      return AppColors.error;
    }

    if (value == 'pending_payment' || value == 'pending') {
      return Colors.orange;
    }

    return AppColors.textSecondary;
  }

  // This chip renders a compact booking status inside the subscriber profile.
  Widget _buildStatusChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.go('/subscribers'),
      ),
      title:
      const Text('Subscriber Profile', style: AppTextStyles.appBarTitle),
      centerTitle: true,
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
