import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/widgets/language_selector.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        centerTitle: true,
        actions: const [
          LanguageSelector(),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (!controller.isLoggedIn) {
          return _buildNotLoggedInView();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildUserInfoCard(),
                const SizedBox(height: 16),
                if (controller.isLicensee) _buildLicenseeInfoCard(),
                if (controller.isLicensee) const SizedBox(height: 16),
                _buildAccountInfoCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'not_logged_in'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'login_to_view_profile'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.navigateToLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('login'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0275FF),
            const Color(0xFF0275FF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0275FF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              controller.userInitials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.userDisplayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.userTypeLabel,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return _buildInfoCard(
      title: 'personal_info'.tr,
      icon: Icons.person_outline,
      children: [
        if (controller.hasFirstName)
          _buildInfoRow('first_name'.tr, controller.firstName!),
        if (controller.hasLastName)
          _buildInfoRow('last_name'.tr, controller.lastName!),
        _buildInfoRow('user_type'.tr, controller.userTypeLabel),
        _buildInfoRow('role'.tr, controller.userRole),
      ],
    );
  }

  Widget _buildLicenseeInfoCard() {
    return _buildInfoCard(
      title: 'licensee_info'.tr,
      icon: Icons.card_membership_outlined,
      children: [
        if (controller.hasLicenseeNumber)
          _buildInfoRow('license_number'.tr, controller.licenseeNumber!),
        if (controller.hasClub) _buildInfoRow('club'.tr, controller.clubName!),
        if (controller.hasYear)
          _buildInfoRow('birth_year'.tr, controller.birthYear!),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return _buildInfoCard(
      title: 'account_info'.tr,
      icon: Icons.settings_outlined,
      children: [
        _buildInfoRow('label'.tr, controller.userLabel),
        _buildInfoRow('token_expires'.tr, controller.tokenExpirationFormatted),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF0275FF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.refreshProfile,
            icon: const Icon(Icons.refresh),
            label: Text('refresh_profile'.tr),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF0275FF),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            label: Text('logout'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
