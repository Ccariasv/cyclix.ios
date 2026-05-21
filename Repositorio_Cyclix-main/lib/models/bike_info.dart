class BikeInfo {
  const BikeInfo({
    required this.id,
    required this.costPerMinuteDisplay,
    this.costPerMinute = 1.0,
    this.code,
    this.brand,
    this.model,
    this.color,
    this.type,
    this.status,
    this.stationName,
    this.isDemo = false,
  });

  final String id;
  final String costPerMinuteDisplay;
  final double costPerMinute;
  final String? code;
  final String? brand;
  final String? model;
  final String? color;
  final String? type;
  final String? status;
  final String? stationName;
  final bool isDemo;

  factory BikeInfo.fromJson(Map<String, dynamic> json) {
    final pricePerHour = (json['precioPorHora'] as num?)?.toDouble() ?? 60;
    final pricePerMinute = pricePerHour / 60;
    final puesto = json['puesto'];

    return BikeInfo(
      id: json['id']?.toString() ?? json['codigo']?.toString() ?? '0',
      code: json['codigo']?.toString(),
      brand: json['marca']?.toString(),
      model: json['modelo']?.toString(),
      color: json['color']?.toString(),
      type: json['tipo']?.toString(),
      status: json['estado']?.toString(),
      stationName: puesto is Map ? puesto['nombre']?.toString() : null,
      isDemo: false,
      costPerMinute: pricePerMinute,
      costPerMinuteDisplay:
          'Referencia de bicicleta: Q.${pricePerHour.toStringAsFixed(2)} / hora (Q.${pricePerMinute.toStringAsFixed(2)} / min)',
    );
  }
}
