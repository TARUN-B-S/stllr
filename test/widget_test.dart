import 'package:flutter_test/flutter_test.dart';
import 'package:steller_market/main.dart';

void main() {
  testWidgets('login screen renders', (tester) async {
    await tester.pumpWidget(const StellerApp());
    expect(find.text('Steller Market'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
