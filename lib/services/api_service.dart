import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  final String apiUrl = 'https://hiring-test.stag.tekoapis.net/api/products/management';

  Future<List<Product>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDataLoaded = prefs.getBool('isDataLoaded') ?? false;

    if (isDataLoaded) {
      String? savedData = prefs.getString('productData');
      if (savedData != null) {
        final List<dynamic> jsonList = jsonDecode(savedData);
        return jsonList.map((item) => Product.fromJson(item)).toList();
      }
    }

    final url = Uri.parse(apiUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;

      final productListItem = items.firstWhere(
            (item) => item['type'] == 'ProductList',
        orElse: () => throw Exception('Lỗi tìm sản phẩm'),
      );
      final productListData = productListItem['customAttributes']['productlist']['items'] as List<dynamic>;

      final List<Product> productList = productListData.map((item) => Product.fromJson(item)).toList();

      return productList;
    } else {
      throw Exception('Lỗi tải dữ liệu từ API: ${response.statusCode}');
    }
  }
}