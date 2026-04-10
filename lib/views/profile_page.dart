import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/utils/app_utils.dart';
import '../core/utils/page_route_utils.dart';
import '../core/utils/shared_preferences_util.dart';
import '../viewmodels/profile_view_model.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/settings_widget.dart';
import 'edit_profile_page.dart';
import 'login_view.dart';
import 'booking_history_page.dart';
import 'time_offs_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileViewModel>(
      model: ProfileViewModel(),
      onModelReady: (vm) => vm.loadProfile(context),
      builder: (context, vm, _) => Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Column(
          children: [
            Container(
              color: const Color(0xFF1D3916),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.profile == null
                      ? const Center(child: Text('Failed to load profile'))
                      : _buildContent(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileViewModel vm) {
    final p = vm.profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfilePage(profile: p)),
              );
              vm.loadProfile(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D3916),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.secondary,
                    backgroundImage: p.profilePictureUrl != null && p.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(p.profilePictureUrl!)
                        : null,
                    child: p.profilePictureUrl == null || p.profilePictureUrl!.isEmpty
                        ? Icon(Icons.person, size: 28, color: AppColors.primary)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          SettingsSection(
            showSectionTitle: false,
            tiles: [
              SettingsTile(
                title: 'Edit Profile',
                subtitle: 'Update Your Personal Details',
                icon: Icons.person,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfilePage(profile: p)),
                  );
                  vm.loadProfile(context);
                },
              ),
              SettingsTile(
                title: 'Manage Time-offs',
                subtitle: 'Set Your Availability',
                icon: Icons.event_busy_outlined,
                onTap: () {
                  PageRouteUtils.push(context, const TimeOffsPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsSection(
            sectionTitle: 'Bookings',
            tiles: [
              SettingsTile(
                title: 'Your Booking History',
                icon: Icons.history,
                onTap: () {
                  PageRouteUtils.push(context, const BookingHistoryPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsSection(
            showSectionTitle: false,
            tiles: [
              SettingsTile(
                title: 'Log Out',
                icon: Icons.logout,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmationDialog(
                      icon: Icons.logout,
                      message: 'Are you sure to log out\nof your account?',
                      confirmText: 'Log Out',
                      cancelText: 'Cancel',
                      onConfirm: () async {
                        Navigator.pop(ctx);
                        await SharedPreferencesUtil().clear();
                        if (context.mounted) {
                          PageRouteUtils.pushAndRemoveUntil(context, const LoginView());
                        }
                      },
                      onCancel: () => Navigator.pop(ctx),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: 'Delete Account',
                icon: Icons.delete_outline,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmationDialog(
                      icon: Icons.delete,
                      message: 'All your records will be deleted.\nAre you sure you want to do this?',
                      confirmText: 'Delete',
                      cancelText: 'Cancel',
                      onConfirm: () async {
                        Navigator.pop(ctx);
                        try {
                          await ApiService().deleteMe(context);
                          await SharedPreferencesUtil().clear();
                          if (context.mounted) {
                            PageRouteUtils.pushAndRemoveUntil(context, const LoginView());
                          }
                        } catch (_) {
                          AppUtils.showToast('Failed to delete account');
                        }
                      },
                      onCancel: () => Navigator.pop(ctx),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'App Version: 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}
