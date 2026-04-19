import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../Dashboard/widgets/PortalDrawer.dart';
import '../viewmodel/institution_bookings_cubit.dart';
import '../viewmodel/institution_bookings_state.dart';

// This screen shows all bookings related to services uploaded by the current institution.
class InstitutionBookingsView extends StatefulWidget {
  const InstitutionBookingsView({super.key});

  @override
  State<InstitutionBookingsView> createState() => _InstitutionBookingsViewState();
}

class _InstitutionBookingsViewState extends State<InstitutionBookingsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // This helper formats the booking date into dd/MM/yyyy.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // This helper maps a booking or payment status to a display color.
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

  @override
  void initState() {
    super.initState();

    // This block loads all institution bookings when the page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstitutionBookingsCubit>().loadInstitutionBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        ),
        title: const Text('QUDRA', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      drawer: const PortalDrawer(currentRoute: 'bookings'),
      body: SafeArea(
        child: BlocBuilder<InstitutionBookingsCubit, InstitutionBookingsState>(
          builder: (context, state) {
            if (state is InstitutionBookingsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is InstitutionBookingsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is InstitutionBookingsLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(
                  child: Text('No bookings found for your services.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<InstitutionBookingsCubit>().loadInstitutionBookings(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: state.bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // This block shows the service title.
                          Text(
                            booking.serviceName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // This block shows booking details.
                          _PortalInfoRow(
                            label: 'Date',
                            value: _formatDate(booking.requestedDate),
                          ),
                          _PortalInfoRow(
                            label: 'Time',
                            value: booking.requestedTime,
                          ),
                          _PortalInfoRow(
                            label: 'Amount',
                            value: 'EGP ${booking.amount.toStringAsFixed(2)}',
                          ),
                          _PortalInfoRow(
                            label: 'Method',
                            value: booking.paymentMethod,
                          ),
                          const SizedBox(height: 14),

                          // This block shows booking and payment statuses.
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PortalStatusChip(
                                label: 'Booking: ${booking.bookingStatus}',
                                color: _statusColor(booking.bookingStatus),
                              ),
                              _PortalStatusChip(
                                label: 'Payment: ${booking.paymentStatus}',
                                color: _statusColor(booking.paymentStatus),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// This widget renders a single portal booking details row.
class _PortalInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PortalInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
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
}

// This widget renders a compact colored status chip inside the institution portal bookings page.
class _PortalStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _PortalStatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}