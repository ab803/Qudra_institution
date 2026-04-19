import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/services_cubit.dart';
import '../viewmodel/services_state.dart';
import '../widgets/service_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Services',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/services/add'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state is ServicesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServicesError) {
              return Center(child: Text(state.errorMessage));
            }

            if (state is ServicesLoaded) {
              if (state.services.isEmpty) {
                return _emptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final service = state.services[index];

                  return ServiceCard(
                    service: service,
                    onEdit: () {
                      if (service.id == null) return;
                      context.push('/services/edit', extra: service);
                    },
                    onToggleStatus: () {
                      if (service.id == null) return;

                      context.read<ServicesCubit>().changeServiceStatus(
                        serviceId: service.id!,
                        isActive: !service.isActive,
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.layers_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            'No services added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first service',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}