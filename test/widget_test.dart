// Smoke test untuk memastikan aplikasi SiLog dapat dirender.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silog_app/main.dart';

void main() {
  testWidgets('Halaman daftar pengiriman tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pengiriman'), findsOneWidget);
    expect(find.text('SLG-2026-0001'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('Mengetuk kartu membuka halaman detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SLG-2026-0001'));
    await tester.pumpAndSettle();

    expect(find.text('Informasi Pengiriman'), findsOneWidget);
    expect(find.text('Kembali ke Daftar'), findsOneWidget);
  });
}
