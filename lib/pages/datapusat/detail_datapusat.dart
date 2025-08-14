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
    futureDetail = _fetchDataWithFallback();
  }

  Future<DataPusats> _fetchDataWithFallback() async {
    try {
      print('🔍 Attempting to fetch data for ID: ${widget.id}');
      final result = await DataPusatService.showDataPusat(widget.id);
      print('✅ Data fetched successfully');
      return result;
    } catch (e) {
      print('❌ Error fetching data: $e');
      // Tidak ada fallback dummy data - langsung throw error
      rethrow;
    }
  }

  // Hapus dummy data method

  void _retryFetch() {
    setState(() {
      isRetrying = true;
      futureDetail = _fetchDataWithFallback();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isRetrying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Detail Data Pusat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
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
            return _buildNoDataState();
          }

          return _buildSuccessState(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            "Memuat detail data...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Gagal memuat detail",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                           color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        "Debugging Info:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getErrorMessage(error),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Solusi yang bisa dicoba:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSolutionMessage(error),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isRetrying ? null : _retryFetch,
                  icon: isRetrying 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(isRetrying ? "Mengulang..." : "Coba Lagi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Kembali"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Data tidak ditemukan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ID: ${widget.id}",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Kembali"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(DataPusats data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Image Section
          _buildImageSection(data),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoCard(data),
                const SizedBox(height: 20),
                _buildStatusCard(data),
                const SizedBox(height: 20),
                _buildMetadataCard(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(DataPusats data) {
    final imageUrl = data.foto != null && data.foto!.isNotEmpty
        ? 'http://127.0.0.1:8000/storage/${data.foto!}'
        : null;

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueAccent,
            Colors.blueAccent.shade700,
          ],
        ),
      ),
      child: imageUrl != null
          ? Hero(
              tag: 'dataPusatImage_${data.id}',
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildNoImagePlaceholder(),
              ),
            )
          : _buildNoImagePlaceholder(),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            "Tidak ada gambar",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(DataPusats data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Informasi Produk",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              data.nama ?? "Nama tidak tersedia",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              Icons.qr_code,
              "Kode Barang",
              data.kodeBarang ?? '-',
            ),
            _buildDetailRow(
              Icons.business,
              "Merk",
              data.merk ?? '-',
            ),
            _buildDetailRow(
              Icons.inventory,
              "Stok",
              "${data.stok ?? 0} unit",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(DataPusats data) {
    final isAvailable = data.stok != null && data.stok! > 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAvailable 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status Ketersediaan",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable ? "Tersedia" : "Stok Habis",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(DataPusats data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Informasi Tambahan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetadataRow(
              "ID Produk",
              "${data.id ?? '-'}",
            ),
            if (data.createdAt != null)
              _buildMetadataRow(
                "Dibuat pada",
                _formatDateTime(data.createdAt!),
              ),
            if (data.updatedAt != null)
              _buildMetadataRow(
                "Terakhir diupdate",
                _formatDateTime(data.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
           "${dateTime.hour.toString().padLeft(2, '0')}:"
           "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _getErrorMessage(String error) {
    if (error.contains('response kosong')) {
      return "Server mengembalikan response kosong.";
    } else if (error.contains('bukan JSON')) {
      return "Server tidak mengembalikan format JSON yang valid.";
    } else if (error.contains('SocketException') || error.contains('terhubung')) {
      return "Tidak dapat terhubung ke server.";
    } else if (error.contains('TimeoutException') || error.contains('timeout')) {
      return "Koneksi timeout - server terlalu lama merespon.";
    } else if (error.contains('404') || error.contains('tidak ditemukan')) {
      return "Data dengan ID ${widget.id} tidak ditemukan.";
    } else if (error.contains('500') || error.contains('internal server')) {
      return "Terjadi kesalahan di server (Internal Server Error).";
    } else if (error.contains('401') || error.contains('Token')) {
      return "Token authentication bermasalah.";
    } else {
      return error.length > 150 ? "${error.substring(0, 150)}..." : error;
    }
  }

  String _getSolutionMessage(String error) {
    if (error.contains('response kosong')) {
      return "• Periksa controller Laravel apakah return response\n• Pastikan route API sudah benar\n• Cek apakah ada data dengan ID ${widget.id}";
    } else if (error.contains('bukan JSON')) {
      return "• Periksa controller Laravel return JSON\n• Pastikan tidak ada HTML error page\n• Cek header Content-Type: application/json";
    } else if (error.contains('SocketException') || error.contains('terhubung')) {
      return "• Pastikan server Laravel running di localhost:8000\n• Cek koneksi internet\n• Pastikan tidak ada firewall blocking";
    } else if (error.contains('404')) {
      return "• Periksa apakah ID ${widget.id} ada di database\n• Cek route API di Laravel (Route::get('/datapusats/{id}'))\n• Pastikan controller method exists";
    } else if (error.contains('500')) {
      return "• Cek log Laravel di storage/logs/laravel.log\n• Periksa database connection\n• Debug controller method";
    } else if (error.contains('Token')) {
      return "• Login ulang untuk refresh token\n• Periksa token di SharedPreferences\n• Cek middleware auth di Laravel";
    } else {
      return "• Cek console log untuk detail\n• Periksa network tab di browser\n• Test API di Postman";
    }
  }
}