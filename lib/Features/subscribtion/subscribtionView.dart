import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_institution/Features/subscribtion/viewModel/bundle_cubit.dart';
import 'package:qudra_institution/Features/subscribtion/viewModel/subscribtion_institution_cubit.dart';
import 'package:qudra_institution/Features/subscribtion/viewModel/subscribtion_institution_state.dart';
import '../../../core/Models/BundleModel.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  int? _selectedBundleId;

  @override
  void initState() {
    super.initState();
    context.read<BundleCubit>().loadBundles();
  }

  void _onSubscribe(BuildContext context, BundleModel bundle) {
    context.push('/payment', extra: bundle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            context.go('/Dashboard');
          },
        ),

        // This title clarifies the current page purpose for the institution user.
        title: const Text(
          'Manage Subscription',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: BlocListener<SubscriptionInstitutionCubit,
          SubscribtionInstitutionState>(
        listener: (context, state) {
          if (state is SubscribtionInstitutionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscribed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SubscribtionInstitutionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This heading uses simpler wording for the current subscription screen.
              const Text(
                'Choose Your\nPlan.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the plan that aligns with your operational scale. '
                    'All plans include core administrative access and 24/7 priority support.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              BlocBuilder<BundleCubit, BundleState>(
                builder: (context, bundleState) {
                  if (bundleState is BundleLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (bundleState is BundleError) {
                    return Center(
                      child: Text(
                        bundleState.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (bundleState is BundleLoaded) {
                    return Column(
                      children: bundleState.bundles
                          .map(
                            (bundle) => _BundleCard(
                          bundle: bundle,
                          isSelected: _selectedBundleId == bundle.id,
                          onSelect: () => setState(
                                () => _selectedBundleId = bundle.id,
                          ),
                          onSubscribe: () => _onSubscribe(context, bundle),
                        ),
                      )
                          .toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'All plans include a 14-day free trial. No credit card required to start.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final BundleModel bundle;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onSubscribe;

  const _BundleCard({
    required this.bundle,
    required this.isSelected,
    required this.onSelect,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bundle.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFF1A1A2E).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${bundle.price.toStringAsFixed(0)}/mo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
            if (bundle.description != null && bundle.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                bundle.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white70 : Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isSelected ? Colors.white : const Color(0xFF1A1A2E),
                  foregroundColor:
                  isSelected ? const Color(0xFF1A1A2E) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}