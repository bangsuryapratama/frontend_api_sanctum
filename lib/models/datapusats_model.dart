// To parse this JSON data, do
//
//     final dataPusat = dataPusatFromJson(jsonString);

import 'dart:convert';

DataPusat dataPusatFromJson(String str) => DataPusat.fromJson(json.decode(str));

String dataPusatToJson(DataPusat data) => json.encode(data.toJson());

class DataPusat {
    bool? success;
    List<DataPusats>? data;
    String? message;

    DataPusat({
        this.success,
        this.data,
        this.message,
    });

    factory DataPusat.fromJson(Map<String, dynamic> json) => DataPusat(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataPusats>.from(json["data"]!.map((x) => DataPusats.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataPusats {
    int? id;
    String? kodeBarang;
    String? nama;
    String? merk;
    String? foto;
    int? stok;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataPusats({
        this.id,
        this.kodeBarang,
        this.nama,
        this.merk,
        this.foto,
        this.stok,
        this.createdAt,
        this.updatedAt,
    });

    factory DataPusats.fromJson(Map<String, dynamic> json) => DataPusats(
        id: json["id"],
        kodeBarang: json["kode_barang"],
        nama: json["nama"],
        merk: json["merk"],
        foto: json["foto"],
        stok: json["stok"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "kode_barang": kodeBarang,
        "nama": nama,
        "merk": merk,
        "foto": foto,
        "stok": stok,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
