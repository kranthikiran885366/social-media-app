import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _is2FAEnabled = false;
  bool _isSMSEnabled = false;
  bool _isAuthAppEnabled = false;
  bool _areBackupCodesGenerated = false;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  
  String _selectedCountryCode = '+1';
  List<String> _backupCodes = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _build2FAToggle(),
          if (_is2FAEnabled) ...[
            const SizedBox(height: 24),
            _buildSMSSection(),
            const SizedBox(height: 24),
            _buildAuthAppSection(),
            const SizedBox(height: 24),
            _buildBackupCodesSection(),
            const SizedBox(height: 24),
            _buildTrustedDevicesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Secure Your Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Two-factor authentication adds an extra layer of security to your account. Even if someone knows your password, they won\'t be able to access your account without the second factor.',
            style: TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _build2FAToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Two-Factor Authentication'),
        subtitle: Text(_is2FAEnabled 
            ? 'Your account is protected with 2FA' 
            : 'Add an extra layer of security'),
        value: _is2FAEnabled,
        onChanged: (value) {
          setState(() => _is2FAEnabled = value);
          if (!value) {
            _disable2FA();
          }
        },
        secondary: Icon(
          _is2FAEnabled ? Icons.security : Icons.security_outlined,
          color: _is2FAEnabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSMSSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sms,
                  color: _isSMSEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Text Message (SMS)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: _isSMSEnabled,
                  onChanged: (value) {
                    if (value) {
                      _setupSMS();
                    } else {
                      setState(() => _isSMSEnabled = false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Get security codes via SMS to your phone number.',
              style: TextStyle(color: Colors.grey),
            ),
            if (_isSMSEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedCountryCode,
                    items: ['+1', '+44', '+91', '+86'].map((code) {
                      return DropdownMenuItem(value: code, child: Text(code));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCountryCode = value!),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyPhoneNumber,
                  child: const Text('Verify Phone Number'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthAppSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smartphone,
                  color: _isAuthAppEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Authentication App',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: _isAuthAppEnabled,
                  onChanged: (value) {
                    if (value) {
                      _setupAuthApp();
                    } else {
                      setState(() => _isAuthAppEnabled = false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Use an authentication app like Google Authenticator or Authy.',
              style: TextStyle(color: Colors.grey),
            ),
            if (_isAuthAppEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scan this QR code with your authenticator app:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('QR Code\n(Generated by backend)'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Or enter this key manually:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ABCD EFGH IJKL MNOP',
                              style: TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: 'ABCD EFGH IJKL MNOP'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Key copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit code from your app',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyAuthApp,
                  child: const Text('Verify Code'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCodesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backup,
                  color: _areBackupCodesGenerated ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Backup Codes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate backup codes to access your account if you lose your phone.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (!_areBackupCodesGenerated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateBackupCodes,
                  child: const Text('Generate Backup Codes'),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Save these codes safely',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Each code can only be used once. Store them in a safe place.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ..._backupCodes.map((code) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        code,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    )).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _downloadBackupCodes,
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyBackupCodes,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
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

  Widget _buildTrustedDevicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.devices),
                SizedBox(width: 12),
                Text(
                  'Trusted Devices',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Devices you\'ve marked as trusted won\'t ask for 2FA codes.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTrustedDevice('iPhone 14 Pro', 'Current device', true),
            _buildTrustedDevice('MacBook Pro', 'Last used 2 days ago', false),
            _buildTrustedDevice('Chrome on Windows', 'Last used 1 week ago', false),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _removeAllTrustedDevices,
                child: const Text('Remove All Trusted Devices'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustedDevice(String deviceName, String lastUsed, bool isCurrent) {
    return ListTile(
      leading: const Icon(Icons.device_unknown),
      title: Text(deviceName),
      subtitle: Text(lastUsed),
      trailing: isCurrent 
          ? const Chip(label: Text('Current'))
          : IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeTrustedDevice(deviceName),
            ),
    );
  }

  void _setupSMS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup SMS Authentication'),
        content: const Text('We\'ll send a verification code to your phone number.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSMSEnabled = true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _setupAuthApp() {
    setState(() => _isAuthAppEnabled = true);
  }

  void _verifyPhoneNumber() {
    // Implement phone verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent to your phone')),
    );
  }

  void _verifyAuthApp() {
    // Implement auth app verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authentication app verified successfully')),
    );
  }

  void _generateBackupCodes() {
    setState(() {
      _areBackupCodesGenerated = true;
      _backupCodes = [
        '1234-5678',
        '2345-6789',
        '3456-7890',
        '4567-8901',
        '5678-9012',
        '6789-0123',
        '7890-1234',
        '8901-2345',
      ];
    });
  }

  void _downloadBackupCodes() {
    // Implement backup codes download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup codes downloaded')),
    );
  }

  void _copyBackupCodes() {
    final codesText = _backupCodes.join('\n');
    Clipboard.setData(ClipboardData(text: codesText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup codes copied to clipboard')),
    );
  }

  void _removeTrustedDevice(String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Trusted Device'),
        content: Text('Remove $deviceName from trusted devices?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$deviceName removed from trusted devices')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeAllTrustedDevices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove All Trusted Devices'),
        content: const Text('This will require 2FA verification on all devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All trusted devices removed')),
              );
            },
            child: const Text('Remove All'),
          ),
        ],
      ),
    );
  }

  void _disable2FA() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: const Text('This will make your account less secure. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _is2FAEnabled = true);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isSMSEnabled = false;
                _isAuthAppEnabled = false;
                _areBackupCodesGenerated = false;
                _backupCodes.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Two-factor authentication disabled')),
              );
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}