class Barang {
  final String kode;
  final String nama;
  final String satuan;
  double _hargaSatuan;
  double beratKg;

  Barang({
    required this.kode,
    required this.nama,
    required double hargaSatuan,
    this.satuan = 'pcs',
    this.beratKg = 0,
  }) : _hargaSatuan = hargaSatuan;

  /// Konstruktor bernama untuk data hasil pemindaian kode barang.
  Barang.dariPemindaian(String baris)
      : kode = baris.split(';')[0],
        nama = baris.split(';')[1],
        satuan = 'pcs',
        _hargaSatuan = double.parse(baris.split(';')[2]),
        beratKg = 0;

  double get hargaSatuan => _hargaSatuan;

  set hargaSatuan(double nilai) {
    if (nilai < 0) {
      throw ArgumentError('Harga satuan tidak boleh negatif');
    }
    _hargaSatuan = nilai;
  }

  double nilaiTotal(int jumlah) => _hargaSatuan * jumlah;

  @override
  String toString() =>
      '[$kode] $nama ($satuan) - Rp${_hargaSatuan.toStringAsFixed(0)}';
}