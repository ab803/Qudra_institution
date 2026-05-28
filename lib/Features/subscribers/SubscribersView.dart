import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/subscribers/viewModel/subscribers_cubit.dart';
import 'package:qudra_institution/Features/subscribers/viewModel/subscribers_state.dart';
import '../../core/Models/subscriberModel.dart';
import '../../core/responsive/responsive_helper.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';
import '../../core/widgets/portal_page_header.dart';
import '../../core/widgets/portal_responsive_scaffold.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../core/widgets/responsive_page_shell.dart';

class SubscribersView extends StatelessWidget {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SubscriberCubit>()..init(),
      child: const _SubscribersBody(),
    );
  }
}

class _SubscribersBody extends StatefulWidget {
  const _SubscribersBody();

  @override
  State<_SubscribersBody> createState() => _SubscribersBodyState();
}

class _SubscribersBodyState extends State<_SubscribersBody> {
  final TextEditingController _searchController = TextEditingController();

  Future<bool> _onWillPop() async {
    context.go('/Dashboard');
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: PortalResponsiveScaffold(
        currentRoute: '/subscribers',
        title: 'Subscribers',
        body: BlocBuilder<SubscriberCubit, SubscriberState>(
          builder: (context, state) {
            return ResponsivePageShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PortalPageHeader(
                    overline: 'Management & Insights',
                    title: 'Subscribers',
                    subtitle:
                    'Review the users who booked services with your institution and open detailed booking profiles.',
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  if (state is SubscriberLoading)
                    const _SubscribersLoadingState()
                  else if (state is SubscriberError)
                    _ErrorCard(
                      message: state.message,
                      onRetry: () => context.read<SubscriberCubit>().init(),
                    )
                  else if (state is SubscriberLoaded) ...[
                      _buildResultSummary(state),
                      const SizedBox(height: 16),
                      if (state.subscribers.isEmpty)
                        const _EmptyState()
                      else ...[
                        _buildSubscribersGrid(context, state.subscribers),
                        const SizedBox(height: 24),
                        _buildPagination(context, state),
                      ],
                    ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (v) => context.read<SubscriberCubit>().search(v.trim()),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or phone...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
            onPressed: () {
              _searchController.clear();
              context.read<SubscriberCubit>().search('');
              setState(() {});
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSummary(SubscriberLoaded state) {
    final start = state.totalCount <= 0
        ? 0
        : (state.currentPage - 1) * state.pageSize + 1;
    final end = state.totalCount <= 0
        ? 0
        : (start + state.subscribers.length - 1).clamp(start, state.totalCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.searchQuery.trim().isEmpty
                  ? 'Showing $start–$end of ${state.totalCount} subscribers'
                  : 'Showing $start–$end of ${state.totalCount} subscribers for "${state.searchQuery}"',
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.textSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersGrid(
      BuildContext context,
      List<SubscriberModel> subscribers,
      ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      wideDesktopColumns: 3,
      childAspectRatio: isDesktop ? 1.45 : 1.35,
      spacing: 18,
      runSpacing: 18,
      children: subscribers
          .map((subscriber) => _SubscriberCard(subscriber: subscriber))
          .toList(),
    );
  }

  Widget _buildPagination(BuildContext context, SubscriberLoaded state) {
    if (state.totalCount <= 0 || state.subscribers.isEmpty) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<SubscriberCubit>();
    final visiblePages = state.totalPages.clamp(1, 5).toInt();
    final isMobile = ResponsiveHelper.isMobile(context);

    final paginationControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageBox(
          label: '<',
          enabled: state.hasPrev,
          onTap: cubit.prevPage,
        ),
        for (int i = 1; i <= visiblePages; i++)
          _PageBox(
            label: '$i',
            active: i == state.currentPage,
            onTap: () => cubit.goToPage(i),
          ),
        _PageBox(
          label: '>',
          enabled: state.hasNext,
          onTap: cubit.nextPage,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: paginationControls,
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Page ${state.currentPage} of ${state.totalPages}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          paginationControls,
        ],
      ),
    );
  }
}

class _SubscriberCard extends StatelessWidget {
  final SubscriberModel subscriber;

  const _SubscriberCard({required this.subscriber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black,
                child: Text(
                  subscriber.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscriber.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subscriber.email ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (subscriber.disabilityType != null &&
                  subscriber.disabilityType!.trim().isNotEmpty)
                _InfoChip(
                  icon: Icons.accessible_outlined,
                  label: subscriber.disabilityType!,
                ),
              if (subscriber.phone != null && subscriber.phone!.trim().isNotEmpty)
                _InfoChip(
                  icon: Icons.phone_outlined,
                  label: subscriber.phone!,
                ),
              if (subscriber.subscribedAt != null)
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label:
                  '${subscriber.subscribedAt!.day}/${subscriber.subscribedAt!.month}/${subscriber.subscribedAt!.year}',
                ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                context.push('/viewProfile', extra: subscriber);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageBox extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback? onTap;

  const _PageBox({
    required this.label,
    this.active = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? Colors.black
              : enabled
              ? const Color(0xFFF3F3F3)
              : const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : enabled
                ? Colors.black
                : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
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
              Icons.people_outline,
              size: 42,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No subscribers found',
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscribers will appear here after users book your services.',
            style: AppTextStyles.pageDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SubscribersLoadingState extends StatelessWidget {
  const _SubscribersLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
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
    );
  }
}