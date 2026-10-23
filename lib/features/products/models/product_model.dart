class ProductModel {
  final String id;
  final String name;
  final String? code;
  final String? barcode;
  final double price;
  final double desi;
  final double? width;
  final double? height;
  final double? length;
  final double? weight;
  final int? status;

  ProductModel({
    required this.id,
    required this.name,
    this.code,
    this.barcode,
    required this.price,
    required this.desi,
    this.width,
    this.height,
    this.length,
    this.weight,
    this.status,
  });

  bool get isActive => status == null || status == 1;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      barcode: json['barcode']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      desi: (json['desi'] is num) ? (json['desi'] as num).toDouble() : double.tryParse(json['desi']?.toString() ?? '') ?? 0.0,
      width: (json['width'] is num) ? (json['width'] as num).toDouble() : double.tryParse(json['width']?.toString() ?? ''),
      height: (json['height'] is num) ? (json['height'] as num).toDouble() : double.tryParse(json['height']?.toString() ?? ''),
      length: (json['length'] is num) ? (json['length'] as num).toDouble() : double.tryParse(json['length']?.toString() ?? ''),
      weight: (json['weight'] is num) ? (json['weight'] as num).toDouble() : double.tryParse(json['weight']?.toString() ?? ''),
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      if (code != null && code!.trim().isNotEmpty) 'code': code!.trim(),
      if (barcode != null && barcode!.trim().isNotEmpty) 'barcode': barcode!.trim(),
      'price': price,
      'desi': desi,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (length != null) 'length': length,
      if (weight != null) 'weight': weight,
      if (status != null) 'status': status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
