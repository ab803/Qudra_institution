import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/Models/service_model.dart';
import '../viewmodel/services_cubit.dart';
import '../viewmodel/services_state.dart';

class AddEditServiceView extends StatefulWidget {
  final ServiceModel? existingService;

  const AddEditServiceView({
    super.key,
    this.existingService,
  });

  @override
  State<AddEditServiceView> createState() => _AddEditServiceViewState();
}

class _AddEditServiceViewState extends State<AddEditServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _availabilityNotesController = TextEditingController();

  bool _isFree = false;
  bool _isActive = true;
  String _locationMode = 'on_site';
  String _bookingType = 'request';

  final List<String> _allDisabilities = [
    'Physical',
    'Visual',
    'Hearing',
    'Cognitive',
    'Other',
  ];

  final List<String> _selectedDisabilities = [];

  bool get isEditMode => widget.existingService != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingService != null) {
      final service = widget.existingService!;
      _nameController.text = service.name;
      _categoryController.text = service.category;
      _descriptionController.text = service.description ?? '';
      _priceController.text = service.price.toString();
      _durationController.text = service.durationMinutes.toString();
      _availabilityNotesController.text = service.availabilityNotes ?? '';
      _isFree = service.isFree;
      _isActive = service.isActive;
      _locationMode = service.locationMode;
      _bookingType = service.bookingType;
      _selectedDisabilities.addAll(service.supportedDisabilities);
    }
  }

  ServiceModel _buildServiceModel() {
    final institutionId = Supabase.instance.client.auth.currentUser!.id;

    return ServiceModel(
      id: widget.existingService?.id,
      institutionId: institutionId,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      supportedDisabilities: _selectedDisabilities,
      price: _isFree ? 0 : double.tryParse(_priceController.text) ?? 0,
      isFree: _isFree,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      locationMode: _locationMode,
      bookingType: _bookingType,
      availabilityNotes: _availabilityNotesController.text.trim().isEmpty
          ? null
          : _availabilityNotesController.text.trim(),
      isActive: _isActive,
      createdAt: widget.existingService?.createdAt ?? DateTime.now(),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDisabilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one supported disability'),
        ),
      );
      return;
    }

    final service = _buildServiceModel();

    if (isEditMode) {
      context.read<ServicesCubit>().editService(service);
    } else {
      context.read<ServicesCubit>().createService(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        if (state is ServicesLoaded) {
          // This returns true to the previous screen so it can refresh the services list after a successful save.
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/services');
          }
        }

      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,

          // This back button always returns to the previous page, or falls back to the services list if there is no back stack.
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop(true);
              } else {
                context.go('/services');
              }
            },
          ),

          title: Text(
            isEditMode ? 'Edit Service' : 'Add Service',
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _section(
                    title: 'Basic Information',
                    child: Column(
                      children: [
                        _input(_nameController, 'Service Name'),
                        const SizedBox(height: 12),
                        _input(_categoryController, 'Category'),
                        const SizedBox(height: 12),
                        _input(
                          _descriptionController,
                          'Description',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'Pricing',
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _isFree,
                          title: const Text('Is this service free?'),
                          onChanged: (v) => setState(() => _isFree = v),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.black,
                          inactiveThumbColor: Colors.black,
                          inactiveTrackColor: Colors.white,
                          trackOutlineColor:
                          MaterialStateProperty.all(Colors.black26),
                        ),
                        if (!_isFree)
                          _input(
                            _priceController,
                            'Price',
                            keyboardType: TextInputType.number,
                          ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'Service Details',
                    child: Column(
                      children: [
                        _input(
                          _durationController,
                          'Duration (minutes)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          'Location Mode',
                          _locationMode,
                          const ['on_site', 'home_visit', 'online'],
                              (v) => setState(() => _locationMode = v!),
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          'Booking Type',
                          _bookingType,
                          const ['request'],
                              (v) => setState(() => _bookingType = v!),
                        ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'Supported Disabilities',
                    child: Wrap(
                      spacing: 8,
                      children: _allDisabilities.map((item) {
                        final selected =
                        _selectedDisabilities.contains(item);

                        return FilterChip(
                          selected: selected,
                          label: Text(
                            item,
                            style: TextStyle(
                              color:
                              selected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color:
                            selected ? Colors.black : Colors.black26,
                          ),
                          onSelected: (v) {
                            setState(() {
                              v
                                  ? _selectedDisabilities.add(item)
                                  : _selectedDisabilities.remove(item);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  _section(
                    title: 'Availability Notes',
                    child: _input(
                      _availabilityNotesController,
                      'Notes',
                      maxLines: 3,
                    ),
                  ),
                  _section(
                    title: 'Status',
                    child: SwitchListTile(
                      value: _isActive,
                      title: const Text('Service is active'),
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.black,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.white,
                      trackOutlineColor:
                      MaterialStateProperty.all(Colors.black26),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEditMode ? 'Update Service' : 'Create Service',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------
  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) =>
      v == null || v.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF2F2F2), // neutral light grey
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _dropdown(
      String label,
      String value,
      List<String> items,
      void Function(String?) onChanged,
      ) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white, // ✅ background of dropdown menu
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(
              e.replaceAll('_', ' '),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
            .toList(),
        onChanged: onChanged,
        // ✅ dropdown list background
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
