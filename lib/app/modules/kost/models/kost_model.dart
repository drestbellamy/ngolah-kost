class KostModel {
  final String id;
  final String name;
  final String address;
  final int roomCount;
  final double? latitude;
  final double? longitude;

  KostModel({
    required this.id,
    required this.name,
    required this.address,
    required this.roomCount,
    this.latitude,
    this.longitude,
  });

  factory KostModel.fromMap(Map<String, dynamic> map) {
    return KostModel(
      id: map['id']?.toString() ?? '',
      name: map['nama_kost']?.toString() ?? '',
      address: map['alamat']?.toString() ?? '',
      roomCount: map['total_kamar'] is int
          ? map['total_kamar'] as int
          : int.tryParse(map['total_kamar']?.toString() ?? '0') ?? 0,
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,
    );
  }
}
