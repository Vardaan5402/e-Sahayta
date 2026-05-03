import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/user_profile_service.dart';

class SignupScreen extends StatefulWidget {
  final String selectedRole;

  const SignupScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const List<String> _companyOptions = [
    'Swiggy',
    'Zomato',
    'Amazon',
    'Blinkit',
    'Others',
  ];

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final aadhaarController = TextEditingController();
  final otherCompanyController = TextEditingController();
  final companyEmployeeIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  bool isLoading = false;
  String selectedCompany = _companyOptions.first;
  XFile? _profilePhotoFile;
  XFile? _aadhaarPhotoFile;
  XFile? _companyIdPhotoFile;

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    aadhaarController.dispose();
    otherCompanyController.dispose();
    companyEmployeeIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ValueChanged<XFile?> onPicked) async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null || !mounted) return;

    setState(() {
      onPicked(file);
    });
  }

  Future<void> signup() async {
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        aadhaarController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required registration details'),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and confirm password do not match'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String companyName = widget.selectedRole == 'worker'
          ? (selectedCompany == 'Others'
              ? otherCompanyController.text.trim()
              : selectedCompany)
          : '';

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await UserProfileService.createUserRecord(
        role: widget.selectedRole,
        name: nameController.text.trim(),
        phone: contactController.text.trim(),
        email: emailController.text.trim(),
        aadhaarNumber: aadhaarController.text.trim(),
        profilePhotoPath: _profilePhotoFile?.path ?? '',
        aadhaarCardPhotoPath: _aadhaarPhotoFile?.path ?? '',
        companyName: companyName,
        companyIdPhotoPath: _companyIdPhotoFile?.path ?? '',
        companyEmployeeId: companyEmployeeIdController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration completed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _uploadField({
    required String title,
    required String subtitle,
    required XFile? selectedFile,
    required VoidCallback onPick,
  }) {
    final String? fileName = selectedFile?.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff0F2A44),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xff667085),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(selectedFile.path),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fileName ?? '',
              style: const TextStyle(
                color: Color(0xff475467),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                selectedFile == null ? 'Browse from phone' : 'Change image',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workerOptionalSection() {
    if (widget.selectedRole != 'worker') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xffF4F7FB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Worker Optional Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0F2A44),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'These company-related details are optional and only shown for worker registration.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff667085),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedCompany,
          decoration: InputDecoration(
            labelText: 'Company Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          items: _companyOptions
              .map(
                (company) => DropdownMenuItem(
                  value: company,
                  child: Text(company),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedCompany = value!;
            });
          },
        ),
        if (selectedCompany == 'Others') ...[
          const SizedBox(height: 16),
          _field(
            controller: otherCompanyController,
            label: 'Enter Your Company Name',
          ),
        ],
        const SizedBox(height: 16),
        _uploadField(
          title: 'Company ID Upload',
          subtitle: 'Optional company ID image from your phone',
          selectedFile: _companyIdPhotoFile,
          onPick: () => _pickImage((file) => _companyIdPhotoFile = file),
        ),
        const SizedBox(height: 16),
        _field(
          controller: companyEmployeeIdController,
          label: 'Company ID Mention',
          hint: 'Enter employee or company ID',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.selectedRole == 'worker' ? 'Worker' : 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleLabel Registration'),
        backgroundColor: const Color(0xff0F2A44),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff0F2A44),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$roleLabel Registration Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Common registration form for both user and worker.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _uploadField(
              title: 'Photo (Optional)',
              subtitle: 'You can choose a profile photo from your phone, or skip this field',
              selectedFile: _profilePhotoFile,
              onPick: () => _pickImage((file) => _profilePhotoFile = file),
            ),
            const SizedBox(height: 16),
            _field(
              controller: nameController,
              label: 'Name',
            ),
            const SizedBox(height: 16),
            _field(
              controller: contactController,
              label: 'Contact No.',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _field(
              controller: aadhaarController,
              label: 'Aadhaar No.',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _uploadField(
              title: 'Aadhaar Card Photo (Optional)',
              subtitle: 'You can choose Aadhaar card image from your phone, or skip this field',
              selectedFile: _aadhaarPhotoFile,
              onPick: () => _pickImage((file) => _aadhaarPhotoFile = file),
            ),
            const SizedBox(height: 16),
            _field(
              controller: emailController,
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _field(
              controller: passwordController,
              label: 'Create Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _field(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              obscureText: true,
            ),
            _workerOptionalSection(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF4F7FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'e-Sahayta ID will be auto-generated in the format eS-XXXXXXXX for both user and worker after registration. Photo and Aadhaar photo are optional.',
                style: TextStyle(
                  color: Color(0xff475467),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signup,
                  child: const Text('Submit'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
