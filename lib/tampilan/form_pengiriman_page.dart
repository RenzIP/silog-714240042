import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/data_contoh.dart';
import '../model/barang.dart';
import '../model/pengiriman.dart';

class FormPengirimanPage extends StatefulWidget {
  /// Kumpulan nomor resi yang sudah dipakai (huruf besar).
  final Set<String> resiTerpakai;

  const FormPengirimanPage({
    super.key,
    this.resiTerpakai = const {},
  });

  @override
  State<FormPengirimanPage> createState() =>
      _FormPengirimanPageState();
}

class _FormPengirimanPageState extends State<FormPengirimanPage> {
  final _formKey = GlobalKey<FormState>();

  final _resiC = TextEditingController();
  final _namaBarangC = TextEditingController();
  final _hargaC = TextEditingController();
  final _beratC = TextEditingController();
  final _jumlahC = TextEditingController();

  String _kotaTujuan = 'Surabaya';
  DateTime _tanggalKirim = DateTime.now();

  @override
  void dispose() {
    _resiC.dispose();
    _namaBarangC.dispose();
    _hargaC.dispose();
    _beratC.dispose();
    _jumlahC.dispose();

    super.dispose();
  }

  String? _wajib(String? v, String label) {
    if (v == null || v.trim().isEmpty) {
      return '$label wajib diisi';
    }

    return null;
  }

  String? _validasiResi(String? v) {
    final dasar = _wajib(v, 'Nomor resi');

    if (dasar != null) return dasar;

    final resi = v!.trim().toUpperCase();
    final pola = RegExp(r'^SLG-\d{4}-\d{4}$');

    if (!pola.hasMatch(resi)) {
      return 'Format resi harus SLG-TAHUN-NOMOR, '
          'contoh SLG-2026-0010';
    }

    // Nomor resi berfungsi sebagai identitas pengiriman, jadi tidak boleh
    // dipakai dua kali.
    if (widget.resiTerpakai.contains(resi)) {
      return 'Nomor resi $resi sudah dipakai pengiriman lain';
    }

    return null;
  }

  String? _validasiBerat(String? v) {
    final dasar = _wajib(v, 'Berat barang');

    if (dasar != null) return dasar;

    // Terima penulisan desimal dengan koma (0,8) maupun titik (0.8).
    final angka = double.tryParse(v!.trim().replaceAll(',', '.'));

    if (angka == null) {
      return 'Berat barang harus berupa angka';
    }

    if (angka < Barang.beratMinimumKg ||
        angka > Barang.beratMaksimumKg) {
      return 'Berat barang harus antara '
          '${Barang.beratMinimumKg.toStringAsFixed(1)} dan '
          '${Barang.beratMaksimumKg.toStringAsFixed(0)} kg';
    }

    return null;
  }

  String? _validasiAngka(
    String? v,
    String label, {
    double min = 1,
  }) {
    final dasar = _wajib(v, label);

    if (dasar != null) return dasar;

    final angka = double.tryParse(v!.trim());

    if (angka == null) {
      return '$label harus berupa angka';
    }

    if (angka < min) {
      return '$label minimal $min';
    }

    return null;
  }

  String? _validasiTanggal() {
    final batas = DateTime.now().subtract(
      const Duration(days: 1),
    );

    if (_tanggalKirim.isBefore(batas)) {
      return 'Tanggal kirim tidak boleh sebelum hari ini';
    }

    return null;
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalKirim,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (hasil != null) {
      setState(() => _tanggalKirim = hasil);
    }
  }

  void _simpan() {
    final pesanTanggal = _validasiTanggal();

    if (!_formKey.currentState!.validate() ||
        pesanTanggal != null) {
      if (pesanTanggal != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesanTanggal),
          ),
        );
      }

      return;
    }

    final pengiriman = Pengiriman(
      resi: _resiC.text.trim().toUpperCase(),
      asal: gudangBandung,
      kotaTujuan: _kotaTujuan,
      barang: Barang(
        kode: 'B-${DateTime.now().millisecondsSinceEpoch % 10000}',
        nama: _namaBarangC.text.trim(),
        hargaSatuan: double.parse(_hargaC.text.trim()),
        beratKg: double.parse(_beratC.text.trim().replaceAll(',', '.')),
      ),
      jumlah: int.parse(_jumlahC.text.trim()),
      tanggalKirim: _tanggalKirim,
      status: 'Menunggu Pickup',
      pelanggan: pelangganSurabaya,
    );

    Navigator.pop(context, pengiriman);
  }

  @override
  Widget build(BuildContext context) {
    const kota = [
      'Surabaya',
      'Makassar',
      'Medan',
      'Denpasar',
      'Jayapura',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengiriman Baru'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _resiC,
              decoration: const InputDecoration(
                labelText: 'Nomor Resi',
                hintText: 'SLG-2026-0010',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: _validasiResi,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _namaBarangC,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _wajib(v, 'Nama barang'),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _hargaC,
              decoration: const InputDecoration(
                labelText: 'Harga Satuan (Rp)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) => _validasiAngka(
                v,
                'Harga satuan',
                min: 1000,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _beratC,
              decoration: const InputDecoration(
                labelText: 'Berat Barang (kg)',
                hintText: '0,1 - 5000',
                helperText: 'Berat per satuan barang',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: _validasiBerat,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _jumlahC,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) => _validasiAngka(
                v,
                'Jumlah',
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _kotaTujuan,
              decoration: const InputDecoration(
                labelText: 'Kota Tujuan',
                border: OutlineInputBorder(),
              ),
              items: kota.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(k),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _kotaTujuan = v);
                }
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Tanggal Kirim: '
                '${_tanggalKirim.day}/'
                '${_tanggalKirim.month}/'
                '${_tanggalKirim.year}',
              ),
            ),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _simpan,
              child: const Text('Simpan Pengiriman'),
            ),
          ],
        ),
      ),
    );
  }
}