import '../model/barang.dart';
import '../model/gudang.dart';
import '../model/pelanggan.dart';
import '../model/pengiriman.dart';

final gudangBandung = Gudang(
  kode: 'GD-BDG',
  nama: 'Gudang Utama Bandung',
  kota: 'Bandung',
);

final pelangganSurabaya = Pelanggan(
  kode: 'PL-0001',
  nama: 'Andi Pratama',
  nomorTelepon: '0812-3456-7890',
  alamat: 'Jl. Raya Darmo No. 45, Surabaya',
);

final pelangganMakassar = Pelanggan(
  kode: 'PL-0002',
  nama: 'Siti Rahmawati',
  nomorTelepon: '0852-1122-3344',
  alamat: 'Jl. Pettarani No. 12, Makassar',
);

final pelangganMedan = Pelanggan(
  kode: 'PL-0003',
  nama: 'Budi Santoso',
  nomorTelepon: '0813-9988-7766',
  alamat: 'Jl. Gatot Subroto No. 88, Medan',
);

final List<Pengiriman> dataPengiriman = [
  Pengiriman(
    resi: 'SLG-2026-0001',
    asal: gudangBandung,
    kotaTujuan: 'Surabaya',
    barang: Barang(kode: 'B-1024', nama: 'Sepatu Lari Pria', hargaSatuan: 450000, beratKg: 0.8, satuan: 'Pasang'),
    jumlah: 10,
    tanggalKirim: DateTime(2026, 9, 8),
    pelanggan: pelangganSurabaya,
    status: 'Dalam Perjalanan',
  ),
  Pengiriman(
    resi: 'SLG-2026-0002',
    asal: gudangBandung,
    kotaTujuan: 'Makassar',
    barang: Barang(kode: 'B-2048', nama: 'Kaos Katun', hargaSatuan: 85000, beratKg: 0.25, satuan: 'Pcs'),
    jumlah: 120,
    tanggalKirim: DateTime(2026, 9, 9),
    pelanggan: pelangganMakassar,
    status: 'Menunggu Pickup',
  ),
  Pengiriman(
    resi: 'SLG-2026-0003',
    asal: gudangBandung,
    kotaTujuan: 'Medan',
    barang: Barang(kode: 'B-3072', nama: 'Tas Ransel', hargaSatuan: 275000, beratKg: 1.2, satuan: 'Pcs'),
    jumlah: 35,
    tanggalKirim: DateTime(2026, 9, 10),
    pelanggan: pelangganMedan,
    status: 'Diterima',
  ),
];
