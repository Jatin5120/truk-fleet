class MaterialModel {
  final String materialName;
  final String materialType;
  final double quantity;
  final double length;
  final double width;
  final double height;
  MaterialModel({
    this.materialName,
    this.materialType,
    this.quantity,
    this.length,
    this.width,
    this.height,
  });

  MaterialModel copyWith({
    String materialName,
    String materialType,
    double quantity,
    double length,
    double width,
    double height,
  }) {
    return MaterialModel(
      materialName: materialName ?? this.materialName,
      materialType: materialType ?? this.materialType,
      quantity: quantity ?? this.quantity,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialName': materialName,
      'materialType': materialType,
      'quantity': quantity,
      'length': length,
      'width': width,
      'height': height,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      materialName: map['materialName'],
      materialType: map['materialType'],
      quantity: map['quantity'],
      length: map['length'],
      width: map['width'],
      height: map['height'],
    );
  }
}
