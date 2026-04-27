import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/Dashboard/widgets/PortalDrawer.dart';
import 'package:qudra_institution/Features/subscribers/viewModel/subscribers_cubit.dart';
import 'package:qudra_institution/Features/subscribers/viewModel/subscribers_state.dart';
import '../../core/Models/subscriberModel.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';

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

// ─────────────────────────────────────────────
class _SubscribersBody extends StatefulWidget {
  const _SubscribersBody();

  @override
  State<_SubscribersBody> createState() => _SubscribersBodyState();
}

class _SubscribersBodyState extends State<_SubscribersBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: const PortalDrawer(currentRoute: '/subscribers'),
        appBar: _buildAppBar(),
        body: BlocBuilder<SubscriberCubit, SubscriberState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Subscribers',
                        style: AppTextStyles.largeTitle,
                      ),
                      const Text(
                        'MANAGEMENT & INSIGHTS',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSearchBar(context),
                      const SizedBox(height: 32),

                      // ── CONTENT ──
                      if (state is SubscriberLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (state is SubscriberError)
                        _ErrorCard(message: state.message)
                      else if (state is SubscriberLoaded) ...[
                          if (state.subscribers.isEmpty)
                            const _EmptyState()
                          else ...[
                            ...state.subscribers
                                .map((s) => _SubscriberCard(subscriber: s)),
                            const SizedBox(height: 24),
                            _buildPagination(context, state),
                          ],
                        ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SEARCH
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (v) => context.read<SubscriberCubit>().search(v.trim()),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or phone...',
          prefixIcon:
          const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear,
                color: AppColors.textSecondary),
            onPressed: () {
              _searchController.clear();
              context.read<SubscriberCubit>().search('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PAGINATION (✅ FIXED)
  Widget _buildPagination(
      BuildContext context,
      SubscriberLoaded state,
      ) {
    // ✅ Guard: no pagination when empty
    if (state.totalCount <= 0 || state.subscribers.isEmpty) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<SubscriberCubit>();
    final start = (state.currentPage - 1) * state.pageSize + 1;
    final end =
    (start + state.subscribers.length - 1).clamp(start, state.totalCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $start–$end of ${state.totalCount}\nsubscribers',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
        Row(
          children: [
            _PageBox(
              label: '<',
              enabled: state.hasPrev,
              onTap: cubit.prevPage,
            ),
            for (int i = 1; i <= state.totalPages.clamp(1, 5); i++)
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
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.go('/Dashboard'),
      ),
      title: const Text(
        'Subscribers',
        style: AppTextStyles.appBarTitle,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS
class _SubscriberCard extends StatelessWidget {
  final SubscriberModel subscriber;

  const _SubscriberCard({required this.subscriber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscriber.displayName,
                      style: AppTextStyles.fieldLabel.copyWith(fontSize: 18),
                    ),
                    Text(
                      subscriber.email ?? '—',
                      style: AppTextStyles.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (subscriber.subscribedAt != null) ...[
            const Text(
              'JOINED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subscriber.subscribedAt!.day}/${subscriber.subscribedAt!.month}/${subscriber.subscribedAt!.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // This button opens the selected subscriber profile as a details screen.
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                context.push('/viewProfile', extra: subscriber);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9E9E9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: active
              ? Colors.black
              : enabled
              ? const Color(0xFFF3F3F3)
              : const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(6),
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No subscribers found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
