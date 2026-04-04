import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_utils.dart';
import '../core/services/api_service.dart';
import '../models/coach_profile_model.dart';
import '../widgets/button.dart';

class EditProfilePage extends StatefulWidget {
  final CoachProfileModel profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _expCtrl;
  late final TextEditingController _dobCtrl;

  String? _gender;
  String? _specializationLevel;
  DateTime? _dob;
  bool _loading = false;
  bool _imageLoading = false;
  File? _pickedImage;
  String? _profileImageUrl;

  static const _genders = ['male', 'female'];
  static const _levels = ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _bioCtrl = TextEditingController(text: p.bio ?? '');
    _expCtrl = TextEditingController(text: p.experienceYears?.toString() ?? '');
    _gender = p.gender;
    _specializationLevel = p.specializationLevel;
    _profileImageUrl = p.profilePictureUrl;
    if (p.dateOfBirth != null) _dob = DateTime.tryParse(p.dateOfBirth!);
    _dobCtrl = TextEditingController(
      text: _dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;
    setState(() { _pickedImage = File(picked.path); _imageLoading = true; });
    try {
      final docId = await ApiService().uploadDocument(_pickedImage!.path);
      await ApiService().updateMe(context, {'profile_picture_id': docId});
      AppUtils.showToast('Profile photo updated');
    } catch (_) { /* fire-and-forget */
      AppUtils.showToast('Failed to upload photo');
    } finally {
      if (mounted) setState(() => _imageLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final payload = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        if (_gender != null) 'gender': _gender,
        if (_specializationLevel != null) 'specialization_level': _specializationLevel,
        if (_expCtrl.text.isNotEmpty) 'experience_years': int.tryParse(_expCtrl.text),
        if (_dob != null) 'date_of_birth': _dob!.toIso8601String().substring(0, 10),
      };
      await ApiService().updateMe(context, payload);
      AppUtils.showToast('Profile updated');
      if (mounted) Navigator.pop(context);
    } catch (_) { /* fire-and-forget */
      AppUtils.showToast('Failed to update profile');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({String? labelText, String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1D3916))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1D3916))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1D3916), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: const Color(0xFF1D3916),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      const Expanded(child: Center(child: Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Profile image
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty ? NetworkImage(_profileImageUrl!) as ImageProvider : null),
                                child: _imageLoading
                                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                    : (_pickedImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                                        ? Icon(Icons.person, size: 36, color: AppColors.primary)
                                        : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.add, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name
                      TextFormField(controller: _nameCtrl, decoration: _inputDecoration(labelText: 'Full Name', hintText: 'Enter your full name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),

                      // Email (disabled)
                      TextFormField(enabled: false, initialValue: widget.profile.email ?? '', decoration: _inputDecoration(labelText: 'Email')),
                      const SizedBox(height: 16),

                      // CC + Phone (disabled)
                      Row(children: [
                        SizedBox(width: 80, child: TextFormField(enabled: false, initialValue: '+91', decoration: _inputDecoration(labelText: 'CC'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(enabled: false, initialValue: widget.profile.phoneNumber, decoration: _inputDecoration(labelText: 'Phone'))),
                      ]),
                      const SizedBox(height: 16),

                      // Date of Birth
                      TextFormField(
                        controller: _dobCtrl, readOnly: true,
                        decoration: _inputDecoration(labelText: 'Date of Birth', hintText: 'Select Date of Birth', suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey)),
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: _dob ?? DateTime.now().subtract(const Duration(days: 365 * 25)), firstDate: DateTime(1950), lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)));
                          if (picked != null) setState(() { _dob = picked; _dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}'; });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(controller: _bioCtrl, decoration: _inputDecoration(labelText: 'Description', hintText: 'Tell us about yourself'), maxLines: 4),
                      const SizedBox(height: 32),

                      // Save
                      SizedBox(width: double.infinity, height: 48, child: Button(onPressed: _loading ? () {} : _save, text: 'Save')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
