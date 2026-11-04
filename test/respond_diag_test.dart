import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fonts.dart';

// Mimics the Respond button exactly: inline styleFrom, textStyle with
// fontWeight but NO fontFamily.
Widget _respondButton() => FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF1D66CC),
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  onPressed: () {},
  child: const Text('Respond'),
);

void main() {
  setUpAll(() => loadRobotoFonts(['Roboto-Regular.ttf', 'Roboto-Bold.ttf']));

  testWidgets('respond box vs defaultstyle wrap', (tester) async {
    tester.view.physicalSize = const Size(700, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('A: bare (expect boxes):'),
                const SizedBox(height: 6),
                _respondButton(),
                const SizedBox(height: 24),
                const Text('B: inside DefaultTextStyle wrap:'),
                const SizedBox(height: 6),
                // Harness-only candidate fix: force Roboto on the ambient
                // DefaultTextStyle so inline styles with null fontFamily
                // inherit it instead of the box font.
                DefaultTextStyle(
                  style: const TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.black),
                  child: _respondButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/respond-diag.png'));
  });
}
