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

  // This dialog asks the institution to confirm deleting the selected service.
  Future<void> _confirmDeleteService({
    required String serviceId,
    required String serviceName,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Service',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$serviceName"? This action cannot be undone.',
            style: const TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      context.read<ServicesCubit>().deleteService(serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // This back button always returns to the previous page, or falls back to Dashboard if there is no back stack.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/Dashboard');
            }
          },
        ),

        title: const Text(
          'My Services',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // This opens the add service screen and refreshes the list only after a successful create.
        onPressed: () async {
          final didChange = await context.push<bool>('/services/add');

          if (didChange == true && mounted) {
            context.read<ServicesCubit>().loadMyServices();
          }
        },
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
                  onEdit: () async {
                 if (service.id == null) return;
                           // This opens the edit service screen and refreshes the list only after a successful update.
                         final didChange = await context.push<bool>(
                             '/services/edit',
                               extra: service,
                                 );

                               if (didChange == true && mounted) {
                                 context.read<ServicesCubit>().loadMyServices();
                           }
                           },

                    onToggleStatus: () {
                      if (service.id == null) return;
                      context.read<ServicesCubit>().changeServiceStatus(
                        serviceId: service.id!,
                        isActive: !service.isActive,
                      );
                    },
                    onDelete: () {
                      if (service.id == null) return;
                      _confirmDeleteService(
                        serviceId: service.id!,
                        serviceName: service.name,
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
