void main() {
  final Map<String, double> tarifZona = {
    'Bandung': 6000,
    'Surabaya': 8500,
    'Makassar': 14000,
    'Jayapura': 21000,
  };

  final List<Map<String, Object>> kiriman = [
    {'resi': 'SLG-001', 'kota': 'Bandung', 'berat': 3.0},
    {'resi': 'SLG-002', 'kota': 'Surabaya', 'berat': 12.5},
    {'resi': 'SLG-003', 'kota': 'Makassar', 'berat': 7.2},
    {'resi': 'SLG-004', 'kota': 'Surabaya', 'berat': 4.8},
    {'resi': 'SLG-005', 'kota': 'Jayapura', 'berat': 18.0},
    {'resi': 'SLG-006', 'kota': 'Bandung', 'berat': 2.5},
    {'resi': 'SLG-007', 'kota': 'Makassar', 'berat': 9.0},
    {'resi': 'SLG-008', 'kota': 'Jayapura', 'berat': 15.5},
  ];

  double totalPendapatan = 0;
  final Map<String, double> rekapPerKota = {};

  for (final item in kiriman) {
    final kota = item['kota'] as String;
    final berat = item['berat'] as double;
    final tarif = tarifZona[kota] ?? 0;
    final biaya = berat * tarif;

    totalPendapatan += biaya;

    rekapPerKota[kota] =
        (rekapPerKota[kota] ?? 0) + biaya;

    print(
      '${item['resi']} $kota ${berat}kg '
      'Rp${biaya.toStringAsFixed(0)}',
    );
  }

  print('\n--- Rekapitulasi per Kota ---');

  rekapPerKota.forEach((kota, total) {
    print('$kota : Rp${total.toStringAsFixed(0)}');
  });

  print(
    'Total pendapatan : '
    'Rp${totalPendapatan.toStringAsFixed(0)}',
  );
}