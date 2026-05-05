import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/main_screen.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget_provider.dart';
import 'services/smoke_log_service.dart';

void main() => runApp(const DopamineTrackerApp());

class DopamineTrackerApp extends StatefulWidget {
  const DopamineTrackerApp({super.key});

  /// Requests the native side to refresh all home screen widgets.
  static Future<void> updateHomeWidgets() async {
    await WidgetProvider.updateWidgets();
  }

  @override
  State<DopamineTrackerApp> createState() => _DopamineTrackerAppState();
}

class _DopamineTrackerAppState extends State<DopamineTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;
  bool _isFirstRun = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.system,
    );

    // Check if it's the first run (no addictions configured)
    final addictions = await DopamineLogService.getAddictions();
    _isFirstRun = addictions.isEmpty;

    setState(() {
      _isLoading = false;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3));
          darkColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3), brightness: Brightness.dark);
        }

        return MaterialApp(
          title: 'Dopamine Tracker',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: _buildTheme(lightColorScheme),
          darkTheme: _buildTheme(darkColorScheme),
          themeMode: _themeMode,
          home: _isFirstRun 
            ? _OnboardingScreen(onComplete: () => setState(() => _isFirstRun = false))
            : MainScreen(setThemeMode: _setThemeMode),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

class _OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const _OnboardingScreen({required this.onComplete});

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final _controller = TextEditingController();
  String? _errorText;

  String _formatName(String input) {
    if (input.isEmpty) return "";
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  bool _isOnlyText(String input) {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Benvenuto!",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Qual è la dipendenza che vuoi iniziare a tracciare?",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Esempio: Social Media, Zucchero, Fumo...",
                errorText: _errorText,
              ),
              autofocus: true,
              onChanged: (_) => setState(() => _errorText = null),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final input = _controller.text.trim();
                if (input.isEmpty) {
                  setState(() => _errorText = "Inserisci un nome");
                  return;
                }
                if (!_isOnlyText(input)) {
                  setState(() => _errorText = "Inserisci solo lettere");
                  return;
                }
                
                final formattedName = _formatName(input);
                await DopamineLogService.addAddiction(formattedName);
                widget.onComplete();
              },
              child: const Text("Inizia il viaggio"),
            ),
          ],
        ),
      ),
    );
  }
}
