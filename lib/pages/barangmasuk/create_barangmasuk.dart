import 'package:flutter/material.dart';
import 'package:flutter_api/models/datapusats_model.dart';
import 'package:flutter_api/services/datapusats_service.dart';
import 'package:flutter_api/services/barangmasuks_service.dart';

class CreateBarangMasukPage extends StatefulWidget {
  const CreateBarangMasukPage({Key? key}) : super(key: key);

  @override
  State<CreateBarangMasukPage> createState() => _CreateBarangMasukPageState();
}

class _CreateBarangMasukPageState extends State<CreateBarangMasukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();
  DateTime? _tglMasuk;
  List<DataPusats> _dataPusatList = [];
  int? _selectedIdBarang;
  String? _selectedKodeBarang;

  @override
  void initState() {
    super.initState();
    _loadDataPusat();
  }

  Future<void> _loadDataPusat() async {
    try {
      final result = await DataPusatService.listDataPusat();
      setState(() {
        _dataPusatList = result.data ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat Data Pusat: $e')),
      );
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
        _tglMasuk = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await BarangMasuksService.createBarangMasuk({
          'id_barang': _selectedIdBarang!,
          'kode_barang': _selectedKodeBarang!,
          'jumlah': int.parse(_jumlahController.text),
          'tgl_masuk':
              "${_tglMasuk!.year.toString().padLeft(4, '0')}-${_tglMasuk!.month.toString().padLeft(2, '0')}-${_tglMasuk!.day.toString().padLeft(2, '0')}",
          'ket': _ketController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang masuk berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan barang masuk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Masuk')),
      body: Padding(
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
                onChanged: (value) => setState(() => _selectedIdBarang = value),
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
                validator: (value) =>
                    value!.isEmpty ? 'Jumlah tidak boleh kosong' : null,
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
                    labelText: 'Tanggal Masuk',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    _tglMasuk == null
                        ? 'Pilih tanggal'
                        : "${_tglMasuk!.day}-${_tglMasuk!.month}-${_tglMasuk!.year}",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
