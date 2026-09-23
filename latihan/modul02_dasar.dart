void main() {
  const double faktorVolumetrik = 6000;

  double beratAktual = 12.4; // kilogram
  double panjang = 90;
  double lebar = 60;
  double tinggi = 50; // sentimeter

  double beratVolumetrik =
      (panjang * lebar * tinggi) / faktorVolumetrik;

  double beratTertagih =
      beratAktual > beratVolumetrik
          ? beratAktual
          : beratVolumetrik;

  String kategori;

  if (beratTertagih <= 5) {
    kategori = 'Paket Kecil';
  } else if (beratTertagih <= 20) {
    kategori = 'Paket Sedang';
  } else {
    kategori = 'Kargo';
  }

  print(
      'Berat aktual : ${beratAktual.toStringAsFixed(2)} kg');
  print(
      'Berat volumetrik : ${beratVolumetrik.toStringAsFixed(2)} kg');
  print(
      'Berat tertagih : ${beratTertagih.toStringAsFixed(2)} kg');
  print('Kategori kiriman : $kategori');
}