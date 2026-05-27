class MaintenanceOrder {
  const MaintenanceOrder({
    required this.id,
    required this.bike,
    required this.createdBy,
    required this.priority,
    required this.type,
    required this.status,
    required this.reportedIssue,
    required this.createdAt,
    required this.updatedAt,
    this.ticketId,
    this.assignedTo,
    this.resultStatus,
    this.diagnosis,
    this.resolutionNotes,
    this.currentLocation,
    this.estimatedMinutes,
    this.outOfServiceReason,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.history = const [],
  });

  final int id;
  final int? ticketId;
  final MaintenanceBike bike;
  final MaintenanceUser? assignedTo;
  final MaintenanceUser createdBy;
  final String priority;
  final String type;
  final String status;
  final String? resultStatus;
  final String reportedIssue;
  final String? diagnosis;
  final String? resolutionNotes;
  final String? currentLocation;
  final int? estimatedMinutes;
  final String? outOfServiceReason;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MaintenanceHistory> history;

  bool get isFinalized => status == 'FINALIZED';

  factory MaintenanceOrder.fromJson(Map<String, dynamic> json) {
    return MaintenanceOrder(
      id: _asInt(json['id']),
      ticketId: _asNullableInt(json['ticketId']),
      bike: MaintenanceBike.fromJson(_asMap(json['bike'])),
      assignedTo: json['assignedTo'] == null
          ? null
          : MaintenanceUser.fromJson(_asMap(json['assignedTo'])),
      createdBy: MaintenanceUser.fromJson(_asMap(json['createdBy'])),
      priority: json['priority']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      resultStatus: json['resultStatus']?.toString(),
      reportedIssue: json['reportedIssue']?.toString() ?? '',
      diagnosis: json['diagnosis']?.toString(),
      resolutionNotes: json['resolutionNotes']?.toString(),
      currentLocation: json['currentLocation']?.toString(),
      estimatedMinutes: _asNullableInt(json['estimatedMinutes']),
      outOfServiceReason: json['outOfServiceReason']?.toString(),
      assignedAt: _asDate(json['assignedAt']),
      startedAt: _asDate(json['startedAt']),
      completedAt: _asDate(json['completedAt']),
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _asDate(json['updatedAt']) ?? DateTime.now(),
      history: (json['history'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MaintenanceHistory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}

class MaintenanceBike {
  const MaintenanceBike({
    required this.id,
    required this.codigo,
    required this.marca,
    required this.modelo,
    required this.tipo,
    required this.estado,
    this.puesto,
  });

  final int id;
  final String codigo;
  final String marca;
  final String modelo;
  final String tipo;
  final String estado;
  final MaintenanceStation? puesto;

  factory MaintenanceBike.fromJson(Map<String, dynamic> json) {
    return MaintenanceBike(
      id: _asInt(json['id']),
      codigo: json['codigo']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      puesto: json['puesto'] == null
          ? null
          : MaintenanceStation.fromJson(_asMap(json['puesto'])),
    );
  }
}

class MaintenanceStation {
  const MaintenanceStation({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.direccion,
    this.latitud,
    this.longitud,
  });

  final int id;
  final String nombre;
  final String codigo;
  final String direccion;
  final double? latitud;
  final double? longitud;

  factory MaintenanceStation.fromJson(Map<String, dynamic> json) {
    return MaintenanceStation(
      id: _asInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      latitud: _asNullableDouble(json['latitud']),
      longitud: _asNullableDouble(json['longitud']),
    );
  }
}

class MaintenanceUser {
  const MaintenanceUser({
    required this.id,
    required this.firstName,
    required this.email,
    this.lastName,
  });

  final int id;
  final String firstName;
  final String? lastName;
  final String email;

  String get fullName {
    final parts = [
      firstName,
      if (lastName != null && lastName!.isNotEmpty) lastName!,
    ];
    return parts.join(' ');
  }

  factory MaintenanceUser.fromJson(Map<String, dynamic> json) {
    return MaintenanceUser(
      id: _asInt(json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString() ?? '',
    );
  }
}

class MaintenanceHistory {
  const MaintenanceHistory({
    required this.id,
    required this.action,
    required this.changedBy,
    required this.createdAt,
    this.previousStatus,
    this.newStatus,
    this.note,
  });

  final int id;
  final String action;
  final String? previousStatus;
  final String? newStatus;
  final String? note;
  final MaintenanceUser changedBy;
  final DateTime createdAt;

  factory MaintenanceHistory.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistory(
      id: _asInt(json['id']),
      action: json['action']?.toString() ?? '',
      previousStatus: json['previousStatus']?.toString(),
      newStatus: json['newStatus']?.toString(),
      note: json['note']?.toString(),
      changedBy: MaintenanceUser.fromJson(_asMap(json['changedBy'])),
      createdAt: _asDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

int _asInt(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;

int? _asNullableInt(Object? value) => int.tryParse(value?.toString() ?? '');

double? _asNullableDouble(Object? value) =>
    double.tryParse(value?.toString() ?? '');

DateTime? _asDate(Object? value) => DateTime.tryParse(value?.toString() ?? '');
