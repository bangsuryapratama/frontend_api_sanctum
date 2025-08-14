import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_api/models/barangkeluars_model.dart';
import 'package:flutter_api/services/barangkeluars_service.dart';
import 'package:flutter_api/pages/barangkeluar/create_barangkeluar.dart';
import 'package:flutter_api/pages/barangkeluar/detail_barangkeluar.dart';
import 'package:flutter_api/pages/barangkeluar/edit_barangkeluar.dart';

class ListBarangKeluarsPage extends StatefulWidget {
  @override
  State<ListBarangKeluarsPage> createState() => _ListBarangKeluarsPageState();
}

class _ListBarangKeluarsPageState extends State<ListBarangKeluarsPage> {
  List<DataKeluar> allData = [];
  List<DataKeluar> filteredData = [];
  bool isLoading = false;
  final searchController = TextEditingController();
  final _debounceTimer = ValueNotifier<Timer?>(null);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer.value?.cancel();
    _debounceTimer.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final barangKeluars = await BarangKeluarsService.getBarangKeluars();
      if (!mounted) return;
      setState(() {
        allData = barangKeluars.data ?? [];
        filteredData = allData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _search(String query) {
    // Cancel previous timer
    _debounceTimer.value?.cancel();
    
    // Set new timer for debounced search
    _debounceTimer.value = Timer(Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        filteredData = query.isEmpty
            ? allData
            : allData.where((item) {
                final searchTerm = query.toLowerCase();
                return (item.kodeBarang ?? '').toLowerCase().contains(searchTerm) ||
                    (item.ket ?? '').toLowerCase().contains(searchTerm);
              }).toList();
      });
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteItem(DataKeluar item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus ${item.kodeBarang ?? 'Item'}?'),
        content: Text('Data akan dihapus permanen dan tidak dapat dikembalikan'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && item.id != null) {
      try {
        final success = await BarangKeluarsService.deleteBarangKeluar(item.id!);
        if (success) {
          _showSnackBar('Data berhasil dihapus', Colors.green);
          _loadData();
        } else {
          _showSnackBar('Gagal menghapus data', Colors.red);
        }
      } catch (e) {
        _showSnackBar('Gagal menghapus: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateBarangKeluarPage()),
    );
    if (result == true) {
      _loadData();
      _showSnackBar('Data berhasil ditambahkan', Colors.green);
    }
  }

  Future<void> _navigateToDetail(DataKeluar item) async {
    if (item.id == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailBarangKeluarPage(id: item.id!)),
    );
    if (result == true) _loadData();
  }

  Future<void> _navigateToEdit(DataKeluar item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBarangKeluarPage(barangKeluar: item)),
    );
    if (result == true) {
      _loadData();
      _showSnackBar('Data berhasil diupdate', Colors.green);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildQuantityBadge(int quantity) {
    Color color = quantity == 0 ? Colors.red : quantity <= 5 ? Colors.orange : Colors.blue;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildItemCard(DataKeluar item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _navigateToDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.outbox,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.kodeBarang ?? 'Tanpa Kode',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.remove_circle_outline, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          _buildQuantityBadge(item.jumlah ?? 0),
                          Text(' unit', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(item.tglKeluar),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      if (item.ket != null && item.ket!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          item.ket!,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _navigateToEdit(item);
                    } else if (value == 'delete') {
                      await _deleteItem(item);
                    }
                  },
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(fontSize: 13, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = searchController.text.isEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEmpty ? Icons.outbox_outlined : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            isEmpty ? 'Belum ada barang keluar' : 'Tidak ditemukan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (isEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Mulai catat barang yang keluar',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: Icon(Icons.add, size: 18),
              label: Text('Tambah Barang Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Memuat data...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    if (filteredData.isEmpty) return _buildEmptyState();
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.orange,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 100),
        itemCount: filteredData.length,
        itemBuilder: (context, index) => _buildItemCard(filteredData[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('Barang Keluar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: Icon(Icons.refresh, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Cari kode atau keterangan...',
                prefixIcon: Icon(Icons.search, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          _search('');
                        },
                        icon: Icon(Icons.clear, size: 18),
                        tooltip: 'Hapus pencarian',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          
          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.orange,
        tooltip: 'Tambah Barang Keluar',
      ),
    );
  }
}