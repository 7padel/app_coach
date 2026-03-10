import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_utils.dart';
import '../core/services/api_service.dart';
import '../models/coach_profile_model.dart';

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

  String? _gender;
  String? _specializationLevel;
  DateTime? _dob;
  bool _loading = false;

  static const _genders = ['male', 'female'];
  static const _levels = ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _bioCtrl = TextEditingController(text: p.bio ?? '');
    _expCtrl = TextEditingController(
        text: p.experienceYears?.toString() ?? '');
    _gender = p.gender;
    _specializationLevel = p.specializationLevel;
    if (p.dateOfBirth != null) {
      _dob = DateTime.tryParse(p.dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final payload = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        if (_gender != null) 'gender': _gender,
        if (_specializationLevel != null)
          'specialization_level': _specializationLevel,
        if (_expCtrl.text.isNotEmpty)
          'experience_years': int.tryParse(_expCtrl.text),
        if (_dob != null)
          'date_of_birth': _dob!.toIso8601String().substring(0, 10),
      };
      await ApiService().updateMe(context, payload);
      AppUtils.showToast('Profile updated');
      if (mounted) Navigator.pop(context);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card([
                _field(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                _dropdown(
                  label: 'Gender',
                  value: _gender,
                  items: _genders,
                  onChanged: (v) => setState(() => _gender = v),
                ),
                _dropdown(
                  label: 'Specialization Level',
                  value: _specializationLevel,
                  items: _levels,
                  onChanged: (v) =>
                      setState(() => _specializationLevel = v),
                ),
                _field(
                  controller: _expCtrl,
                  label: 'Years of Experience',
                  keyboardType: TextInputType.number,
                ),
                _dobPicker(),
                _field(
                  controller: _bioCtrl,
                  label: 'Bio',
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                    e[0].toUpperCase() + e.substring(1))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dobPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _dob ?? DateTime(1995),
            firstDate: DateTime(1950),
            lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
          );
          if (picked != null) setState(() => _dob = picked);
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 18, color: Colors.black45),
              const SizedBox(width: 10),
              Text(
                _dob != null
                    ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                    : 'Date of Birth',
                style: TextStyle(
                    fontSize: 14,
                    color:
                        _dob != null ? Colors.black87 : Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
