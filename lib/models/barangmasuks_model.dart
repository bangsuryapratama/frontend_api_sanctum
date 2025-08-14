// To parse this JSON data, do
//
//     final barangMasuks = barangMasuksFromJson(jsonString);

import 'dart:convert';

BarangMasuks barangMasuksFromJson(String str) => BarangMasuks.fromJson(json.decode(str));

String barangMasuksToJson(BarangMasuks data) => json.encode(data.toJson());

class BarangMasuks {
    bool? success;
    List<DataMasuk>? data;
    String? message;

    BarangMasuks({
        this.success,
        this.data,
        this.message,
    });

    factory BarangMasuks.fromJson(Map<String, dynamic> json) => BarangMasuks(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataMasuk>.from(json["data"]!.map((x) => DataMasuk.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataMasuk {
    int? id;
    String? kodeBarang;
    int? jumlah;
    DateTime? tglMasuk;
    String? ket;
    int? idBarang;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataMasuk({
        this.id,
        this.kodeBarang,
        this.jumlah,
        this.tglMasuk,
        this.ket,
        this.idBarang,
        this.createdAt,
        this.updatedAt,
    });

    factory DataMasuk.fromJson(Map<String, dynamic> json) => DataMasuk(
        id: json["id"],
        kodeBarang: json["kode_barang"],
        jumlah: json["jumlah"],
        tglMasuk: json["tgl_masuk"] == null ? null : DateTime.parse(json["tgl_masuk"]),
        ket: json["ket"],
        idBarang: json["id_barang"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "kode_barang": kodeBarang,
        "jumlah": jumlah,
        "tgl_masuk": "${tglMasuk!.year.toString().padLeft(4, '0')}-${tglMasuk!.month.toString().padLeft(2, '0')}-${tglMasuk!.day.toString().padLeft(2, '0')}",
        "ket": ket,
        "id_barang": idBarang,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
