import 'package:flutter/material.dart';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:flutter_api/services/datapusats_service.dart';
import 'package:flutter_api/services/barangkeluars_service.dart';

class CreateBarangKeluarPage extends StatefulWidget {
  const CreateBarangKeluarPage({Key? key}) : super(key: key);

  @override
  State<CreateBarangKeluarPage> createState() => _CreateBarangKeluarPageState();
}

class _CreateBarangKeluarPageState extends State<CreateBarangKeluarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();
  DateTime? _tglKeluar;

  List<DataPusats> _dataPusatList = [];
  int? _selectedIdBarang;
  String? _selectedKodeBarang;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDataPusat();
  }

  Future<void> _loadDataPusat() async {
    setState(() => _isLoading = true);
    try {
      final result = await DataPusatService.listDataPusat();
      setState(() {
        _dataPusatList = result.data ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat Data Pusat: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _tglKeluar = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tglKeluar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal keluar terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await BarangKeluarsService.createBarangKeluar({
        'id_barang': _selectedIdBarang!,
        'kode_barang': _selectedKodeBarang!,
        'jumlah': int.parse(_jumlahController.text),
        'tgl_keluar':
            "${_tglKeluar!.year.toString().padLeft(4, '0')}-${_tglKeluar!.month.toString().padLeft(2, '0')}-${_tglKeluar!.day.toString().padLeft(2, '0')}",
        'ket': _ketController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang keluar berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan barang keluar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Keluar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedIdBarang,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Barang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: _dataPusatList.map((item) {
                        return DropdownMenuItem<int>(
                          value: item.id,
                          child: Text('${item.kodeBarang} - ${item.nama}'),
                          onTap: () {
                            _selectedKodeBarang = item.kodeBarang;
                          },
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedIdBarang = value),
                      validator: (value) =>
                          value == null ? 'Pilih barang terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jumlahController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ketController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_alt),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Keluar',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        child: Text(
                          _tglKeluar == null
                              ? 'Pilih tanggal'
                              : "${_tglKeluar!.day}-${_tglKeluar!.month}-${_tglKeluar!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
