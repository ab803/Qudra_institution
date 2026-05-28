import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthButton.dart';

class InstitutionSignUpView extends StatefulWidget {
  const InstitutionSignUpView({super.key});

  @override
  State<InstitutionSignUpView> createState() => _InstitutionSignUpViewState();
}

class _InstitutionSignUpViewState extends State<InstitutionSignUpView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedType;

  static const _institutionTypes = [
    'Hospital / Clinic',
    'Rehabilitation Center',
    'School / Education',
    'NGO / Charity',
    'Government Body',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<InstitutionAuthCubit>().signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      institutionType: _selectedType!,
      location: _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return BlocListener<InstitutionAuthCubit, InstitutionAuthState>(
      listener: (context, state) {
        if (state is InstitutionSignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            // This success message tells the institution user to verify the email before logging in.
            const SnackBar(
              content: Text(
                '✅ Registration successful. Please check your email, verify your account, then log in.',
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 4),
            ),
          );

          // This redirects the user to the login screen instead of opening the dashboard without a confirmed session.
          context.go('/institutionLogin');
        } else if (state is InstitutionAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<InstitutionAuthCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: isDesktop ? 22 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 1180 : 520,
                        ),
                        child: isDesktop
                            ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _buildSidePanel(),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: _buildFormCard(isDesktop: true),
                            ),
                          ],
                        )
                            : _buildFormCard(isDesktop: false),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            height: 105,
            child: Image.asset(
              'assets/images/Qudra_logo_Dark_mode.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'INSTITUTION REGISTRATION',
            style: TextStyle(
              color: Color(0xFFC5CE4E),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Join Qudra as an institution partner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Create your institution account, wait for approval, then manage services and subscribers from the portal.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),
          _buildSideFeature(Icons.verified_user_outlined, 'Admin approval flow'),
          const SizedBox(height: 14),
          _buildSideFeature(Icons.layers_outlined, 'Manage institution services'),
          const SizedBox(height: 14),
          _buildSideFeature(Icons.people_outline, 'View subscribers insights'),
        ],
      ),
    );
  }

  Widget _buildSideFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({required bool isDesktop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop) ...[
          SizedBox(
            width: 180,
            height: 105,
            child: Image.asset(
              'assets/images/Qudra_Institution_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 26 : 22),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Institution Details', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              const Text(
                'Register your institution to access Qudra services',
                style: AppTextStyles.pageDescription,
              ),
              const SizedBox(height: 22),
              isDesktop ? _buildDesktopForm() : _buildMobileForm(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already registered? ',
              style: AppTextStyles.description,
            ),
            GestureDetector(
              onTap: () => context.go('/institutionLogin'),
              child: const Text(
                'Log In',
                style: AppTextStyles.underlineLink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopForm() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Institution Name *',
                    hint: 'e.g. Cairo Rehabilitation Center',
                    prefixIcon: const Icon(
                      Icons.business,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Official Email *',
                    hint: 'contact@institution.com',
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    obscureText: true,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  _institutionTypeDropdown(),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number *',
                    hint: '01234567890',
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  CustomTextField(
                    controller: _addressController,
                    label: 'Address *',
                    hint: 'Full address',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.streetAddress,
                  ),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location Link',
                    hint: 'Google Maps link',
                    prefixIcon: const Icon(
                      Icons.link_outlined,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Institution Description *',
                    hint: 'Briefly describe the institution',
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AuthButton(
          label: 'Register Institution',
          onPressed: _onSignUp,
          trailingIcon: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Institution Name *',
          hint: 'e.g. Cairo Rehabilitation Center',
          prefixIcon: const Icon(Icons.business, color: AppColors.iconGrey),
          keyboardType: TextInputType.text,
        ),
        CustomTextField(
          controller: _emailController,
          label: 'Official Email *',
          hint: 'contact@institution.com',
          prefixIcon: const Icon(Icons.mail_outline, color: AppColors.iconGrey),
          keyboardType: TextInputType.emailAddress,
        ),
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Min. 8 characters',
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconGrey),
          keyboardType: TextInputType.visiblePassword,
        ),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number *',
          hint: '01234567890',
          prefixIcon: const Icon(Icons.phone, color: AppColors.iconGrey),
          keyboardType: TextInputType.phone,
        ),
        CustomTextField(
          controller: _addressController,
          label: 'Address *',
          hint: 'Full address',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.iconGrey,
          ),
          keyboardType: TextInputType.streetAddress,
        ),
        CustomTextField(
          controller: _descriptionController,
          label: 'Institution Description *',
          hint: 'Briefly describe the institution and its mission',
          prefixIcon: const Icon(
            Icons.description_outlined,
            color: AppColors.iconGrey,
          ),
          keyboardType: TextInputType.multiline,
        ),
        _institutionTypeDropdown(),
        CustomTextField(
          controller: _locationController,
          label: 'Location Link',
          hint: 'Google Maps link',
          prefixIcon: const Icon(Icons.link_outlined, color: AppColors.iconGrey),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 8),
        AuthButton(
          label: 'Register Institution',
          onPressed: _onSignUp,
          trailingIcon: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _institutionTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Institution Type *', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedType,
                isExpanded: true,
                hint: Text('Select type', style: AppTextStyles.hint),
                items: _institutionTypes
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val),
              ),
            ),
          ),
        ],
      ),
    );
  }
}