# Jurnal Modul — Form Pengiriman, Validasi, dan State

Nama: _isi sendiri_
NIM: 714240042
Proyek: `silog_app` (SiLog — Sistem Logistik)

---

## 1. Field berat barang (kg) dan validasinya

Berat barang ditambahkan pada model `Barang` sebagai field privat `_beratKg`
dengan setter yang memvalidasi nilai, sehingga aturan 0,1 – 5000 kg berlaku
di **satu tempat** dan tidak bisa dilewati dari mana pun objek dibuat.

```dart
class Barang {
  static const double beratMinimumKg = 0.1;
  static const double beratMaksimumKg = 5000;

  double _beratKg;

  set beratKg(double nilai) {
    validasiBerat(nilai);
    _beratKg = nilai;
  }

  static void validasiBerat(double nilai) {
    if (nilai.isNaN || nilai < beratMinimumKg || nilai > beratMaksimumKg) {
      throw ArgumentError('Berat barang harus antara 0,1 dan 5000 kg');
    }
  }
}
```

Keputusan penting: konstruktor `Barang` **wajib** menerima `beratKg` dan
mengisinya lewat setter (`this.beratKg = beratKg;` di badan konstruktor),
bukan langsung ke field. Kalau diisi langsung ke `_beratKg` pada initializer
list, nilai tidak akan melewati validasi.

Di lapisan UI, `FormPengirimanPage` memakai `TextFormField` dengan validator
tersendiri yang mengembalikan pesan error dalam bahasa manusia (bukan
exception), karena kesalahan ketik pengguna bukan kondisi "program rusak":

```dart
String? _validasiBerat(String? v) {
  ...
  final angka = double.tryParse(v!.trim().replaceAll(',', '.'));
  if (angka == null) return 'Berat barang harus berupa angka';
  if (angka < Barang.beratMinimumKg || angka > Barang.beratMaksimumKg) {
    return 'Berat barang harus antara 0,1 dan 5000 kg';
  }
  return null;
}
```

Kolom ini menerima penulisan desimal gaya Indonesia (`0,8`) maupun titik
(`0.8`) karena `replaceAll(',', '.')` sebelum `double.tryParse`.
`Pengiriman` juga mendapat getter turunan `beratTotal = barang.beratKg * jumlah`
untuk ditampilkan di halaman detail.

## 2. Nomor resi tidak boleh dipakai ulang

Nomor resi adalah identitas pengiriman, jadi harus unik. Pengecekan dilakukan
di dua lapis:

1. **Di form** — `FormPengirimanPage` menerima `resiTerpakai` (kumpulan resi
   yang sudah ada, sudah dinormalisasi ke huruf besar) dari halaman daftar:

   ```dart
   if (widget.resiTerpakai.contains(resi)) {
     return 'Nomor resi $resi sudah dipakai pengiriman lain';
   }
   ```

   Pesan ini muncul langsung di bawah field sebagai error validasi, bukan
   SnackBar, supaya pengguna tahu **field mana** yang salah.

2. **Di halaman daftar** — sebelum `insert`, data hasil form diperiksa lagi.
   Ini mencegah resi ganda kalau daftar berubah saat form masih terbuka.
   Bila lolos pun tetap ganda, data ditolak dan muncul SnackBar
   "Nomor resi ... sudah ada di daftar".

Normalisasi `toUpperCase()` penting: tanpa itu, `slg-2026-0001` dan
`SLG-2026-0001` dianggap dua resi berbeda padahal sama.

## 3. Hapus data dari halaman detail + konfirmasi

Halaman detail tidak menghapus data sendiri (dia hanya memegang satu objek
`Pengiriman`, bukan daftarnya). Pola yang dipakai adalah **mengembalikan hasil
navigasi**:

```dart
// detail_pengiriman_page.dart
final setuju = await showDialog<bool>(...); // AlertDialog Batal / Hapus
if (setuju != true || !context.mounted) return;
Navigator.pop(context, true); // true = "tolong hapus saya"
```

```dart
// daftar_pengiriman_page.dart
final dihapus = await Navigator.push<bool>(...);
if (!mounted || dihapus != true) return;
setState(() => _daftar.removeWhere((p) => p.resi == item.resi));
```

Alasannya: sumber kebenaran data ada di `_DaftarPengirimanPageState`.
Kalau halaman detail mengubah list secara langsung, ia harus diberi referensi
list/state milik halaman lain — coupling yang tidak perlu dan rawan bug saat
daftar sedang difilter. Dengan pola "pop dengan hasil", halaman detail tetap
tidak tahu apa-apa soal daftar.

`context.mounted` diperiksa setelah `await` karena dialog bisa memakan waktu;
bila halaman sudah ditutup saat dialog selesai, memakai `context` akan error.

## 4. Mengapa `TextEditingController` wajib di-`dispose()`?

### Apa yang sebenarnya dipegang sebuah controller

`TextEditingController` bukan sekadar variabel pembungkus `String`. Di dalamnya
ada:

- `ValueNotifier<TextEditingValue>` yang menyimpan teks + posisi kursor/selection,
- daftar `listener` (dari `TextField`/`TextFormField`, dan siapa pun yang
  memanggil `addListener`),
- `TextInputConnection` ke text input milik platform (IME/keyboard),
- timer animasi kursor yang berdetak selama field dalam keadaan fokus.

Artinya controller adalah objek **berumur panjang yang memegang resource di
luar dirinya sendiri**. `dispose()` memutus semuanya: melepas listener,
menghentikan timer, menutup koneksi ke platform, dan membebaskan memori.

### Akibat bila `dispose()` dilewatkan

1. **Memory leak.** Setiap kali halaman form dibuka, satu controller baru
   dibuat. Kalau tidak pernah di-dispose, objek lama tetap hidup bersama
   listener dan timer-nya. Pada aplikasi yang dipakai berulang (buka form →
   simpan → buka lagi), jumlah objek "hantu" tumbuh terus dan penggunaan
   memori naik tanpa pernah turun.

2. **Error "used after being disposed" / "setState() called after dispose()".**
   Selama controller masih hidup, ia bisa memicu notifikasi. Bila notifikasi
   itu sampai ke `State` widget yang sudah dibuang, Flutter melempar error
   karena `setState` dipanggil pada widget yang tidak ada lagi di tree. Ini
   tipe bug yang **tidak selalu muncul saat dites manual**, tapi muncul saat
   pengguna menavigasi cepat atau saat widget di-rebuild.

3. **Listener yatim dan kebocoran callback.** `TextFormField` mendaftarkan
   listener ke controller. Tanpa `dispose`, listener itu tidak pernah dicabut.
   Kalau controller dipegang objek lain (mis. singleton, variabel global, atau
   `late final` di luar `State`), callback lama akan terus terpanggil dan
   menyentuh widget yang sudah tidak ada.

4. **Resource platform tidak dilepas.** Koneksi text input dan timer kursor
   tetap aktif. Efeknya boros CPU/baterai, dan pada beberapa kasus keyboard
   platform "nyangkut" atau muncul lagi di halaman yang salah.

5. **Nilai "hantu" saat hot reload / buka ulang.** Controller yang tidak
   pernah dibersihkan bisa membawa teks lama, sehingga form terbuka dengan isi
   pengiriman sebelumnya — terlihat seperti bug state padahal penyebabnya
   objek yang tidak pernah dilepas.

### Aturan praktis yang saya terapkan

```dart
class _FormPengirimanPageState extends State<FormPengirimanPage> {
  final _resiC = TextEditingController();
  final _beratC = TextEditingController();
  // ...

  @override
  void dispose() {
    _resiC.dispose();
    _beratC.dispose();
    // ...
    super.dispose(); // selalu paling akhir
  }
}
```

- Controller dibuat sebagai field `final` di `State`, bukan di dalam `build()`
  (kalau dibuat di `build`, setiap rebuild menghasilkan controller baru dan
  teks yang sedang diketik bisa hilang).
- Semua controller di-dispose di `dispose()`, lalu `super.dispose()` dipanggil
  **terakhir** supaya resource milik `State` masih valid saat dibersihkan.
- Controller yang **diberikan** dari parent (mis. `controller:` hasil
  `TextEditingController` milik widget lain) **tidak boleh** di-dispose anak,
  karena pemiliknya adalah yang membuatnya.
- `FocusNode`, `AnimationController`, `ScrollController`, `StreamSubscription`
  mengikuti aturan yang sama: siapa yang membuat, dia yang melepas.

### Ringkasan satu kalimat

`dispose()` bukan formalitas: ia adalah satu-satunya titik di mana controller
melepaskan listener, timer kursor, dan koneksi text input platform. Melewatkannya
membuat memori dan callback menumpuk setiap kali halaman dibuka, dan mengubah
bug "kadang-kadang error" menjadi hal yang pasti terjadi seiring pemakaian.

---

## Bukti pengujian

`flutter test` — 10 test lulus:

- validasi model: berat < 0,1 kg ditolak, berat > 5000 kg ditolak, batas
  0,1 dan 5000 diterima,
- form: resi duplikat ditolak dengan pesan error, berat 6000 kg ditolak,
  data valid masuk ke daftar,
- detail: tombol hapus memunculkan AlertDialog, konfirmasi menghapus data,
  Batal tidak menghapus data.

`flutter analyze` — tidak ada issue.
