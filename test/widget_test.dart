import 'package:flutter_test/flutter_test.dart';
import 'package:healthbuddy/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthBuddyApp());
    expect(find.text('Hoy'), findsOneWidget);
  });
}
