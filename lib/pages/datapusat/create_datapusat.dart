import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_api/services/datapusats_service.dart';

class CreateDataPusatPage extends StatefulWidget {
  @override
  State<CreateDataPusatPage> createState() => _CreateDataPusatPageState();
}

class _CreateDataPusatPageState extends State<CreateDataPusatPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  final _merkController = TextEditingController();
  final _stokController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    _merkController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (picked != null) {
        final imageBytes = await picked.readAsBytes();
        
        if (imageBytes.length > 5 * 1024 * 1024) {
          _showSnackBar('Ukuran gambar terlalu besar (maks 5MB)', Colors.red);
          return;
        }

        setState(() {
          _imageBytes = imageBytes;
          _imageName = picked.name;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: $e', Colors.red);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (picked != null) {
        final imageBytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
          _imageName = picked.name;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil foto: $e', Colors.red);
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
                      _pickImage();
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
                      _takePhoto();
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
            if (_imageBytes != null) ...[
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageBytes = null;
                    _imageName = null;
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
      final success = await DataPusatService.createDataPusat(
        kodeBarang: _kodeController.text.trim(),
        nama: _namaController.text.trim(),
        merk: _merkController.text.trim(),
        stok: int.parse(_stokController.text),
        imageBytes: _imageBytes,
        imageName: _imageName,
      );

      if (mounted) {
        if (success) {
          _showSnackBar('Data berhasil dibuat', Colors.green);
          Navigator.pop(context, true);
        } else {
          _showSnackBar('Gagal membuat data', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Tambah Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                          ),
                          child: _imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
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
                      if (_imageBytes != null) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text('File: $_imageName', style: TextStyle(fontSize: 12, color: Colors.grey))),
                            IconButton(
                              onPressed: () => setState(() {
                                _imageBytes = null;
                                _imageName = null;
                              }),
                              icon: Icon(Icons.delete, color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      ],
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
              
              // Submit Button
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
                            Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}