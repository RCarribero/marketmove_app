import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/profile_model.dart';

class EmbeddedMockData {
  static const String demoUserId = 'demo-admin-user';

  static final Profile demoProfile = Profile(
    id: demoUserId,
    email: 'admin@marketmove.app',
    role: 'admin',
    createdAt: DateTime(2025, 1, 1),
  );

  static List<Product> get initialProducts {
    final now = DateTime.now();
    return [
      Product(
        id: 1,
        userId: demoUserId,
        name: 'Café Espresso Arábica Especialidad',
        price: 14.50,
        stock: 28,
        description: 'Bolsa 1kg en grano tostado natural de origen Colombia.',
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Product(
        id: 2,
        userId: demoUserId,
        name: 'Té Matcha Ceremonial Uji Grado A',
        price: 24.00,
        stock: 16,
        description: 'Lata 80g de té matcha puro importado de Kioto, Japón.',
        imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      Product(
        id: 3,
        userId: demoUserId,
        name: 'Vaso Térmico Acero Inoxidable 450ml',
        price: 18.90,
        stock: 4, // Alerta stock bajo
        description: 'Doble pared térmica con cierre hermético anti-goteo.',
        imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Product(
        id: 4,
        userId: demoUserId,
        name: 'Taza Cerámica Artesanal MarketMove',
        price: 9.50,
        stock: 42,
        description: 'Cerámica gres esmaltada a mano apta para lavavajillas.',
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Product(
        id: 5,
        userId: demoUserId,
        name: 'Molinillo de Café Manual Muelas Cónicas',
        price: 36.00,
        stock: 9,
        description: 'Cuerpo de aluminio y muelas cerámicas regulables.',
        imageUrl: 'https://images.unsplash.com/photo-1589396575653-c09c794ff6a6?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Product(
        id: 6,
        userId: demoUserId,
        name: 'Pack 3 Siropes Barista Variados',
        price: 12.50,
        stock: 20,
        description: 'Vainilla Bourbon, Caramelo Salado y Avellana Tostada.',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Product(
        id: 7,
        userId: demoUserId,
        name: 'Bolsa Tote Algodón Orgánico Eco',
        price: 6.90,
        stock: 55,
        description: '100% algodón orgánico certificado 300 GSM reforzado.',
        imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Product(
        id: 8,
        userId: demoUserId,
        name: 'Galletas Artesanales Avena & Miel',
        price: 3.80,
        stock: 2, // Alerta stock crítico
        description: 'Paquete 200g horneado a diario con ingredientes ecológicos.',
        imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=400&q=80',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<Sale> get initialSales {
    final now = DateTime.now();
    return [
      Sale(
        id: 101,
        userId: demoUserId,
        total: 52.90,
        date: now.subtract(const Duration(hours: 2)),
        customerName: 'Elena Martínez',
        items: [
          {'name': 'Café Espresso Arábica', 'quantity': 2, 'price': 14.50},
          {'name': 'Té Matcha Ceremonial', 'quantity': 1, 'price': 23.90},
        ],
      ),
      Sale(
        id: 102,
        userId: demoUserId,
        total: 28.40,
        date: now.subtract(const Duration(hours: 5)),
        customerName: 'Carlos Gutiérrez',
        items: [
          {'name': 'Vaso Térmico Acero', 'quantity': 1, 'price': 18.90},
          {'name': 'Taza Cerámica', 'quantity': 1, 'price': 9.50},
        ],
      ),
      Sale(
        id: 103,
        userId: demoUserId,
        total: 48.50,
        date: now.subtract(const Duration(days: 1, hours: 3)),
        customerName: 'Sofía Navarro',
        items: [
          {'name': 'Molinillo de Café Manual', 'quantity': 1, 'price': 36.00},
          {'name': 'Pack 3 Siropes Barista', 'quantity': 1, 'price': 12.50},
        ],
      ),
      Sale(
        id: 104,
        userId: demoUserId,
        total: 35.80,
        date: now.subtract(const Duration(days: 2, hours: 4)),
        customerName: 'David Ramos',
        items: [
          {'name': 'Café Espresso Arábica', 'quantity': 2, 'price': 14.50},
          {'name': 'Bolsa Tote Eco', 'quantity': 1, 'price': 6.80},
        ],
      ),
      Sale(
        id: 105,
        userId: demoUserId,
        total: 71.90,
        date: now.subtract(const Duration(days: 3, hours: 2)),
        customerName: 'Lucía Morales',
        items: [
          {'name': 'Té Matcha Ceremonial', 'quantity': 2, 'price': 24.00},
          {'name': 'Vaso Térmico Acero', 'quantity': 1, 'price': 18.90},
          {'name': 'Galletas Artesanales', 'quantity': 1, 'price': 3.80},
        ],
      ),
      Sale(
        id: 106,
        userId: demoUserId,
        total: 60.50,
        date: now.subtract(const Duration(days: 4, hours: 6)),
        customerName: 'Alejandro Peña',
        items: [
          {'name': 'Molinillo de Café Manual', 'quantity': 1, 'price': 36.00},
          {'name': 'Café Espresso Arábica', 'quantity': 1, 'price': 14.50},
          {'name': 'Taza Cerámica', 'quantity': 1, 'price': 9.50},
        ],
      ),
      Sale(
        id: 107,
        userId: demoUserId,
        total: 44.90,
        date: now.subtract(const Duration(days: 5, hours: 5)),
        customerName: 'Beatriz Méndez',
        items: [
          {'name': 'Pack 3 Siropes Barista', 'quantity': 2, 'price': 12.50},
          {'name': 'Vaso Térmico Acero', 'quantity': 1, 'price': 18.90},
        ],
      ),
      Sale(
        id: 108,
        userId: demoUserId,
        total: 82.00,
        date: now.subtract(const Duration(days: 6, hours: 3)),
        customerName: 'Javier Sánchez',
        items: [
          {'name': 'Café Espresso Arábica', 'quantity': 3, 'price': 14.50},
          {'name': 'Té Matcha Ceremonial', 'quantity': 1, 'price': 24.00},
          {'name': 'Taza Cerámica', 'quantity': 1, 'price': 9.50},
          {'name': 'Galletas Artesanales', 'quantity': 1, 'price': 3.80},
        ],
      ),
      Sale(
        id: 109,
        userId: demoUserId,
        total: 115.00,
        date: now.subtract(const Duration(days: 12)),
        customerName: 'Cafetería El Faro',
        items: [
          {'name': 'Café Espresso Arábica', 'quantity': 6, 'price': 14.50},
          {'name': 'Pack 3 Siropes Barista', 'quantity': 2, 'price': 12.50},
        ],
      ),
      Sale(
        id: 110,
        userId: demoUserId,
        total: 96.50,
        date: now.subtract(const Duration(days: 18)),
        customerName: 'Marta Alonso',
        items: [
          {'name': 'Molinillo de Café Manual', 'quantity': 2, 'price': 36.00},
          {'name': 'Té Matcha Ceremonial', 'quantity': 1, 'price': 24.00},
        ],
      ),
    ];
  }

  static List<Expense> get initialExpenses {
    final now = DateTime.now();
    return [
      Expense(
        id: 201,
        userId: demoUserId,
        amount: 850.00,
        description: 'Alquiler local comercial del mes',
        category: 'Alquiler',
        date: now.subtract(const Duration(days: 10)),
      ),
      Expense(
        id: 202,
        userId: demoUserId,
        amount: 142.30,
        description: 'Factura electricidad e iluminación',
        category: 'Servicios',
        date: now.subtract(const Duration(days: 4)),
      ),
      Expense(
        id: 203,
        userId: demoUserId,
        amount: 420.00,
        description: 'Reposición grano café verde a tostador',
        category: 'Inventario',
        date: now.subtract(const Duration(days: 8)),
      ),
      Expense(
        id: 204,
        userId: demoUserId,
        amount: 95.00,
        description: 'Campaña anuncios Meta / Instagram Ads',
        category: 'Marketing',
        date: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: 205,
        userId: demoUserId,
        amount: 58.50,
        description: 'Bolsas Kraft para take-away y embalajes',
        category: 'Suministros',
        date: now.subtract(const Duration(days: 14)),
      ),
      Expense(
        id: 206,
        userId: demoUserId,
        amount: 45.00,
        description: 'Conexión fibra óptica y TPV virtual',
        category: 'Servicios',
        date: now.subtract(const Duration(days: 16)),
      ),
    ];
  }
}
