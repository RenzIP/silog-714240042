// Smoke test & uji perilaku untuk aplikasi SiLog.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silog_app/main.dart';
import 'package:silog_app/model/barang.dart';

/// Mengisi seluruh field pada FormPengirimanPage.
Future<void> _isiForm(
  WidgetTester tester, {
  required String resi,
  required String berat,
}) async {
  final fields = find.byType(TextFormField);

  await tester.enterText(fields.at(0), resi);
  await tester.enterText(fields.at(1), 'Barang Uji');
  await tester.enterText(fields.at(2), '10000');
  await tester.enterText(fields.at(3), berat);
  await tester.enterText(fields.at(4), '2');
  await tester.pumpAndSettle();
}

Future<void> _bukaForm(WidgetTester tester) async {
  await tester.tap(find.text('Pengiriman Baru'));
  await tester.pumpAndSettle();
}

Future<void> _tekanSimpan(WidgetTester tester) async {
  final tombol = find.text('Simpan Pengiriman');
  await tester.ensureVisible(tombol);
  await tester.pumpAndSettle();
  await tester.tap(tombol);
  await tester.pumpAndSettle();
}

void main() {
  group('Validasi model Barang', () {
    Barang buat(double berat) => Barang(
          kode: 'B-1',
          nama: 'Barang Uji',
          hargaSatuan: 1000,
          beratKg: berat,
        );

    test('berat di bawah 0,1 kg ditolak', () {
      expect(() => buat(0.05), throwsArgumentError);
    });

    test('berat di atas 5000 kg ditolak', () {
      expect(() => buat(5001), throwsArgumentError);
    });

    test('berat pada batas bawah dan atas diterima', () {
      expect(buat(0.1).beratKg, 0.1);
      expect(buat(5000).beratKg, 5000);
    });
  });

  testWidgets('Halaman daftar pengiriman tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pengiriman'), findsOneWidget);
    expect(find.text('SLG-2026-0001'), findsOneWidget);
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
    expect(find.text('Hapus Pengiriman'), findsOneWidget);
  });

  testWidgets('Nomor resi yang sudah dipakai ditolak', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await _bukaForm(tester);
    await _isiForm(tester, resi: 'SLG-2026-0001', berat: '1');
    await _tekanSimpan(tester);

    expect(
      find.text('Nomor resi SLG-2026-0001 sudah dipakai pengiriman lain'),
      findsOneWidget,
    );
    // Masih di halaman form, belum kembali ke daftar.
    expect(find.text('Simpan Pengiriman'), findsOneWidget);
  });

  testWidgets('Berat di luar rentang 0,1 - 5000 kg ditolak', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await _bukaForm(tester);
    await _isiForm(tester, resi: 'SLG-2026-0099', berat: '6000');
    await _tekanSimpan(tester);

    expect(
      find.text('Berat barang harus antara 0.1 dan 5000 kg'),
      findsOneWidget,
    );
  });

  testWidgets('Pengiriman baru dengan data valid masuk ke daftar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await _bukaForm(tester);
    await _isiForm(tester, resi: 'SLG-2026-0099', berat: '0,8');
    await _tekanSimpan(tester);

    expect(find.text('SLG-2026-0099'), findsOneWidget);
    expect(find.text('Menampilkan 4 dari 4 data'), findsOneWidget);
  });

  testWidgets('Hapus pengiriman setelah konfirmasi AlertDialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SLG-2026-0001'));
    await tester.pumpAndSettle();

    final tombolHapus = find.text('Hapus Pengiriman');
    await tester.ensureVisible(tombolHapus);
    await tester.pumpAndSettle();
    await tester.tap(tombolHapus);
    await tester.pumpAndSettle();

    expect(find.text('Hapus pengiriman?'), findsOneWidget);

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0001'), findsNothing);
    expect(find.text('Menampilkan 2 dari 2 data'), findsOneWidget);
  });

  testWidgets('Batal pada AlertDialog tidak menghapus data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('SLG-2026-0001'));
    await tester.pumpAndSettle();

    final tombolHapus = find.text('Hapus Pengiriman');
    await tester.ensureVisible(tombolHapus);
    await tester.pumpAndSettle();
    await tester.tap(tombolHapus);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // Tetap di halaman detail, data belum terhapus.
    expect(find.text('Informasi Pengiriman'), findsOneWidget);
    expect(find.text('Hapus pengiriman?'), findsNothing);

    await tester.tap(find.text('Kembali ke Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0001'), findsOneWidget);
    expect(find.text('Menampilkan 3 dari 3 data'), findsOneWidget);
  });
}
