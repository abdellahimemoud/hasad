import 'package:flutter/material.dart';
import 'package:hasad_app/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF256454)),
            ),
            const SizedBox(height: 20),
            _buildOption(context, "🇬🇧 English", const Locale('en')),
            _buildOption(context, "🇫🇷 Français", const Locale('fr')),
            _buildOption(context, "🇩🇿 العربية", const Locale('ar')),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String name, Locale locale) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: const Icon(Icons.language, color: Color(0xFF256454)),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: () {
        MyApp.setLocale(context, locale);
        Navigator.of(context).pop();
      },
    );
  }
}
