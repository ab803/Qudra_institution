import 'package:flutter/material.dart';
import '../../core/styles/AppColors.dart';
import '../../core/styles/AppTextStyles.dart';

class SubscribersView extends StatelessWidget {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 16),
                const Text('Subscribers', style: AppTextStyles.largeTitle),
                const Text('MANAGEMENT & INSIGHTS',
                    style: TextStyle(letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                // ───────── Search & Filter ─────────
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilterButton(),
                const SizedBox(height: 32),

                // ───────── Subscriber List ─────────
                _buildSubscriberCard(
                  name: 'Elena Rosales',
                  email: 'elena.r@institution.edu',
                  date: 'Oct 12, 2023',
                  status: 'ACTIVE',
                  statusColor: const Color(0xFFC5CEFF), // Soft blue/purple
                  image: 'https://i.pravatar.cc/150?u=elena',
                ),
                _buildSubscriberCard(
                  name: 'Marcus Thorne',
                  email: 'm.thorne@global.com',
                  date: 'Nov 05, 2023',
                  status: 'PREMIUM',
                  statusColor: const Color(0xFFC5CEFF),
                  image: 'https://i.pravatar.cc/150?u=marcus',
                ),
                _buildSubscriberCard(
                  name: 'Sarah Kovic',
                  email: 'sarah@creative.io',
                  date: 'Dec 20, 2023',
                  status: 'TRIAL',
                  statusColor: const Color(0xFFEEEEEE),
                  isInitials: true,
                ),

                const SizedBox(height: 24),
                _buildPagination(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── UI Helper Methods ─────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, email, or ID...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.filter_list, color: AppColors.white),
        label: const Text('Filters', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSubscriberCard({
    required String name,
    required String email,
    required String date,
    required String status,
    required Color statusColor,
    String? image,
    bool isInitials = false,
  }) {
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
                backgroundImage: image != null ? NetworkImage(image) : null,
                child: isInitials ? const Text('SK', style: TextStyle(color: Colors.white)) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.fieldLabel.copyWith(fontSize: 18)),
                  Text(email, style: AppTextStyles.description),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('JOINED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9E9E9),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Showing 1-4 of 1,240\nsubscribers', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        Row(
          children: [
            _pageBox('<', isIcon: true),
            _pageBox('1', active: true),
            _pageBox('2'),
            _pageBox('3'),
            _pageBox('>', isIcon: true),
          ],
        )
      ],
    );
  }

  Widget _pageBox(String text, {bool active = false, bool isIcon = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: active ? Colors.black : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: const Icon(Icons.menu, color: AppColors.textPrimary),
      title: const Text('Qudra', style: AppTextStyles.appBarTitle),
      centerTitle: true,
      actions: const [
        CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
        SizedBox(width: 24),
      ],
    );
  }
}