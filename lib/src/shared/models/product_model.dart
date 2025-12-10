/// Modelo que representa un producto en el inventario.
///
/// Corresponde a la tabla 'productos' en Supabase.
class Product {
  /// Identificador único del producto.
  final int? id;

  /// ID del usuario propietario del producto (Supabase Auth).
  final String? userId;

  /// Nombre del producto.
  final String name;

  /// Precio unitario del producto.
  final double price;

  /// Cantidad disponible en stock.
  final int stock;

  /// Descripción opcional del producto.
  final String? description;

  /// URL de la imagen del producto (opcional).
  final String? imageUrl;

  /// Fecha de creación del registro.
  final DateTime? createdAt;

  /// Constructor inmutable para crear una instancia de [Product].
  const Product({
    this.id,
    this.userId,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  /// Crea una copia de esta instancia con los campos modificados.
  Product copyWith({
    int? id,
    String? userId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convierte la instancia a un mapa JSON compatible con Supabase.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'imageurl':
          imageUrl, // Note: DB column is imageurl (lowercase usually in postgres unless quoted) but schema said imageurl
    };
    if (id != null) map['id'] = id;
    if (createdAt != null) map['createdat'] = createdAt!.toIso8601String();
    return map;
  }

  /// Crea una instancia de [Product] a partir de un mapa JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      description: json['description'] as String?,
      imageUrl: json['imageurl'] as String?, // DB column name
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'] as String)
          : null,
    );
  }
}
