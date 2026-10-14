class ResiTidakDitemukan implements Exception {
  final String resi;

  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan.';
}


// Data status kiriman
final Map<String, String> dataKiriman = {
  'SLG-001': 'Sedang diproses di gudang Bandung',
  'SLG-002': 'Sedang dalam perjalanan menuju Surabaya',
  'SLG-003': 'Sudah tiba di gudang Jakarta',
  'SLG-004': 'Sedang dalam perjalanan menuju Makassar',
  'SLG-005': 'Sudah diterima oleh penerima',
};


// Mengambil status kiriman berdasarkan resi
Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda jaringan
  await Future.delayed(const Duration(seconds: 1));

  final status = dataKiriman[resi];

  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }

  return status;
}


// Memantau banyak resi secara bersamaan
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  print('=== PEMANTAUAN BANYAK RESI ===');

  final hasil = await Future.wait(
    daftarResi.map((resi) async {
      try {
        final status = await ambilStatusKiriman(resi);

        print('BERHASIL | $resi | $status');

        return true;
      } on ResiTidakDitemukan catch (e) {
        print('GAGAL    | $resi | $e');

        return false;
      } catch (e) {
        print('ERROR    | $resi | $e');

        return false;
      }
    }),
  );

  final jumlahBerhasil = hasil.where((hasil) => hasil).length;
  final jumlahGagal = hasil.length - jumlahBerhasil;

  print('\n=== HASIL PEMANTAUAN ===');
  print('Total resi     : ${daftarResi.length}');
  print('Berhasil       : $jumlahBerhasil');
  print('Gagal          : $jumlahGagal');
}


// Skenario 1: seluruh resi sah
Future<void> skenarioSemuaSah() async {
  print('\n================================');
  print('SKENARIO 1: SEMUA RESI SAH');
  print('================================');

  await pantauBanyakResi([
    'SLG-001',
    'SLG-002',
    'SLG-003',
    'SLG-004',
    'SLG-005',
  ]);
}


// Skenario 2: terdapat resi tidak sah
Future<void> skenarioAdaYangTidakSah() async {
  print('\n================================');
  print('SKENARIO 2: ADA RESI TIDAK SAH');
  print('================================');

  await pantauBanyakResi([
    'SLG-001',
    'SLG-999',
    'SLG-003',
    'SLG-888',
    'SLG-005',
  ]);
}


Future<void> main() async {
  await skenarioSemuaSah();

  await skenarioAdaYangTidakSah();
}