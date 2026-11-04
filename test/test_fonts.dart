import 'dart:io';

import 'package:flutter/services.dart';

String _join(String first, List<String> parts) => <String>[first, ...parts].join(Platform.pathSeparator);

String _flutterRoot() {
  final configured = Platform.environment['FLUTTER_ROOT'];
  if (configured != null && configured.isNotEmpty) return configured;

  var directory = File(Platform.resolvedExecutable).parent;
  while (directory.path != directory.parent.path) {
    final cache = Directory(_join(directory.path, ['bin', 'cache']));
    if (cache.existsSync()) return directory.path;
    directory = directory.parent;
  }
  throw StateError('Unable to locate Flutter SDK. Set FLUTTER_ROOT before running golden tests.');
}

Future<void> loadRobotoFonts(List<String> files, {bool includeMaterialIcons = false}) async {
  final root = _flutterRoot();
  final fontDirectory = _join(root, [
    'bin',
    'cache',
    'dart-sdk',
    'bin',
    'resources',
    'devtools',
    'assets',
    'fonts',
    'Roboto',
  ]);
  final roboto = FontLoader('Roboto');
  for (final file in files) {
    final bytes = Uint8List.fromList(File(_join(fontDirectory, [file])).readAsBytesSync());
    roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await roboto.load();

  if (!includeMaterialIcons) return;
  final iconCandidates = [
    _join(root, ['bin', 'cache', 'artifacts', 'material_fonts', 'MaterialIcons-Regular.otf']),
    _join(root, [
      'bin',
      'cache',
      'dart-sdk',
      'bin',
      'resources',
      'devtools',
      'assets',
      'fonts',
      'MaterialIcons-Regular.otf',
    ]),
  ];
  final iconFile = iconCandidates
      .map(File.new)
      .firstWhere(
        (file) => file.existsSync(),
        orElse: () => throw StateError('MaterialIcons-Regular.otf was not found in the Flutter SDK.'),
      );
  final icons = Uint8List.fromList(iconFile.readAsBytesSync());
  final iconLoader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(icons.buffer)));
  await iconLoader.load();
}
