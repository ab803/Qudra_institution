import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/Models/dashboard_stats_model.dart';


class DashboardRepository {
  final SupabaseClient _client;
  DashboardRepository(this._client);

  Future<DashboardStats> fetchStats(String institutionId) async {
    // 1. Fetch all bookings for this institution
    final bookingsRaw = await _client
        .from('bookings')
        .select('user_id, created_at')
        .eq('institution_id', institutionId);

    final bookings = List<Map<String, dynamic>>.from(bookingsRaw);

    // 2. Total distinct subscribers
    final totalSubscribers =
        bookings.map((b) => b['user_id'] as String).toSet().length;

    // 3. Active services count
    final servicesRaw = await _client
        .from('services')
        .select('id')
        .eq('institution_id', institutionId);

    final activeServices = (servicesRaw as List).length;

    // 4. Monthly growth — distinct users per month (last 8 months)
    const monthLabels = [
      'JAN','FEB','MAR','APR','MAY','JUN',
      'JUL','AUG','SEP','OCT','NOV','DEC'
    ];

    // Build map: "2026-04" -> Set<userId>
    final Map<String, Set<String>> monthUserMap = {};
    for (final b in bookings) {
      final dt = DateTime.parse(b['created_at'] as String);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      monthUserMap.putIfAbsent(key, () => {}).add(b['user_id'] as String);
    }

    final now = DateTime.now();
    final monthlyGrowth = List.generate(8, (i) {
      final date = DateTime(now.year, now.month - 7 + i);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      return MonthlyStats(
        month: monthLabels[date.month - 1],
        count: monthUserMap[key]?.length ?? 0,
      );
    });

    return DashboardStats(
      totalSubscribers: totalSubscribers,
      activeServices: activeServices,
      monthlyGrowth: monthlyGrowth,
    );
  }
}