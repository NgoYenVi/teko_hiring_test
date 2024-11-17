import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teko_test/pages/navigation_screen.dart';
import 'package:teko_test/services/api_service.dart';
import 'models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    // Avoid fetching again if already in progress or already loaded
    if (_isLoading || _products.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _products = await ApiService().fetchData();
      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products: ${e.toString()}';
    }

    notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (productProvider.errorMessage != null) {
            return Scaffold(
              body: Center(child: Text(productProvider.errorMessage!)),
            );
          }
          return const NavigationScreen(initialIndex: 0);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
