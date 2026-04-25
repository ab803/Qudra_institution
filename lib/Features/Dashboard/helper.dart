  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../../core/styles/AppColors.dart';

  Future<bool> checkSubscription(BuildContext context) async {
    try {
      final id = Supabase.instance.client.auth.currentUser?.id;
      if (id == null) return false;

      // 1. Check subscribed flag — compare as String
      final institutionRes = await Supabase.instance.client
          .from('institutions')
          .select('subscribed')
          .eq('id', id)
          .single();

      final subscribedValue = institutionRes['subscribed'];
      final isSubscribed = subscribedValue == true ||
          subscribedValue.toString().toUpperCase() == 'TRUE'; // ✅ handles text "TRUE"

      if (!isSubscribed) {
        if (context.mounted) _showNotSubscribedDialog(context);
        return false;
      }

      // 2. Correct table name + maybeSingle to avoid throw on empty
      final subscriptionRes = await Supabase.instance.client
          .from('subscription_institution') // ✅ correct table name
          .select('end_date')
          .eq('institution_id', id)
          .order('end_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (subscriptionRes == null) {
        if (context.mounted) _showNotSubscribedDialog(context);
        return false;
      }

      final endDate = DateTime.tryParse(subscriptionRes['end_date'] ?? '');

      if (endDate == null || !DateTime.now().isBefore(endDate)) {
        await Supabase.instance.client
            .from('institutions')
            .update({'subscribed': 'FALSE'}) // ✅ update as text to match column type
            .eq('id', id);

        if (context.mounted) _showExpiredDialog(context);
        return false;
      }

      return true;

    } catch (e) {
      debugPrint('checkSubscription error: $e'); // ✅ always log the real error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription check failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _showExpiredDialog(BuildContext context) {
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
              child: const Icon(Icons.timer_off_outlined,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Subscription Expired',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your subscription has expired. '
              'Please renew your plan to continue accessing this feature.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              context.go('/subscription');
            },
            child: const Text(
              'Renew Now',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }