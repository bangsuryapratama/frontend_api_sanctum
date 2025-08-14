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
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _merkController = TextEditingController();
  final _stokController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
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
        
        // Validasi ukuran file (maksimal 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Ukuran gambar terlalu besar (maksimal 5MB)"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Validasi format file
        final fileName = picked.name.toLowerCase();
        if (!fileName.endsWith('.jpg') && 
            !fileName.endsWith('.jpeg') && 
            !fileName.endsWith('.png')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Format gambar tidak didukung. Gunakan JPG, JPEG, atau PNG"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _imageBytes = imageBytes;
          _imageName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memilih gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse stok dengan validasi
      final stokText = _stokController.text.trim();
      if (stokText.isEmpty) {
        throw Exception('Stok harus diisi');
      }
      
      final stok = int.tryParse(stokText);
      if (stok == null || stok < 0) {
        throw Exception('Stok harus berupa angka positif');
      }

      final success = await DataPusatService.createDataPusat(
        kodeBarang: _kodeController.text.trim(),
        nama: _namaController.text.trim(),
        merk: _merkController.text.trim(),
        stok: stok,
        imageBytes: _imageBytes,
        imageName: _imageName,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data berhasil dibuat"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true untuk refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal membuat data"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Tambah Data Pusat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kode Barang Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _kodeController,
                  decoration: const InputDecoration(
                    labelText: "Kode Barang",
                    hintText: "Masukkan kode barang",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Kode barang harus diisi";
                    }
                    if (value.trim().length < 3) {
                      return "Kode barang minimal 3 karakter";
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nama Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Barang",
                    hintText: "Masukkan nama barang",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama barang harus diisi";
                    }
                    if (value.trim().length < 3) {
                      return "Nama barang minimal 3 karakter";
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Merk Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _merkController,
                  decoration: const InputDecoration(
                    labelText: "Merk",
                    hintText: "Masukkan merk barang",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.branding_watermark),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Merk harus diisi";
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stok Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: "Stok",
                    hintText: "Masukkan jumlah stok",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    suffixText: "pcs",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Stok harus diisi";
                    }
                    final stok = int.tryParse(value.trim());
                    if (stok == null || stok < 0) {
                      return "Stok harus berupa angka positif";
                    }
                    return null;
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Image Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Foto Barang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_imageBytes != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 16,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "File: $_imageName",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ] else ...[
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(8),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap untuk pilih foto",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Format: JPG, JPEG, PNG (Maks. 5MB)",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            "Simpan Data",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}