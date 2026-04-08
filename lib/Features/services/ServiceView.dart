import 'package:flutter/material.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppColors.textPrimary),
        title: const Text('Services', style: AppTextStyles.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPortfolioBanner(),
          const SizedBox(height: 24),
          _buildActiveNodesMetric(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Services', style: AppTextStyles.screenTitle),
              Row(
                children: [
                  _buildIconButton(Icons.filter_list),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.search),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            'Physical Therapy Center',
            'Main campus rehabilitation facility focusing on mobility and recovery excellence.',
            'ACTIVE',
            AppColors.success,
            'https://via.placeholder.com/400x200',
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            'Specialized Education',
            'Adaptive curriculum and support systems for diverse learning requirements.',
            'PENDING REVIEW',
            Colors.orange,
            'https://via.placeholder.com/400x200',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 20),
    );
  }

  Widget _buildServiceCard(String title, String desc, String status, Color statusColor, String imgUrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imgUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(title, style: AppTextStyles.fieldLabel.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(desc, style: AppTextStyles.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        onPressed: () {},
                        child: const Text('Manage'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                      onPressed: () {},
                      child: const Text('Edit'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ───────── Portfolio Banner ─────────
  Widget _buildPortfolioBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        // Subtle gradient as seen in the top section
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.white,
            AppColors.background.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service\nPortfolio',
            style: AppTextStyles.largeTitle,
          ),
          const SizedBox(height: 16),
          Text(
            'Manage institutional accessibility and specialized facilities from a centralized dashboard.',
            style: AppTextStyles.description.copyWith(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ───────── Active Nodes Metric ─────────
  Widget _buildActiveNodesMetric() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Off-white/grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE NODES',
            style: AppTextStyles.fieldLabel.copyWith(
              fontSize: 12,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '12',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.textPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                '+2 from last month',
                style: AppTextStyles.fieldLabel.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}