mixin Terlacak {
  final List<String> _riwayat = [];

  List<String> get riwayat => List.unmodifiable(_riwayat);

  void catatPosisi(String lokasi) {
    final waktu =
        DateTime.now().toIso8601String().substring(11, 16);
    _riwayat.add('[$waktu] $lokasi');
  }

  String posisiTerakhir() =>
      _riwayat.isEmpty ? 'Belum ada data posisi' : _riwayat.last;
}

abstract class LayananPengiriman {
  final String kodeLayanan;
  final double jarakKm;
  final double beratKg;

  LayananPengiriman({
    required this.kodeLayanan,
    required this.jarakKm,
    required this.beratKg,
  });

  /// Wajib diisi oleh setiap moda pengiriman.
  double hitungTarif();

  /// Wajib diisi oleh setiap moda pengiriman.
  int estimasiHari();

  /// Implementasi umum yang diwarisi seluruh turunan.
  String ringkasan() {
    final tarif = hitungTarif().toStringAsFixed(0);

    return '$kodeLayanan | '
        '${jarakKm.toStringAsFixed(0)} km | '
        '${beratKg.toStringAsFixed(1)} kg | '
        'Rp$tarif | ${estimasiHari()} hari';
  }
}

mixin Terasuransi {
  double persentasePremi = 0.02;

  double hitungPremi(double nilaiBarang) {
    return nilaiBarang * persentasePremi;
  }
}