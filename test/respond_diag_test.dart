import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _dir =
    '/tools/App-Dev-Env/flutter/bin/cache/dart-sdk/bin/resources/devtools/assets/fonts/Roboto';

Future<void> _load() async {
  final roboto = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Bold.ttf']) {
    final bytes = Uint8List.fromList(File('$_dir/$f').readAsBytesSync());
    roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await roboto.load();
}

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
  setUpAll(_load);

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
                  style: const TextStyle(
                      fontFamily: 'Roboto', fontSize: 14, color: Colors.black),
                  child: _respondButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/respond-diag.png'),
    );
  });
}
