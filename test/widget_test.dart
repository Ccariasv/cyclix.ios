import 'package:cyclix_mapa_detalle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CyclixApp se construye', (WidgetTester tester) async {
    await tester.pumpWidget(const CyclixApp());
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
