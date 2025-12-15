import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/language_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final langController = Get.find<LanguageController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'.tr),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.saveSettings,
            child: Text(
              'Save'.tr,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    // Avatar Display
                    Obx(
                      () => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        // Reconstruct full path here
                        backgroundImage: AssetImage(
                          'assets/avatars/${controller.tempAvatar.value}',
                        ),
                      ),
                    ),
                    // Edit Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showAvatarSelectionSheet(context),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  controller.currentUser?.name ?? 'User'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 4),
                Text(
                  controller.currentUser?.email ?? 'No Email'.tr,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // --- Personal Info Section ---
          ProfileSection(
            children: [
              ProfileItem(
                icon: Icons.person_outline,
                title: 'Full Name'.tr,
                value: controller.currentUser?.name ?? 'User'.tr,
              ),

              const CustomDivider(),
              ProfileItem(
                icon: Icons.email_outlined,
                title: 'Email'.tr,
                value: controller.currentUser?.email ?? 'No Email'.tr,
              ),

              const CustomDivider(),

              ProfileItem(
                icon: Icons.lock_outline,
                title: 'Change Password'.tr,
                hasNavigation: true,
                onTap: () => Get.toNamed('/update_password'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- Settings Section ---
          ProfileSection(
            children: [
              Obx(
                () => SwitchItem(
                  icon: Icons.language,
                  title: 'Language'.tr,
                  value: langController.isArabic.value,
                  onChanged: (val) {
                    langController.toggleLanguage(val);
                  },
                ),
              ),

              const CustomDivider(),
              Obx(
                () => SwitchItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: controller.themeController.isDarkMode.value,
                  onChanged: (value) => controller.toggleDarkMode(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Action Buttons ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Log Out'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: controller.deleteAccount,
            child: Text(
              'Delete Account'.tr,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showAvatarSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Avatar'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: controller.avatarFilenames.length,
                  itemBuilder: (context, index) {
                    final filename = controller.avatarFilenames[index];
                    return GestureDetector(
                      onTap: () => controller.selectAvatar(filename),
                      child: CircleAvatar(
                        // Reconstruct full path for display
                        backgroundImage: AssetImage('assets/avatars/$filename'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Reusable Components (Stateless) ---
class ProfileSection extends StatelessWidget {
  final List<Widget> children;
  const ProfileSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool hasNavigation;
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.hasNavigation = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value!,

                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            if (hasNavigation) ...[
              if (value != null) const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodySmall?.color,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).textTheme.bodySmall?.color,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).dividerColor,
      indent: 54,
    );
  }
}
