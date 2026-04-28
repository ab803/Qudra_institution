import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/Models/institutionModel.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../../../core/supabase/institutionservice.dart';
import '../../Dashboard/widgets/PortalDrawer.dart';

class InstitutionProfileView extends StatefulWidget {
  const InstitutionProfileView({super.key});

  @override
  State<InstitutionProfileView> createState() => _InstitutionProfileViewState();
}

class _InstitutionProfileViewState extends State<InstitutionProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final InstitutionService _service = InstitutionService();

  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  InstitutionModel? _profile;
  bool _loading = true;
  bool _isEditMode = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

// This loads the current institution profile for the profile screen.
  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getCurrentProfile();
      if (!mounted) return;

      _fillControllers(profile);

      setState(() {
        _profile = profile;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // This fills the editable profile controllers from the currently loaded institution profile.
  void _fillControllers(InstitutionModel? profile) {
    _descriptionController.text = profile?.description ?? '';
    _phoneController.text = profile?.phone ?? '';
    _addressController.text = profile?.address ?? '';
    _locationController.text = profile?.location ?? '';
  }

// This enables profile edit mode for editable institution fields only.
  void _startEditing() {
    _fillControllers(_profile);
    setState(() {
      _isEditMode = true;
    });
  }

// This cancels profile editing and restores the current loaded values.
  void _cancelEditing() {
    _fillControllers(_profile);
    setState(() {
      _isEditMode = false;
      _isSaving = false;
    });
  }


  // This saves the editable institution profile fields and exits edit mode after a successful update.
  Future<void> _saveProfileChanges() async {
    if (_profile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedModel = _profile!.copyWith(
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        location: _locationController.text.trim(),
      );

      final updatedProfile = await _service.updateProfile(updatedModel);

      if (!mounted) return;

      _fillControllers(updatedProfile);

      setState(() {
        _profile = updatedProfile;
        _isEditMode = false;
        _isSaving = false;
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
        ),
      );
    }
  }




  // This opens the subscription screen directly from the profile page.
  void _openSubscription() {
    context.go('/subscription');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const PortalDrawer(currentRoute: '/profile'),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : _profile == null
            ? _buildEmptyState()
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 16),
            _buildHeroCard(_profile!),
            const SizedBox(height: 16),
            _buildProfileActions(),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'CONTACT',
              children: [
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _profile!.email,
                  isLocked: true,
                ),
                _buildEditableField(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  controller: _phoneController,
                  placeholder: 'Add phone number',
                  keyboardType: TextInputType.phone,
                ),
                _buildEditableField(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  controller: _addressController,
                  placeholder: 'Add address',
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'INSTITUTION',
              children: [
                _buildEditableField(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  controller: _descriptionController,
                  placeholder: 'Add institution description',
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                ),
                _buildInfoRow(
                  icon: Icons.business_outlined,
                  label: 'Institution Type',
                  value: _profile!.institutionType,
                  isLocked: true,
                ),
                _buildEditableField(
                  icon: Icons.link_outlined,
                  label: 'Location Link',
                  controller: _locationController,
                  placeholder: 'Add location link',
                  keyboardType: TextInputType.url,
                  maxLines: 2,
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created At',
                  value: _formatDate(_profile!.createdAt),
                  isLocked: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'ACCOUNT STATUS',
              children: [
                _buildInfoRow(
                  icon: Icons.verified_outlined,
                  label: 'Approval Status',
                  value: _profile!.status,
                  isLocked: true,
                ),
                _buildInfoRow(
                  icon: Icons.stars_outlined,
                  label: 'Subscription',
                  value: _profile!.subscribed
                      ? 'Active'
                      : 'Inactive',
                  isLocked: true,
                ),
              ],
            ),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.stars_outlined),
                label: const Text('Manage Subscription'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go('/Dashboard'),
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: const Text('Profile', style: AppTextStyles.appBarTitle),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildHeroCard(InstitutionModel profile) {
    final parts = profile.name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF242424),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildHeroBadge(profile.institutionType),
              _buildHeroBadge(profile.status.toUpperCase()),
              _buildHeroBadge(
                profile.subscribed ? 'SUBSCRIBED' : 'NOT SUBSCRIBED',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC5CEFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProfileActions() {
    if (!_isEditMode) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          // This enters profile edit mode for institution-managed fields.
          onPressed: _startEditing,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.textPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Profile'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            // This cancels profile editing and restores the loaded profile values.
            onPressed: _cancelEditing,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            // This saves the editable institution profile fields through InstitutionService.updateProfile.
            onPressed: _isSaving ? null : _saveProfileChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }


  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 44),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Failed to load profile.',
              textAlign: TextAlign.center,
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 12),
            TextButton(
              // This retries loading the current institution profile.
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person_outline, color: Colors.grey, size: 44),
            SizedBox(height: 12),
            Text(
              'No institution profile found.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final value = controller.text.trim().isEmpty ? '—' : controller.text.trim();

    if (!_isEditMode) {
      return _buildInfoRow(
        icon: icon,
        label: label,
        value: value,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }



  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}
