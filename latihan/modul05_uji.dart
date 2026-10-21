import '../lib/layanan/layanan_pengiriman.dart';
import '../lib/layanan/moda.dart';

void main() {
  final List<LayananPengiriman> daftarLayanan = [
    PengirimanTruk(kodeLayanan: 'TRK-REG', jarakKm: 780, beratKg: 1200),
    PengirimanTruk(
      kodeLayanan: 'TRK-EXP',
      jarakKm: 780,
      beratKg: 1200,
      ekspres: true,
    ),
    PengirimanKeretaApi(
      kodeLayanan: 'KA-CARGO',
      jarakKm: 780,
      beratKg: 1200,
      stasiunAsal: 'Kiaracondong',
      stasiunTujuan: 'Pasar Turi',
    ),
    PengirimanKapal(
      kodeLayanan: 'KPL-PETI',
      jarakKm: 1450,
      beratKg: 1200,
      volumeM3: 8.5,
    ),
    PengirimanUdara(
      kodeLayanan: 'UDR-REG',
      jarakKm: 1450,
      beratKg: 120,
      panjangCm: 100,
      lebarCm: 80,
      tinggiCm: 75,
    ),
  ];

  print('=== Perbandingan Layanan Pengiriman ===');

  for (final layanan in daftarLayanan) {
    print(layanan.ringkasan());
  }

  daftarLayanan.sort((a, b) => a.hitungTarif().compareTo(b.hitungTarif()));

  print('\nLayanan termurah : ${daftarLayanan.first.kodeLayanan}');

  print(
    'Layanan tercepat : '
    '${daftarLayanan.reduce((a, b) => a.estimasiHari() <= b.estimasiHari() ? a : b).kodeLayanan}',
  );

  // Pemanfaatan mixin Terlacak
  final truk = daftarLayanan.whereType<PengirimanTruk>().first;

  truk.catatPosisi('Gudang Utama Bandung');
  truk.catatPosisi('Rest Area KM 207');
  truk.catatPosisi('Gudang Transit Semarang');

  print('\nRiwayat posisi ${truk.kodeLayanan}:');

  for (final r in truk.riwayat) {
    print(' $r');
  }

  print('Posisi terakhir: ${truk.posisiTerakhir()}');

  print('\n=== Pengujian Mixin Terasuransi ===');

  for (final layanan in daftarLayanan) {
    if (layanan is Terasuransi) {
      final premi = (layanan as Terasuransi).hitungPremi(1000000);

      print(
        '${layanan.kodeLayanan}: '
        'Memiliki asuransi, '
        'premi Rp${premi.toStringAsFixed(0)}',
      );
    } else {
      print(
        '${layanan.kodeLayanan}: '
        'Tidak memiliki fitur asuransi',
      );
    }
  }
}
