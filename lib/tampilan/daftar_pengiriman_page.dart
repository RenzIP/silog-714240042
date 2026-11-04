import 'package:flutter/material.dart';
import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatelessWidget {
  const DaftarPengirimanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menghitung statistik ringkasan
    final totalPengiriman = dataPengiriman.length;
    final totalNilai = dataPengiriman.fold<double>(
      0,
      (sum, item) => sum + item.nilaiBarang,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Cari resi',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Perjalanan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: Column(
          children: [
            // G.2: Widget Ringkasan di bagian atas layar daftar
            Card(
              margin: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Total Kiriman',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('$totalPengiriman Paket'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Total Nilai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Rp${totalNilai.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // G.1: TabBarView dengan filter daftar pengiriman
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(dataPengiriman),
                  _buildList(
                    dataPengiriman
                        .where((e) => e.status == 'Dalam Perjalanan')
                        .toList(),
                  ),
                  _buildList(
                    dataPengiriman
                        .where((e) => e.status == 'Diterima')
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }

  Widget _buildList(List<Pengiriman> daftar) {
    if (daftar.isEmpty) {
      return const Center(child: Text('Tidak ada data pengiriman'));
    }

    return ListView.builder(
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final item = daftar[index];
        return KartuPengiriman(
          pengiriman: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPengirimanPage(pengiriman: item),
              ),
            );
          },
        );
      },
    );
  }
}