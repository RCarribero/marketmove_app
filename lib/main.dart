import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/router.dart';
import 'src/shared/services/product_service.dart';
import 'src/shared/services/sale_service.dart';
import 'src/shared/services/expense_service.dart';
import 'src/shared/providers/products_provider.dart';
import 'src/shared/providers/ventas_provider.dart';
import 'src/shared/providers/gastos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MarketMoveApp());
}

class MarketMoveApp extends StatelessWidget {
  const MarketMoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(ProductService(supabaseClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => VentasProvider(SaleService(supabaseClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => GastosProvider(ExpenseService(supabaseClient)),
        ),
      ],
      child: MaterialApp.router(
        title: 'MarketMove App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
