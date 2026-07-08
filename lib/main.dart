import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    // ProviderScope habilita Riverpod en toda la app.
    const ProviderScope(child: PromApp()),
  );
}
