import 'package:flutter/material.dart';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:flutter_api/services/datapusats_service.dart';

class DetailDataPusatPage extends StatefulWidget {
  final int id;

  const DetailDataPusatPage({Key? key, required this.id}) : super(key: key);

  @override
  State<DetailDataPusatPage> createState() => _DetailDataPusatPageState();
}

class _DetailDataPusatPageState extends State<DetailDataPusatPage> {
  late Future<DataPusats> futureDetail;
  bool isRetrying = false;

  @override
  void initState() {
    super.initState();
    futureDetail = _fetchData();
  }

  Future<DataPusats> _fetchData() async {
    try {
      return await DataPusatService.showDataPusat(widget.id);
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  void _retryFetch() {
    setState(() {
      isRetrying = true;
      futureDetail = _fetchData();
    });
    
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) setState(() => isRetrying = false);
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text('Memuat detail...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Gagal memuat detail',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _getSimpleErrorMessage(error),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isRetrying ? null : _retryFetch,
                  icon: isRetrying 
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.refresh),
                  label: Text(isRetrying ? 'Mengulang...' : 'Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Kembali'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(DataPusats data) {
    final imageUrl = data.foto != null && data.foto!.isNotEmpty
        ? 'http://127.0.0.1:8000/storage/${data.foto!}'
        : null;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Section
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[200],
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => _buildNoImagePlaceholder(),
                  )
                : _buildNoImagePlaceholder(),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  data.nama ?? 'Tanpa Nama',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                
                SizedBox(height: 16),
                
                // Info Cards
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.qr_code, 'Kode Barang', data.kodeBarang ?? '-'),
                        Divider(),
                        _buildInfoRow(Icons.business, 'Merk', data.merk ?? '-'),
                        Divider(),
                        _buildInfoRow(Icons.inventory, 'Stok', '${data.stok ?? 0} unit'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Stock Status Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStockIcon(data.stok ?? 0),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status Stok', style: TextStyle(color: Colors.grey[600])),
                              Text(
                                _getStockStatus(data.stok ?? 0),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStockColor(data.stok ?? 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Metadata Card
                if (data.createdAt != null || data.updatedAt != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          if (data.createdAt != null)
                            _buildMetaRow('Dibuat', _formatDate(data.createdAt!)),
                          if (data.updatedAt != null)
                            _buildMetaRow('Diperbarui', _formatDate(data.updatedAt!)),
                          _buildMetaRow('ID', '${data.id ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 60, color: Colors.grey[400]),
        SizedBox(height: 8),
        Text('Tidak ada gambar', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIcon(int stock) {
    Color color = _getStockColor(stock);
    IconData icon = stock == 0 ? Icons.cancel : stock <= 5 ? Icons.warning : Icons.check_circle;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatus(int stock) {
    if (stock == 0) return 'Stok Habis';
    if (stock <= 5) return 'Stok Menipis';
    return 'Stok Tersedia';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getSimpleErrorMessage(String error) {
    if (error.contains('404') || error.contains('tidak ditemukan')) {
      return 'Data dengan ID ${widget.id} tidak ditemukan';
    } else if (error.contains('SocketException') || error.contains('terhubung')) {
      return 'Tidak dapat terhubung ke server';
    } else if (error.contains('TimeoutException')) {
      return 'Koneksi timeout';
    } else {
      return 'Terjadi kesalahan saat memuat data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Detail Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DataPusats>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Data tidak ditemukan', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          return _buildSuccessState(snapshot.data!);
        },
      ),
    );
  }
}