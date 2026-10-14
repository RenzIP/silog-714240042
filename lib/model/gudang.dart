import 'barang.dart';

class Gudang {
  final String kode;
  final String nama;
  final String kota;
  final int kapasitas;
  final Map<String, int> _stok = {};

  Gudang({
    required this.kode,
    required this.nama,
    required this.kota,
    this.kapasitas = 1000,
  });

  int get totalStok => _stok.values.fold(0, (a, b) => a + b);

  bool get penuh => totalStok >= kapasitas;

  Map<String, int> get stok => Map.unmodifiable(_stok);

  void terimaBarang(Barang barang, int jumlah) {
    if (jumlah <= 0) {
      throw ArgumentError('Jumlah penerimaan harus lebih besar dari nol');
    }
    if (totalStok + jumlah > kapasitas) {
      throw StateError('Kapasitas gudang $nama tidak mencukupi');
    }
    _stok[barang.kode] = (_stok[barang.kode] ?? 0) + jumlah;
  }

  void keluarkanBarang(Barang barang, int jumlah) {
    final tersedia = _stok[barang.kode] ?? 0;
    if (jumlah > tersedia) {
      throw StateError(
        'Stok ${barang.kode} hanya $tersedia, tidak dapat mengeluarkan $jumlah',
      );
    }
    _stok[barang.kode] = tersedia - jumlah;
  }

  @override
  String toString() => '$kode - $nama ($kota), stok $totalStok/$kapasitas';
}