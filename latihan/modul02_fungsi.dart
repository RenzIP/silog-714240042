double beratVolumetrik(
  double p,
  double l,
  double t, {
  double faktor = 6000,
}) =>
    (p * l * t) / faktor;

double beratTertagih({
  required double aktual,
  required double volumetrik,
}) =>
    aktual > volumetrik ? aktual : volumetrik;

double hitungOngkir({
  required double berat,
  required double tarifPerKg,
  bool asuransi = false,
  double persenAsuransi = 0.005,
  double nilaiBarang = 0,
}) {
  double biaya = berat * tarifPerKg;

  if (asuransi) {
    biaya += nilaiBarang * persenAsuransi;
  }

  return biaya;
}

String rupiah(double nilai) =>
    'Rp${nilai.toStringAsFixed(0)}';

// Fungsi baru
int estimasiHariSampai(String kota) {
  switch (kota) {
    case 'Bandung':
      return 1;
    case 'Surabaya':
      return 2;
    case 'Makassar':
      return 4;
    case 'Jayapura':
      return 7;
    default:
      return 5;
  }
}

void main() {
  final volumetrik = beratVolumetrik(45, 30, 25);

  final tertagih = beratTertagih(
    aktual: 12.4,
    volumetrik: volumetrik,
  );

  final ongkir = hitungOngkir(
    berat: tertagih,
    tarifPerKg: 8500,
    asuransi: true,
    nilaiBarang: 2500000,
  );

  final estimasi = estimasiHariSampai('Surabaya');

  print(
    'Berat tertagih : '
    '${tertagih.toStringAsFixed(2)} kg',
  );

  print('Ongkos kirim : ${rupiah(ongkir)}');
  print('Estimasi sampai : $estimasi hari');
}