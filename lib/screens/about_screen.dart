import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import '../services/smoke_log_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _addictionName = 'Dopamine';

  @override
  void initState() {
    super.initState();
    _loadAddictionName();
  }

  Future<void> _loadAddictionName() async {
    final addictions = await DopamineLogService.getAddictions();
    if (addictions.isNotEmpty) {
      setState(() {
        _addictionName = addictions.first.name;
      });
    }
  }

  // Function to open URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutScreenTitle(_addictionName)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutDescriptionTitle(_addictionName),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.aboutDescriptionText(_addictionName),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aboutLinksTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Text(
                l10n.aboutLinksViewSourceCode,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              onTap: () => _launchURL('https://forgejo.it/Buon-Omba/DopamineTracker'),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aboutCreditsTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
           /* const SizedBox(height: 10),
            Text(
              l10n.aboutCreditsText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Text(
                l10n.aboutCreditsOpenMoji,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              onTap: () => _launchURL('https://openmoji.org/'),
            ),
            const SizedBox(height: 10),*/
            InkWell(
              child: Text(
                l10n.aboutCreditsMyWebsite,
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
