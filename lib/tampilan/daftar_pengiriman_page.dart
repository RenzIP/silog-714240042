
import 'package:flutter/material.dart';
import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() =>
      _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  late List<Pengiriman> _daftar;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _daftar = List<Pengiriman>.from(dataPengiriman);
  }

  List<Pengiriman> get _hasilSaring => _filterStatus == 'Semua'
      ? _daftar
      : _daftar.where((p) => p.status == _filterStatus).toList();

  Future<void> _bukaFormulir() async {
    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengirimanPage(
          resiTerpakai: _daftar.map((p) => p.resi.toUpperCase()).toSet(),
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    // Pengaman terakhir agar resi ganda tidak pernah masuk ke daftar.
    final sudahAda = _daftar.any(
      (p) => p.resi.toUpperCase() == hasil.resi.toUpperCase(),
    );

    if (sudahAda) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomor resi ${hasil.resi} sudah ada di daftar'),
        ),
      );
      return;
    }

    setState(() => _daftar.insert(0, hasil));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pengiriman ${hasil.resi} berhasil ditambahkan',
        ),
      ),
    );
  }

  /// Membuka detail, lalu menghapus data bila pengguna mengonfirmasi
  /// lewat AlertDialog di halaman detail.
  Future<void> _bukaDetail(Pengiriman item) async {
    final dihapus = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPengirimanPage(pengiriman: item),
      ),
    );

    if (!mounted || dihapus != true) return;

    setState(() => _daftar.removeWhere((p) => p.resi == item.resi));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengiriman ${item.resi} dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const opsi = [
      'Semua',
      'Menunggu Pickup',
      'Dalam Perjalanan',
      'Diterima',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengiriman'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              children: opsi.map((o) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: _filterStatus == o,
                    onSelected: (_) {
                      setState(() => _filterStatus = o);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Text(
            'Menampilkan ${_hasilSaring.length} dari ${_daftar.length} data',
          ),
          Expanded(
            child: _hasilSaring.isEmpty
                ? const Center(
                    child: Text('Tidak ada data pengiriman'),
                  )
                : ListView.builder(
                    itemCount: _hasilSaring.length,
                    itemBuilder: (context, i) {
                      final item = _hasilSaring[i];

                      return KartuPengiriman(
                        pengiriman: item,
                        onTap: () => _bukaDetail(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
    );
  }
}
