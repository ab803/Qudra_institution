class MonthlyStats {
  final String month;
  final int count;
  MonthlyStats({required this.month, required this.count});
}

class DashboardStats {
  final int totalSubscribers;
  final int activeServices;
  final List<MonthlyStats> monthlyGrowth;

  const DashboardStats({
    required this.totalSubscribers,
    required this.activeServices,
    required this.monthlyGrowth,
  });
}