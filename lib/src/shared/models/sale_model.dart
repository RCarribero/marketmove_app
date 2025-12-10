/// Modelo que representa una venta realizada.
///
/// Corresponde a la tabla 'ventas' en Supabase.
class Sale {
  /// Identificador único de la venta.
  final int? id;

  /// ID del usuario propietario de la venta (Supabase Auth).
  final String? userId;

  /// Monto total de la venta.
  final double total;

  /// Fecha y hora en que se realizó la venta.
  final DateTime date;

  /// Nombre del cliente (opcional).
  final String? customerName;

  /// Lista de items vendidos (almacenado como JSONB en Supabase).
  /// Cada item es un mapa con detalles del producto vendido.
  final List<Map<String, dynamic>> items;

  /// Constructor inmutable para crear una instancia de [Sale].
  const Sale({
    this.id,
    this.userId,
    required this.total,
    required this.date,
    this.customerName,
    required this.items,
  });

  /// Crea una copia de esta instancia con los campos modificados.
  Sale copyWith({
    int? id,
    String? userId,
    double? total,
    DateTime? date,
    String? customerName,
    List<Map<String, dynamic>>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
    );
  }

  /// Convierte la instancia a un mapa JSON compatible con Supabase.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'total': total,
      'date': date.toIso8601String(),
      'customername':
          customerName, // Lowercase in DB usually? Schema said customername
      'items': items,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  /// Crea una instancia de [Sale] a partir de un mapa JSON.
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      customerName: json['customername'] as String?,
      items: List<Map<String, dynamic>>.from(json['items'] as List),
    );
  }
}
