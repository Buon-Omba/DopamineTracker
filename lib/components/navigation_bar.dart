import 'package:flutter/material.dart';
import 'package:dopamine_tracker/screens/home_screen.dart';
import 'package:dopamine_tracker/screens/calendar_screen.dart';
import 'package:dopamine_tracker/screens/health_screen.dart';
import 'package:dopamine_tracker/screens/stats_screen.dart';
import 'package:dopamine_tracker/screens/daily_log_screen.dart';
import 'package:dopamine_tracker/l10n/app_localizations.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(ThemeMode) setThemeMode;

  const CustomNavigationBar({super.key, required this.currentIndex, required this.setThemeMode});

  Future<void> _onItemTapped(BuildContext context, int index) async {
    if (index != currentIndex) {
      Widget? targetScreen;

      switch (index) {
        case 0:
          targetScreen = HomeScreen(setThemeMode: setThemeMode);
          break;
        case 1:
          targetScreen = HealthScreen(setThemeMode: setThemeMode);
          break;
        case 2:
          targetScreen = CalendarScreen(setThemeMode: setThemeMode);
          break;
        case 3:
          targetScreen = DailyLogScreen(setThemeMode: setThemeMode);
          break;
        case 4:
          targetScreen = StatsScreen(setThemeMode: setThemeMode);
          break;
        default:
          return;
      }

      final direction =
          index > currentIndex ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

      _navigateWithCustomTransition(context, targetScreen, direction);
        }
  }

  void _navigateWithCustomTransition(
      BuildContext context, Widget screen, Offset direction) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: direction, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.navigationBarHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.health_and_safety),
          label: l10n.navigationBarHealthGoals,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month),
          label: l10n.navigationBarCalendar,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.edit_calendar),
          label: l10n.navigationBarDailyLog,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: l10n.statsScreenTitle,
        ),
      ],
    );
  }
}
