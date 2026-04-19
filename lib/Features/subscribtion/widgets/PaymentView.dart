import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/Models/BundleModel.dart';
import '../../../core/Models/subscribtionModel.dart';
import '../../../core/paymentService/PaymobManager.dart';
import '../../subscribtion/viewModel/subscribtion_institution_cubit.dart';
import '../../subscribtion/viewModel/subscribtion_institution_state.dart';


class PaymentView extends StatefulWidget {
  final BundleModel bundle;

  const PaymentView({super.key, required this.bundle});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

enum PaymentType { card, wallet, cash }

class _PaymentViewState extends State<PaymentView> {
  PaymentType _selectedPayment = PaymentType.card;
  bool _isLoading = false;

  // Card controllers
  final _cardNumberController = TextEditingController();
  final _cardNameController   = TextEditingController();
  final _expiryController     = TextEditingController();
  final _cvvController        = TextEditingController();

  // Wallet controller
  final _walletPhoneController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _walletPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPayment() async {
    // ── Cash ──────────────────────────────────────────────
    if (_selectedPayment == PaymentType.cash) {
      _createSubscription();
      return;
    }

    // ── Wallet ────────────────────────────────────────────
    if (_selectedPayment == PaymentType.wallet) {
      final phone = _walletPhoneController.text.trim();
      if (phone.isEmpty) {
        _showMessage('Please enter your wallet phone number.', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FlutterPaymob.instance.payWithWallet(
          context: context,
          currency: 'EGP',
          amount: widget.bundle.price.toDouble(),
          number: phone,
          onPayment: (response) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            if (response.success) {
              _createSubscription();
            } else {
              _showMessage('Wallet payment failed. Please try again.', isError: true);
            }
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showMessage(e.toString(), isError: true);
        }
      }
      return;
    }

    // ── Card ──────────────────────────────────────────────
    if (_cardNumberController.text.trim().isEmpty ||
        _cardNameController.text.trim().isEmpty ||
        _expiryController.text.trim().isEmpty ||
        _cvvController.text.trim().isEmpty) {
      _showMessage('Please fill in all card details.', isError: true);
      return;
    }

    final expiry = _expiryController.text.trim().split('/');
    if (expiry.length != 2) {
      _showMessage('Invalid expiry format. Use MM/YY.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentKey = await PaymobManager().getPaymentKey(
        widget.bundle.price.toInt(),
        'EGP',
      );

      final result = await PaymobManager().payWithCard(
        paymentKey: paymentKey,
        cardNumber: _cardNumberController.text.trim(),
        cardholderName: _cardNameController.text.trim(),
        expiryMonth: expiry[0],
        expiryYear: expiry[1],
        cvv: _cvvController.text.trim(),
      );

      if (!mounted) return;

      if (result['is_3d_secure'] == true && result['redirect_url'] != '') {
        final url = Uri.parse(result['redirect_url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          _createSubscription();
        } else {
          _showMessage('Could not open 3DS page.', isError: true);
        }
        return;
      }

      if (result['success'] == true) {
        _createSubscription();
      } else {
        _showMessage(
          result['message'].isNotEmpty
              ? result['message']
              : 'Payment failed. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _createSubscription() {
    final institutionId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    final paymentMethod = switch (_selectedPayment) {
      PaymentType.card   => 'card',
      PaymentType.wallet => 'wallet',
      PaymentType.cash   => 'cash',
    };

    final model = SubscribtionInstitutionmodel(
      id: 0,
      amount: widget.bundle.price.toInt(),
      institutionId: institutionId,
      paymentMethod: paymentMethod,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      bundleId: widget.bundle.id,
      createdAt: DateTime.now(),
    );

    context
        .read<SubscriptionInstitutionCubit>()
        .createSubscription(model);
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionInstitutionCubit,
        SubscribtionInstitutionState>(
      listener: (context, state) {
        if (state is SubscribtionInstitutionSuccess) {
          _showMessage('Subscribed successfully!', isError: false);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is SubscribtionInstitutionError) {
          _showMessage(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const Text('Order Summary',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildOrderSummaryCard(),
                const SizedBox(height: 32),
                const Text('Payment Method',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCreditCardOption(),
                const SizedBox(height: 16),
                _buildWalletOption(),           // 👈 wallet with phone field
                const SizedBox(height: 16),
                _buildSimplePaymentOption(
                  title: 'Cash Payment',
                  value: PaymentType.cash,
                  icons: [const Icon(Icons.money, color: Colors.black54)],
                ),
                const SizedBox(height: 40),
                _buildConfirmButton(),
                const SizedBox(height: 16),
                _buildSecurePaymentFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Payment',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.bundle.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  widget.bundle.description ?? 'Monthly Subscription',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('\$${widget.bundle.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('/ mo',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardOption() {
    final isSelected = _selectedPayment == PaymentType.card;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = PaymentType.card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildCustomRadio(isSelected),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Credit/Debit Card',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.credit_card, color: Colors.black54),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 24),
              _buildTextField(
                label: 'CARDHOLDER NAME',
                hint: 'John Doe',
                controller: _cardNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'CARD NUMBER',
                hint: '0000 0000 0000 0000',
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'EXPIRY DATE',
                      hint: 'MM/YY',
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'CVV',
                      hint: '123',
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      trailingIcon: Icons.help_outline,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Wallet option — expands to show a phone number field when selected
  Widget _buildWalletOption() {
    final isSelected = _selectedPayment == PaymentType.wallet;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = PaymentType.wallet),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildCustomRadio(isSelected),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Mobile Wallet',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.black54),
                const SizedBox(width: 8),
                const Icon(Icons.contactless_outlined, color: Colors.black54),
              ],
            ),
            // ── Phone field shown only when selected ──
            if (isSelected) ...[
              const SizedBox(height: 24),
              _buildTextField(
                label: 'WALLET PHONE NUMBER',
                hint: '010XXXXXXXX',
                controller: _walletPhoneController,
                keyboardType: TextInputType.phone,
                trailingIcon: Icons.phone_android,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePaymentOption({
    required String title,
    required PaymentType value,
    required List<Widget> icons,
  }) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            _buildCustomRadio(isSelected),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500))),
            ...icons,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRadio(bool isSelected) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isSelected ? Colors.black : Colors.grey, width: 2),
      ),
      child: isSelected
          ? Center(
        child: Container(
          height: 10,
          width: 10,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Colors.black),
        ),
      )
          : null,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? trailingIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          color: const Color(0xFFEBEBEB),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: trailingIcon != null
                  ? Icon(trailingIcon, size: 16, color: Colors.grey[700])
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleConfirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF222222),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2))
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Confirm Payment',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.lock, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurePaymentFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text('Payments are secure and encrypted',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}