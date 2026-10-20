import 'package:flutter_test/flutter_test.dart';
import 'package:steller_market/data/models.dart';
import 'package:steller_market/theme.dart';
import 'package:steller_market/widgets/common.dart';

void main() {
  test('AppUser initials use first and last', () {
    expect(AppUser(uid: 'a', name: 'Aarav Mehta', email: 'a@b.c', role: UserRole.buyer).initials, 'AM');
    expect(AppUser(uid: 'a', name: 'Diya', email: 'a@b.c', role: UserRole.buyer).initials, 'D');
    expect(AppUser(uid: 'a', name: '   ', email: 'a@b.c', role: UserRole.buyer).initials, '?');
  });

  test('role round-trips through Firestore string', () {
    expect(roleToName(UserRole.seller), 'seller');
    expect(userRoleFrom('seller'), UserRole.seller);
    expect(userRoleFrom('buyer'), UserRole.buyer);
    expect(userRoleFrom(null), UserRole.buyer);
  });

  test('brand theme exposes the Steller palette', () {
    final theme = buildTheme();
    expect(theme.appBarTheme.backgroundColor, Steller.charcoal);
    expect(theme.scaffoldBackgroundColor, Steller.background);
  });

  testWidgets('crest logo paints without error', (tester) async {
    await tester.pumpWidget(const CrestLogo(size: 48));
    expect(find.byType(CrestLogo), findsOneWidget);
  });
}
