import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Function to open URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutDescriptionTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.aboutDescriptionText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.aboutLinksTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Text(
                AppLocalizations.of(context)!.aboutLinksViewSourceCode,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              onTap: () => _launchURL('https://forgejo.it/Buon-Omba/DopamineTracker'),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.aboutCreditsTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.aboutCreditsText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Text(
                AppLocalizations.of(context)!.aboutCreditsOpenMoji,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              onTap: () => _launchURL('https://openmoji.org/'),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Text(
                AppLocalizations.of(context)!.aboutCreditsMyWebsite,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              onTap: () => _launchURL('https://retiolus.net/'),
            ),
          ],
        ),
      ),
    );
  }
}
