import 'package:dopamine_tracker/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const DopamineTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Dopamine Tracker'), findsOneWidget);
  });
}
