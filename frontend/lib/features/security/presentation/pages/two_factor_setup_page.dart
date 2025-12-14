import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart;

class TwoFactorSetupPage extends StatefulWidget {
  const TwoFactorSetupPage({super.key});

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  int _currentStep = 0;
  String? _qrCode;
  List<String> _backupCodes = [];

  @override
  void dispose() {
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                expandedHeight: isTablet ? 120 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient.scale(0.1),
                    ),
                  ),
                  title: Text(
                    'Setup Two-Factor Authentication',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                ),
                leading: Container(
                  margin: EdgeInsets.only(
                    left: isTablet ? 24 : 16,
                    top: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: isTablet ? 28 : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocConsumer<SecurityBloc, SecurityState>(
                  listener: (context, state) {
                    if (state is TwoFactorAuthEnabled) {
                      setState(() {
                        _qrCode = state.qrCode;
                        _backupCodes = state.backupCodes;
                        _currentStep = 1;
                      });
                    } else if (state is TwoFactorCodeVerified) {
                      setState(() => _currentStep = 2);
                    } else if (state is TwoFactorCodeInvalid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid code. Please try again.'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else if (state is SecurityError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      margin: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: Stepper(
                          currentStep: _currentStep,
                          onStepTapped: (step) {
                            if (step <= _currentStep) {
                              setState(() => _currentStep = step);
                            }
                          },
                          controlsBuilder: (context, details) {
                            return const SizedBox.shrink();
                          },
                          steps: [
                            Step(
                              title: Text(
                                'Verify Password',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              content: _buildPasswordStep(state, isTablet),
                              isActive: _currentStep >= 0,
                            ),
                            Step(
                              title: Text(
                                'Scan QR Code',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              content: _buildQRStep(isTablet),
                              isActive: _currentStep >= 1,
                            ),
                            Step(
                              title: Text(
                                'Verify Setup',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              content: _buildVerificationStep(state, isTablet),
                              isActive: _currentStep >= 2,
                            ),
                            Step(
                              title: Text(
                                'Save Backup Codes',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              content: _buildBackupCodesStep(isTablet),
                              isActive: _currentStep >= 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordStep(SecurityState state, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your password to continue setting up two-factor authentication.',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 18 : 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Container(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              gradient: state is SecurityLoading 
                  ? AppColors.primaryGradient.scale(0.5) 
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: isTablet ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: state is SecurityLoading ? null : () {
                  if (_passwordController.text.isNotEmpty) {
                    context.read<SecurityBloc>().add(
                      EnableTwoFactorAuth(_passwordController.text),
                    );
                  }
                },
                child: Center(
                  child: state is SecurityLoading
                      ? SizedBox(
                          width: isTablet ? 28 : 24,
                          height: isTablet ? 28 : 24,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRStep(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.)',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (_qrCode != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: _qrCode!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'Can\'t scan? Enter this code manually:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'JBSWY3DPEHPK3PXP',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: 'JBSWY3DPEHPK3PXP'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: const Text('I\'ve Added the Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep(SecurityState state, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter the 6-digit code from your authenticator app to verify the setup.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit code',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is SecurityLoading ? null : () {
              if (_codeController.text.length == 6) {
                context.read<SecurityBloc>().add(
                  VerifyTwoFactorCode(_codeController.text),
                );
              }
            },
            child: state is SecurityLoading
                ? const CircularProgressIndicator()
                : const Text('Verify Code'),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupCodesStep(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Save these backup codes in a safe place. You can use them to access your account if you lose your phone.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: _backupCodes.map((code) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _backupCodes.join('\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup codes copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Codes'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Two-factor authentication enabled successfully'),
                    ),
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}