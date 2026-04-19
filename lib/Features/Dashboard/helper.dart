// core/utils/subscription_guard.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/styles/AppColors.dart';

Future<bool> checkSubscription(BuildContext context) async {
  try {
    final id = Supabase.instance.client.auth.currentUser?.id;
    if (id == null) return false;

    final response = await Supabase.instance.client
        .from('institutions')
        .select('subscribed')
        .eq('id', id)
        .single();

    final isSubscribed = response['subscribed'] == true;

    if (!isSubscribed && context.mounted) {
      _showNotSubscribedDialog(context);
    }
    return isSubscribed;
  } catch (e) {
    return false;
  }
}

void _showNotSubscribedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'No Active Subscription',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      content: const Text(
        'You need an active subscription to access this feature. '
            'Please subscribe to a plan first.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.go("/Dashboard"),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {

            context.go('/subscription');
          },
          child: const Text(
            'Subscribe Now',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}