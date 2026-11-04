class Barang {
  /// Batas berat barang yang diizinkan, dalam kilogram.
  static const double beratMinimumKg = 0.1;
  static const double beratMaksimumKg = 5000;

  final String kode;
  final String nama;
  final String satuan;
  double _hargaSatuan;
  late double _beratKg;

  Barang({
    required this.kode,
    required this.nama,
    // Parameter publik sengaja dipisah dari field privat.
    required double hargaSatuan,
    required double beratKg,
    this.satuan = 'pcs',
    // ignore: prefer_initializing_formals
  }) : _hargaSatuan = hargaSatuan {
    // Lewat setter agar nilai berat selalu tervalidasi.
    this.beratKg = beratKg;
  }

  /// Konstruktor bernama untuk data hasil pemindaian kode barang.
  ///
  /// Format: `kode;nama;hargaSatuan[;beratKg]`.
  /// Bila berat tidak ikut dipindai, dipakai 1 kg sebagai nilai wajar.
  factory Barang.dariPemindaian(String baris) {
    final bagian = baris.split(';');

    if (bagian.length < 3) {
      throw ArgumentError(
        'Format pemindaian harus kode;nama;harga[;beratKg]',
      );
    }

    return Barang(
      kode: bagian[0].trim(),
      nama: bagian[1].trim(),
      hargaSatuan: double.parse(bagian[2].trim()),
      beratKg: bagian.length > 3 ? double.parse(bagian[3].trim()) : 1,
    );
  }

  double get hargaSatuan => _hargaSatuan;

  set hargaSatuan(double nilai) {
    if (nilai < 0) {
      throw ArgumentError('Harga satuan tidak boleh negatif');
    }
    _hargaSatuan = nilai;
  }

  double get beratKg => _beratKg;

  /// Berat per satuan barang dalam kilogram.
  set beratKg(double nilai) {
    validasiBerat(nilai);
    _beratKg = nilai;
  }

  /// Validasi berat barang: harus di antara 0,1 kg dan 5000 kg.
  static void validasiBerat(double nilai) {
    if (nilai.isNaN || nilai < beratMinimumKg || nilai > beratMaksimumKg) {
      throw ArgumentError(
        'Berat barang harus antara ${beratMinimumKg.toStringAsFixed(1)} '
        'dan ${beratMaksimumKg.toStringAsFixed(0)} kg '
        '(diterima: $nilai kg)',
      );
    }
  }

  double nilaiTotal(int jumlah) => _hargaSatuan * jumlah;

  @override
  String toString() =>
      '[$kode] $nama ($satuan) - Rp${_hargaSatuan.toStringAsFixed(0)} '
      '- ${_beratKg.toStringAsFixed(1)} kg';
}
