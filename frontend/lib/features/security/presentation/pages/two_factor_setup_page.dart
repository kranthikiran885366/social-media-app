import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

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
      appBar: AppBar(
        title: const Text('Setup Two-Factor Authentication'),
      ),
      body: BlocConsumer<SecurityBloc, SecurityState>(
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
              const SnackBar(content: Text('Invalid code. Please try again.')),
            );
          } else if (state is SecurityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) {
              if (step <= _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            steps: [
              Step(
                title: const Text('Verify Password'),
                content: _buildPasswordStep(state),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Scan QR Code'),
                content: _buildQRStep(),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Verify Setup'),
                content: _buildVerificationStep(state),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('Save Backup Codes'),
                content: _buildBackupCodesStep(),
                isActive: _currentStep >= 3,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordStep(SecurityState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your password to continue setting up two-factor authentication.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is SecurityLoading ? null : () {
              if (_passwordController.text.isNotEmpty) {
                context.read<SecurityBloc>().add(
                  EnableTwoFactorAuth(_passwordController.text),
                );
              }
            },
            child: state is SecurityLoading
                ? const CircularProgressIndicator()
                : const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildQRStep() {
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

  Widget _buildVerificationStep(SecurityState state) {
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

  Widget _buildBackupCodesStep() {
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