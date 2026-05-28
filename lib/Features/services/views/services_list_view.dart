import 'package:flutter/material.dart';
import '../../../core/styles/AppColors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/widgets/portal_page_header.dart';
import '../../../core/widgets/portal_responsive_scaffold.dart';
import '../../../core/widgets/responsive_page_shell.dart';
import '../viewmodel/services_cubit.dart';
import '../viewmodel/services_state.dart';
import '../widgets/service_card.dart';

import 'package:go_router/go_router.dart';
import '../../../core/responsive/responsive_helper.dart';


class ServicesListView extends StatefulWidget {
  const ServicesListView({super.key});

  @override
  State<ServicesListView> createState() => _ServicesListViewState();
}

class _ServicesListViewState extends State<ServicesListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesCubit>().loadMyServices();
    });
  }

  // This dialog asks the institution to confirm deleting the selected service.
  Future<void> _confirmDeleteService({
    required String serviceId,
    required String serviceName,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Service',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$serviceName"? This action cannot be undone.',
            style: const TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      context.read<ServicesCubit>().deleteService(serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return PortalResponsiveScaffold(
      currentRoute: '/services',
      title: 'Services',
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // This opens the add service screen and refreshes the list only after a successful create.
        onPressed: () async {
          final didChange = await context.push<bool>('/services/add');

          if (didChange == true && mounted) {
            context.read<ServicesCubit>().loadMyServices();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state is ServicesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServicesError) {
              return _ServicesErrorState(
                message: state.errorMessage,
                onRetry: () => context.read<ServicesCubit>().loadMyServices(),
              );
            }

            if (state is ServicesLoaded) {
              return ResponsivePageShell(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 18 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: isMobile ? 20 : 24),
                    if (state.services.isEmpty)
                      _emptyState(context)
                    else
                      _buildServicesWrap(context, state),
                    SizedBox(height: isMobile ? 90 : 32),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      return PortalPageHeader(
        overline: 'Service Management',
        title: 'My Services',
        subtitle: 'Create, edit, and manage the services available to Qudra users.',
        trailing: ElevatedButton.icon(
          onPressed: () async {
            final didChange = await context.push<bool>('/services/add');

            if (didChange == true && mounted) {
              context.read<ServicesCubit>().loadMyServices();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Service',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    // This compact mobile header keeps the services screen readable without pushing the cards too far down.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICE MANAGEMENT',
          style: AppTextStyles.overline.copyWith(
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'My Services',
          style: AppTextStyles.screenTitle.copyWith(
            fontSize: 30,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Create, edit, and manage the services available to Qudra users.',
          style: AppTextStyles.pageDescription.copyWith(
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesWrap(BuildContext context, ServicesLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 1250
            ? 3
            : width >= 820
            ? 2
            : 1;

        final spacing = columns == 1 ? 14.0 : 18.0;
        final cardWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: state.services.map((service) {
            return SizedBox(
              width: cardWidth,
              child: ServiceCard(
                service: service,
                onEdit: () async {
                  if (service.id == null) return;

                  // This opens the edit service screen and refreshes the list only after a successful update.
                  final didChange = await context.push<bool>(
                    '/services/edit',
                    extra: service,
                  );

                  if (didChange == true && mounted) {
                    context.read<ServicesCubit>().loadMyServices();
                  }
                },
                onToggleStatus: () {
                  if (service.id == null) return;

                  context.read<ServicesCubit>().changeServiceStatus(
                    serviceId: service.id!,
                    isActive: !service.isActive,
                  );
                },
                onDelete: () {
                  if (service.id == null) return;

                  _confirmDeleteService(
                    serviceId: service.id!,
                    serviceName: service.name,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 22,
        vertical: isDesktop ? 64 : 42,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.layers_outlined,
              size: 38,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No services added yet',
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first service to start receiving bookings from Qudra users.',
            style: AppTextStyles.pageDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () async {
              final didChange = await context.push<bool>('/services/add');

              if (didChange == true && mounted) {
                context.read<ServicesCubit>().loadMyServices();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Service'),
          ),
        ],
      ),
    );
  }
}

class _ServicesErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ServicesErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Failed to load services',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
