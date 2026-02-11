class DivisiModel {
  final String id;
  final String lembagaId;
  final String namaDivisi;
  final String? deskripsi;
  final String? status;

  DivisiModel({
    required this.id,
    required this.lembagaId,
    required this.namaDivisi,
    this.deskripsi,
    this.status,
  });

  DivisiModel copyWith({
    String? id,
    String? lembagaId,
    String? namaDivisi,
    String? deskripsi,
    String? status,
  }) {
    return DivisiModel(
      id: id ?? this.id,
      lembagaId: lembagaId ?? this.lembagaId,
      namaDivisi: namaDivisi ?? this.namaDivisi,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
    );
  }

  factory DivisiModel.fromJson(Map<String, dynamic> json) => DivisiModel(
    id: json['id'],
    lembagaId: json['lembaga_id'] ?? '',
    namaDivisi: json['nama_divisi'] ?? '',
    deskripsi: json['deskripsi'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'lembaga_id': lembagaId,
    'nama_divisi': namaDivisi,
    'deskripsi': deskripsi,
    'status': status,
  };
}