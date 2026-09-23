// Menghitung total berat seluruh kiriman
double hitungTotalBerat(List<double> berat) {
  double total = 0;

  for (final nilai in berat) {
    total += nilai;
  }

  return total;
}

// Menghitung rata-rata berat
double hitungRataRata(List<double> berat) {
  if (berat.isEmpty) {
    return 0;
  }

  return hitungTotalBerat(berat) / berat.length;
}

// Mencari kiriman terberat
double cariTerberat(List<double> berat) {
  double terberat = berat[0];

  for (final nilai in berat) {
    if (nilai > terberat) {
      terberat = nilai;
    }
  }

  return terberat;
}

// Mencari kiriman teringan
double cariTeringan(List<double> berat) {
  double teringan = berat[0];

  for (final nilai in berat) {
    if (nilai < teringan) {
      teringan = nilai;
    }
  }

  return teringan;
}

// Menentukan kategori berdasarkan berat
String tentukanKategori(double berat) {
  if (berat <= 5) {
    return 'Paket Kecil';
  } else if (berat <= 20) {
    return 'Paket Sedang';
  } else {
    return 'Kargo';
  }
}

// Menghitung jumlah kiriman pada setiap kategori
Map<String, int> hitungKategori(List<double> berat) {
  int paketKecil = 0;
  int paketSedang = 0;
  int kargo = 0;

  for (final nilai in berat) {
    final kategori = tentukanKategori(nilai);

    if (kategori == 'Paket Kecil') {
      paketKecil++;
    } else if (kategori == 'Paket Sedang') {
      paketSedang++;
    } else {
      kargo++;
    }
  }

  return {
    'Paket Kecil': paketKecil,
    'Paket Sedang': paketSedang,
    'Kargo': kargo,
  };
}

void main() {
  final List<double> beratKiriman = [
    2.5,
    4.0,
    7.5,
    12.0,
    18.5,
    22.0,
    3.2,
    15.0,
  ];

  final totalBerat = hitungTotalBerat(beratKiriman);
  final rataRata = hitungRataRata(beratKiriman);
  final terberat = cariTerberat(beratKiriman);
  final teringan = cariTeringan(beratKiriman);
  final kategori = hitungKategori(beratKiriman);

  print('=== REKAPITULASI KIRIMAN ===');
  print('Jumlah kiriman : ${beratKiriman.length}');
  print('Total berat : ${totalBerat.toStringAsFixed(2)} kg');
  print('Rata-rata berat : ${rataRata.toStringAsFixed(2)} kg');
  print('Kiriman terberat : ${terberat.toStringAsFixed(2)} kg');
  print('Kiriman teringan : ${teringan.toStringAsFixed(2)} kg');

  print('\n=== JUMLAH BERDASARKAN KATEGORI ===');
  print('Paket Kecil : ${kategori['Paket Kecil']} kiriman');
  print('Paket Sedang : ${kategori['Paket Sedang']} kiriman');
  print('Kargo : ${kategori['Kargo']} kiriman');
}