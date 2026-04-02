import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../models/coach_profile_model.dart';
import '../viewmodels/profile_view_model.dart';
import 'edit_profile_page.dart';
import 'time_offs_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileViewModel>(
      model: ProfileViewModel(),
      onModelReady: (vm) => vm.loadProfile(context),
      builder: (context, vm, _) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Profile',
              style: TextStyle(fontWeight: FontWeight.w600)),
          elevation: 0,
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.profile == null
                ? const Center(child: Text('Failed to load profile'))
                : _ProfileBody(vm: vm),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileViewModel vm;
  const _ProfileBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    final p = vm.profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar + Name + Status
          _AvatarCard(profile: p),
          const SizedBox(height: 12),
          // Info card
          _InfoCard(profile: p),
          const SizedBox(height: 12),
          // Actions
          _ActionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditProfilePage(profile: p)),
              );
              if (context.mounted) vm.loadProfile(context);
            },
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.event_busy_outlined,
            label: 'Manage Time-offs',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimeOffsPage()),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, vm),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, ProfileViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.logout(context);
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final CoachProfileModel profile;
  const _AvatarCard({required this.profile});

  Color get _statusColor {
    switch (profile.approvalStatus) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty
                ? NetworkImage(profile.profilePictureUrl!)
                : null,
            child: profile.profilePictureUrl == null || profile.profilePictureUrl!.isEmpty
                ? Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(profile.fullName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.approvalStatus.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                  letterSpacing: 0.5),
            ),
          ),
          // Rating removed from coach profile
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CoachProfileModel profile;
  const _InfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: Column(
        children: [
          _Row(icon: Icons.phone_outlined, label: profile.phoneNumber),
          if (profile.email != null)
            _Row(icon: Icons.email_outlined, label: profile.email!),
          if (profile.specializationLevel != null)
            _Row(
                icon: Icons.sports_tennis,
                label: _capitalize(profile.specializationLevel!)),
          if (profile.experienceYears != null)
            _Row(
                icon: Icons.workspace_premium_outlined,
                label: '${profile.experienceYears} years experience'),
          if (profile.bio != null && profile.bio!.isNotEmpty)
            _Row(icon: Icons.info_outline, label: profile.bio!),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF333333))),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
