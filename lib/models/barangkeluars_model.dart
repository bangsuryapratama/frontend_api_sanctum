// To parse this JSON data, do
//
//     final BarangKeluars = BarangKeluarsFromJson(jsonString);

import 'dart:convert';

BarangKeluars BarangKeluarsFromJson(String str) => BarangKeluars.fromJson(json.decode(str));

String BarangKeluarsToJson(BarangKeluars data) => json.encode(data.toJson());

class BarangKeluars {
    bool? success;
    List<DataKeluar>? data;
    String? message;

    BarangKeluars({
        this.success,
        this.data,
        this.message,
    });

    factory BarangKeluars.fromJson(Map<String, dynamic> json) => BarangKeluars(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataKeluar>.from(json["data"]!.map((x) => DataKeluar.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataKeluar {
    int? id;
    String? kodeBarang;
    int? jumlah;
    DateTime? tglKeluar;
    String? ket;
    int? idBarang;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataKeluar({
        this.id,
        this.kodeBarang,
        this.jumlah,
        this.tglKeluar,
        this.ket,
        this.idBarang,
        this.createdAt,
        this.updatedAt,
    });

    factory DataKeluar.fromJson(Map<String, dynamic> json) => DataKeluar(
        id: json["id"],
        kodeBarang: json["kode_barang"],
        jumlah: json["jumlah"],
        tglKeluar: json["tgl_keluar"] == null ? null : DateTime.parse(json["tgl_keluar"]),
        ket: json["ket"],
        idBarang: json["id_barang"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "kode_barang": kodeBarang,
        "jumlah": jumlah,
        "tgl_keluar": "${tglKeluar!.year.toString().padLeft(4, '0')}-${tglKeluar!.month.toString().padLeft(2, '0')}-${tglKeluar!.day.toString().padLeft(2, '0')}",
        "ket": ket,
        "id_barang": idBarang,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
