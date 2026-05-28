import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/Models/subscriberModel.dart';
import '../../../core/Models/subscriber_booking_item_model.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/widgets/portal_page_header.dart';
import '../../../core/widgets/portal_responsive_scaffold.dart';
import '../../../core/widgets/responsive_page_shell.dart';
import 'package:go_router/go_router.dart';
import '../repo/SubscriberRepository.dart';

class ViewProfileView extends StatefulWidget {
  final SubscriberModel subscriber;

  const ViewProfileView({super.key, required this.subscriber});

  @override
  State<ViewProfileView> createState() => _ViewProfileViewState();
}

class _ViewProfileViewState extends State<ViewProfileView> {
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

      if (!mounted) return;

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
        _bookingsError = null;
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
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return PortalResponsiveScaffold(
      currentRoute: '/subscribers',
      title: 'Subscriber Profile',
      showMobileAppBar: false,
      body: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: ResponsivePageShell(
            maxWidth: isDesktop ? 1180 : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PortalPageHeader(
                  overline: 'Subscriber Details',
                  title: 'Subscriber Profile',
                  subtitle:
                  'Review subscriber information and bookings linked to your institution.',
                ),
                const SizedBox(height: 24),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 340,
                        child: _buildHeroCard(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildInfoGrid(context),
                            const SizedBox(height: 18),
                            _buildBookingsSection(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildHeroCard(),
                  const SizedBox(height: 18),
                  _buildInfoGrid(context),
                  const SizedBox(height: 18),
                  _buildBookingsSection(),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.email ?? '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          if (s.disabilityType != null && s.disabilityType!.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFC5CEFF),
                borderRadius: BorderRadius.circular(10),
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

  // This widget lays out subscriber info cards responsively.
  Widget _buildInfoGrid(BuildContext context) {
    final cards = [
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
      _buildInfoCard(
        title: 'SUBSCRIPTION',
        items: [
          _InfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: s.subscribedAt != null ? _formatDate(s.subscribedAt!) : null,
          ),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 620
            ? 2
            : 1;
        const spacing = 16.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
              width: itemWidth,
              child: card,
            ),
          )
              .toList(),
        );
      },
    );
  }

  // ─── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.overline),
          const SizedBox(height: 16),
          ...items.map((item) => _buildInfoRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    final value = item.value?.isNotEmpty == true ? item.value! : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // This section shows loading, error, empty state, or the booking list for the selected subscriber.
  Widget _buildBookingsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BOOKINGS', style: AppTextStyles.overline),
          const SizedBox(height: 16),
          if (_loadingBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_bookingsError != null)
            _buildBookingsError()
          else if (_bookings.isEmpty)
              _buildBookingsEmptyState()
            else
              ..._bookings.map((booking) => _buildBookingCard(booking)).toList(),
        ],
      ),
    );
  }

  Widget _buildBookingsError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Text(
        _bookingsError!,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildBookingsEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 38,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No bookings found for this subscriber.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // This card renders a single booking item inside the selected subscriber profile.
  Widget _buildBookingCard(SubscriberBookingItemModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.serviceName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 620;

              final details = [
                _buildBookingInfoRow('Date', _formatDate(booking.requestedDate)),
                _buildBookingInfoRow('Time', booking.requestedTime),
                _buildBookingInfoRow(
                  'Amount',
                  'EGP ${booking.amount.toStringAsFixed(2)}',
                ),
                _buildBookingInfoRow('Method', booking.paymentMethod),
              ];

              if (!isWide) {
                return Column(children: details);
              }

              return Wrap(
                spacing: 16,
                runSpacing: 8,
                children: details
                    .map(
                      (item) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: item,
                  ),
                )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSoft),
            ),
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
        borderRadius: BorderRadius.circular(999),
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
      title: const Text(
        'Subscriber Profile',
        style: AppTextStyles.appBarTitle,
      ),
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