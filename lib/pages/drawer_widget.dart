import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hasad_app/pages/contact_popup.dart';
import 'package:hasad_app/pages/profile_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hasad_app/pages/recommandation_Details.dart';
import 'package:hasad_app/widgets/language_picker_dialog.dart';

class DrawerWidget extends StatelessWidget {
  final void Function()? onLogout;
  final User? user;
  final void Function(int)? onSelectPage;

  const DrawerWidget({
    super.key,
    this.onLogout,
    this.user,
    this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 37, 100, 84),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Color(0xFF173F35)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _drawerItem(
            icon: Icons.insert_chart_outlined,
            label: AppLocalizations.of(context)!.recommendations,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const RecommandationDetailsPage(),
              );
            },
          ),
          _drawerItem(
            icon: Icons.cloud_outlined,
            label: AppLocalizations.of(context)!.weather,
            onTap: () {
              Navigator.pop(context);
              if (onSelectPage != null) onSelectPage!(2); // MeteoPage index
            },
          ),
          _drawerItem(
            icon: Icons.camera_alt_outlined,
            label: AppLocalizations.of(context)!.diseaseDetection,
            onTap: () {
              Navigator.pop(context);
              if (onSelectPage != null) onSelectPage!(1); // MaladiePage index
            },
          ),
          _drawerItem(
            icon: Icons.person_outline,
            label: AppLocalizations.of(context)!.profile,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const ProfilePopup(),
              );
            },
          ),
          _drawerItem(
            icon: Icons.info_outline,
            label: AppLocalizations.of(context)!.contactUs,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const ContactPopup(),
              );
            },
          ),
          _drawerItem(
            icon: Icons.language,
            label: AppLocalizations.of(context)!.language,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const LanguagePickerDialog(),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.logOut,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  ListTile _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF173F35)),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF173F35),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
