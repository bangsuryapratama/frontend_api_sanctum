import 'package:flutter/material.dart';
import 'package:flutter_api/models/barangmasuks_model.dart';
import 'package:flutter_api/services/barangmasuks_service.dart';

class DetailBarangMasukPage extends StatefulWidget {
  final int id;

  const DetailBarangMasukPage({Key? key, required this.id}) : super(key: key);

  @override
  State<DetailBarangMasukPage> createState() => _DetailBarangMasukPageState();
}

class _DetailBarangMasukPageState extends State<DetailBarangMasukPage> {
  DataMasuk? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await BarangMasuksService.listBarangMasuks();
      final item = response.data?.firstWhere((item) => item.id == widget.id);
      setState(() {
        _data = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Data?'),
        content: Text('Data akan dihapus permanen dan tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await BarangMasuksService.deleteBarangMasuk(widget.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus data'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildReceiptRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontFamily: 'Courier', fontSize: 14)),
          Text(value, style: TextStyle(fontFamily: 'Courier', fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Struk Barang Masuk'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _data != null ? _deleteItem : null,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Container(
                      width: 350,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LAPORAN BARANG MASUK',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PT INVENTORY MAKMUR',
                            style: TextStyle(fontFamily: 'Courier', fontSize: 14),
                          ),
                          Divider(thickness: 1, color: Colors.black),
                          _buildReceiptRow('Kode Barang', _data!.kodeBarang ?? '-'),
                          _buildReceiptRow('ID Barang', _data!.idBarang?.toString() ?? '-'),
                          _buildReceiptRow('Jumlah', _data!.jumlah?.toString() ?? '0'),
                          _buildReceiptRow(
                            'Tanggal Masuk',
                            _data!.tglMasuk != null
                                ? '${_data!.tglMasuk!.day}/${_data!.tglMasuk!.month}/${_data!.tglMasuk!.year}'
                                : '-',
                          ),
                          _buildReceiptRow('Keterangan', _data!.ket ?? '-'),
                          Divider(thickness: 1, color: Colors.black),
                          _buildReceiptRow(
                            'Dibuat',
                            _data!.createdAt != null
                                ? '${_data!.createdAt!.day}/${_data!.createdAt!.month}/${_data!.createdAt!.year}'
                                : '-',
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Terima kasih telah menggunakan layanan kami',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Courier', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
