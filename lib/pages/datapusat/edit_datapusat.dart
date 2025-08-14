import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:flutter_api/services/datapusats_service.dart';

class EditDataPusatPage extends StatefulWidget {
  final DataPusats data;

  const EditDataPusatPage({Key? key, required this.data}) : super(key: key);

  @override
  State<EditDataPusatPage> createState() => _EditDataPusatPageState();
}

class _EditDataPusatPageState extends State<EditDataPusatPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  final _merkController = TextEditingController();
  final _stokController = TextEditingController();
  
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _namaController.text = widget.data.nama ?? '';
    _kodeController.text = widget.data.kodeBarang ?? '';
    _merkController.text = widget.data.merk ?? '';
    _stokController.text = widget.data.stok?.toString() ?? '0';
    
    if (widget.data.foto != null && widget.data.foto!.isNotEmpty) {
      _currentImageUrl = 'http://127.0.0.1:8000/storage/${widget.data.foto!}';
    }

    // Add listeners
    _namaController.addListener(() => _hasChanges = true);
    _kodeController.addListener(() => _hasChanges = true);
    _merkController.addListener(() => _hasChanges = true);
    _stokController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    _merkController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: $e', Colors.red);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Gambar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, color: Colors.blue, size: 32),
                          SizedBox(height: 8),
                          Text('Galeri', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.green, size: 32),
                          SizedBox(height: 8),
                          Text('Kamera', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedImage != null || _currentImageUrl != null) ...[
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _currentImageUrl = null;
                    _hasChanges = true;
                  });
                },
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Uint8List? imageBytes;
      String? imageName;

      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
        imageName = _selectedImage!.path;
      }

      final success = await DataPusatService.updateDataPusat(
        id: widget.data.id!,
        nama: _namaController.text.trim(),
        kodeBarang: _kodeController.text.trim(),
        merk: _merkController.text.trim(),
        stok: int.parse(_stokController.text),
        imageBytes: imageBytes,
        imageName: imageName,
      );

      if (mounted) {
        if (success) {
          _showSnackBar('Data berhasil diperbarui', Colors.green);
          Navigator.pop(context, true);
        } else {
          _showSnackBar('Gagal memperbarui data', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Perubahan Belum Disimpan'),
        content: Text('Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('Edit Produk'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (_hasChanges)
              IconButton(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.save),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (_hasChanges)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Ada perubahan yang belum disimpan', style: TextStyle(color: Colors.orange[700])),
                      ],
                    ),
                  ),

                // Image Section
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Foto Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showImagePicker,
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                  )
                                : _currentImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _currentImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                              Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('Tap untuk pilih foto', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Form Fields
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informasi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _namaController,
                          label: 'Nama Produk *',
                          hint: 'Masukkan nama produk',
                          icon: Icons.inventory_2,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Nama produk harus diisi';
                            if (value.trim().length < 3) return 'Nama minimal 3 karakter';
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _kodeController,
                          label: 'Kode Barang *',
                          hint: 'Contoh: BRG001',
                          icon: Icons.qr_code,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Kode barang harus diisi';
                            if (value.trim().length < 3) return 'Kode minimal 3 karakter';
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _merkController,
                          label: 'Merk',
                          hint: 'Masukkan merk produk',
                          icon: Icons.business,
                          textCapitalization: TextCapitalization.words,
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _stokController,
                          label: 'Jumlah Stok *',
                          hint: '0',
                          icon: Icons.inventory,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Stok harus diisi';
                            final stok = int.tryParse(value);
                            if (stok == null || stok < 0) return 'Stok harus berupa angka positif';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('Menyimpan...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}