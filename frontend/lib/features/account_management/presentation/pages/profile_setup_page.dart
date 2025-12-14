import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  double _progress = 0.2;

  // Form controllers
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _dobController = TextEditingController();

  // State variables
  File? _profileImage;
  String _selectedGender = 'Prefer not to say';
  bool _isUsernameAvailable = true;
  bool _isPrivateAccount = false;
  String _accountType = 'Personal';
  DateTime? _dateOfBirth;
  final List<String> _bioLinks = [];

  final List<String> _genderOptions = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say', 'Custom'
  ];

  final List<String> _accountTypes = [
    'Personal', 'Business', 'Creator'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _progress),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
            _progress = (index + 1) / 6;
          });
        },
        children: [
          _buildUsernameStep(),
          _buildProfilePhotoStep(),
          _buildPersonalInfoStep(),
          _buildBioStep(),
          _buildAccountTypeStep(),
          _buildPrivacyStep(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildUsernameStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose a username',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can always change it later.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixText: '@',
              border: const OutlineInputBorder(),
              suffixIcon: _isUsernameAvailable
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.error, color: Colors.red),
            ),
            onChanged: _checkUsernameAvailability,
          ),
          if (!_isUsernameAvailable)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'This username isn\'t available. Try another.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Username suggestions:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['john_doe_2024', 'johndoe.official', 'john.doe.123']
                .map((suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        _usernameController.text = suggestion;
                        _checkUsernameAvailability(suggestion);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Add a profile photo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a photo that represents you.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _selectProfilePhoto,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImage == null
                  ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoOption('Camera', Icons.camera_alt, () => _pickImage(ImageSource.camera)),
              _buildPhotoOption('Gallery', Icons.photo_library, () => _pickImage(ImageSource.gallery)),
              _buildPhotoOption('Avatar', Icons.face, _selectAvatar),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _nextStep,
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This won\'t be part of your public profile.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _selectDateOfBirth,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(value: gender, child: Text(gender));
            }).toList(),
            onChanged: (value) => setState(() => _selectedGender = value!),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We use this information to keep our community safe and show you relevant content.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell people about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a bio and links to your profile.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Website',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Additional Links',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: _addBioLink,
                icon: const Icon(Icons.add),
                label: const Text('Add Link'),
              ),
            ],
          ),
          ..._bioLinks.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: entry.value,
                      decoration: InputDecoration(
                        labelText: 'Link ${entry.key + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => _bioLinks[entry.key] = value,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeBioLink(entry.key),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAccountTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose account type',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can switch between account types anytime.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ..._accountTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAccountTypeOption(type),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAccountTypeOption(String type) {
    final isSelected = _accountType == type;
    String description;
    IconData icon;

    switch (type) {
      case 'Personal':
        description = 'For personal use and connecting with friends';
        icon = Icons.person;
        break;
      case 'Business':
        description = 'For businesses, brands, and organizations';
        icon = Icons.business;
        break;
      case 'Creator':
        description = 'For content creators and public figures';
        icon = Icons.star;
        break;
      default:
        description = '';
        icon = Icons.person;
    }

    return GestureDetector(
      onTap: () => setState(() => _accountType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose who can see your content.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Private Account'),
            subtitle: const Text('Only followers you approve can see your posts'),
            value: _isPrivateAccount,
            onChanged: (value) => setState(() => _isPrivateAccount = value),
          ),
          const SizedBox(height: 24),
          const Text(
            'You can always change these settings later in your profile.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _completeSetup,
              child: const Text('Complete Setup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoOption(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(icon, size: 30, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < 5 ? _nextStep : _completeSetup,
              child: Text(_currentStep < 5 ? 'Next' : 'Complete'),
            ),
          ),
        ],
      ),
    );
  }

  void _checkUsernameAvailability(String username) async {
    if (username.length < 3) return;
    
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isUsernameAvailable = !['admin', 'test', 'user'].contains(username.toLowerCase());
    });
  }

  void _selectProfilePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  void _selectAvatar() {
    // Show avatar selection dialog
  }

  void _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 4745)), // 13 years ago
    );
    if (date != null) {
      setState(() {
        _dateOfBirth = date;
        _dobController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  void _addBioLink() {
    setState(() => _bioLinks.add(''));
  }

  void _removeBioLink(int index) {
    setState(() => _bioLinks.removeAt(index));
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() {
    context.go('/main');
  }
}