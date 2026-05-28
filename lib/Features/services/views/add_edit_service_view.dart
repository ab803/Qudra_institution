import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/widgets/portal_page_header.dart';
import '../../../core/widgets/responsive_page_shell.dart';
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

  bool _isFree = false;
  bool _isActive = true;
  String _locationMode = 'on_site';

  final List<String> _allDisabilities = [
    'Physical',
    'Visual',
    'Hearing',
    'Cognitive',
    'Other',
  ];

  final List<String> _selectedDisabilities = [];

  // This list defines the allowed working days shown to the institution.
  final List<String> _allWorkingDays = const [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // This list stores the selected working days for the current service.
  final List<String> _selectedWorkingDays = [];

  // These values store the selected daily working start and end times.
  TimeOfDay? _workingStartTime;
  TimeOfDay? _workingEndTime;

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
      _isFree = service.isFree;
      _isActive = service.isActive;
      _locationMode = service.locationMode;
      _selectedDisabilities.addAll(service.supportedDisabilities);
      _selectedWorkingDays.addAll(service.workingDays);

      // This block restores the saved working start and end times in edit mode.
      _workingStartTime = _parseTimeOfDay(service.workingStartTime);
      _workingEndTime = _parseTimeOfDay(service.workingEndTime);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // This helper converts a stored HH:mm value into a TimeOfDay instance.
  TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // This helper converts TimeOfDay into a stable HH:mm value for storage.
  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // This helper renders the selected time as a readable label in the UI.
  String _displayTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // This helper opens a time picker and stores the selected working time.
  Future<void> _pickWorkingTime({
    required bool isStartTime,
  }) async {
    final initialTime = isStartTime
        ? (_workingStartTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_workingEndTime ?? const TimeOfDay(hour: 17, minute: 0));

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime == null) return;

    setState(() {
      if (isStartTime) {
        _workingStartTime = selectedTime;
      } else {
        _workingEndTime = selectedTime;
      }
    });
  }

  // This helper validates the selected working hours before saving the service.
  bool _validateWorkingHours() {
    if (_selectedWorkingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one working day'),
        ),
      );
      return false;
    }

    if (_workingStartTime == null || _workingEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end working times'),
        ),
      );
      return false;
    }

    final startMinutes =
        (_workingStartTime!.hour * 60) + _workingStartTime!.minute;
    final endMinutes = (_workingEndTime!.hour * 60) + _workingEndTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Working end time must be after working start time'),
        ),
      );
      return false;
    }

    return true;
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
      bookingType: 'instant_slot',
      availabilityNotes: null,
      workingDays: _selectedWorkingDays,
      workingStartTime: _formatTimeOfDay(_workingStartTime),
      workingEndTime: _formatTimeOfDay(_workingEndTime),
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

    if (!_validateWorkingHours()) return;

    final service = _buildServiceModel();

    if (isEditMode) {
      context.read<ServicesCubit>().editService(service);
    } else {
      context.read<ServicesCubit>().createService(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            // This back button always returns to the previous page, or falls back to the services list if there is no back stack.
            onPressed: () {
              if (context.canPop()) {
                context.pop(false);
              } else {
                context.go('/services');
              }
            },
          ),
          title: Text(
            isEditMode ? 'Edit Service' : 'Add Service',
            style: AppTextStyles.appBarTitle,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ResponsivePageShell(
            maxWidth: isDesktop ? 1180 : double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PortalPageHeader(
                    overline: 'Service Setup',
                    title: isEditMode ? 'Edit Service' : 'Add Service',
                    subtitle:
                    'Configure the service information, pricing, supported disabilities, and working hours.',
                  ),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
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
                                      maxLines: 4,
                                    ),
                                  ],
                                ),
                              ),
                              _section(
                                title: 'Supported Disabilities',
                                child: _buildDisabilityChips(),
                              ),
                              _section(
                                title: 'Working Hours',
                                child: _buildWorkingHoursSection(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _section(
                                title: 'Pricing',
                                child: _buildPricingSection(),
                              ),
                              _section(
                                title: 'Service Details',
                                child: _buildServiceDetailsSection(),
                              ),
                              _section(
                                title: 'Status',
                                child: _buildStatusSection(),
                              ),
                              _buildSaveButton(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
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
                      child: _buildPricingSection(),
                    ),
                    _section(
                      title: 'Service Details',
                      child: _buildServiceDetailsSection(),
                    ),
                    _section(
                      title: 'Supported Disabilities',
                      child: _buildDisabilityChips(),
                    ),
                    _section(
                      title: 'Working Hours',
                      child: _buildWorkingHoursSection(),
                    ),
                    _section(
                      title: 'Status',
                      child: _buildStatusSection(),
                    ),
                    const SizedBox(height: 4),
                    _buildSaveButton(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        _switchTile(
          value: _isFree,
          title: 'Is this service free?',
          onChanged: (v) => setState(() => _isFree = v),
        ),
        if (!_isFree) ...[
          const SizedBox(height: 12),
          _input(
            _priceController,
            'Price',
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildServiceDetailsSection() {
    return Column(
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
      ],
    );
  }

  Widget _buildDisabilityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allDisabilities.map((item) {
        final selected = _selectedDisabilities.contains(item);
        return FilterChip(
          selected: selected,
          label: Text(
            item,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          selectedColor: Colors.black,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          side: BorderSide(color: selected ? Colors.black : Colors.black26),
          onSelected: (v) {
            setState(() {
              v
                  ? _selectedDisabilities.add(item)
                  : _selectedDisabilities.remove(item);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildWorkingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allWorkingDays.map((day) {
            final selected = _selectedWorkingDays.contains(day);
            return FilterChip(
              selected: selected,
              label: Text(
                day,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selectedColor: Colors.black,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              side: BorderSide(color: selected ? Colors.black : Colors.black26),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedWorkingDays.add(day);
                  } else {
                    _selectedWorkingDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 560;
            final startTile = _timePickerTile(
              label: 'Working Start Time',
              value: _displayTime(_workingStartTime),
              onTap: () => _pickWorkingTime(isStartTime: true),
            );
            final endTile = _timePickerTile(
              label: 'Working End Time',
              value: _displayTime(_workingEndTime),
              onTap: () => _pickWorkingTime(isStartTime: false),
            );

            if (!isWide) {
              return Column(
                children: [
                  startTile,
                  const SizedBox(height: 12),
                  endTile,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: startTile),
                const SizedBox(width: 12),
                Expanded(child: endTile),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _switchTile(
      value: _isActive,
      title: 'Service is active',
      onChanged: (v) => setState(() => _isActive = v),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
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
          elevation: 0,
        ),
        child: Text(
          isEditMode ? 'Update Service' : 'Create Service',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------
  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 17)),
          const SizedBox(height: 14),
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
      validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
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
        canvasColor: Colors.white,
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

  Widget _switchTile({
    required bool value,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SwitchListTile(
        value: value,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.black,
        inactiveThumbColor: Colors.black,
        inactiveTrackColor: Colors.white,
        trackOutlineColor: MaterialStateProperty.all(Colors.black26),
      ),
    );
  }

  // This widget renders a reusable time selector tile for working hours input.
  Widget _timePickerTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}