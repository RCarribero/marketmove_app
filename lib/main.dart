import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/router.dart';
import 'src/shared/services/product_service.dart';
import 'src/shared/services/sale_service.dart';
import 'src/shared/services/expense_service.dart';
import 'src/shared/services/profile_service.dart';
import 'src/shared/providers/products_provider.dart';
import 'src/shared/providers/ventas_provider.dart';
import 'src/shared/providers/gastos_provider.dart';
import 'src/shared/providers/auth_provider.dart';
import 'src/shared/providers/theme_provider.dart';
import 'src/shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qgccgvjsmzjzeqelyutq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnY2NndmpzbXpqemVxZWx5dXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzQ4NDIsImV4cCI6MjA4MDE1MDg0Mn0.YPEaJAYmBrirsyBJ7o7QLPhRgPti9WuLeZaG-p0IhmQ',
  );

  runApp(const MarketMoveApp());
}

class MarketMoveApp extends StatelessWidget {
  const MarketMoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final profileService = ProfileService(supabaseClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(supabaseClient, profileService)..loadSession(),
        ),
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'MarketMove App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
