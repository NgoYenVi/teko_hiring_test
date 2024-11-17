import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:teko_test/pages/navigation_screen.dart';
import '../main.dart';
import '../models/product_model.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController productName = TextEditingController();
  final TextEditingController price = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> submitProduct(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      Product newProduct = Product(
        name: productName.text,
        price: int.parse(price.text),
        imageUrl: _imageFile?.path ?? '',
      );

      Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sản phẩm đã được thêm!')));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigationScreen(initialIndex: 0),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng kiểm tra lại thông tin")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Thêm sản phẩm",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text("*", style: TextStyle(color: Colors.redAccent)),
                      SizedBox(width: 5),
                      Text("Tên sản phẩm"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: productName,
                    decoration: const InputDecoration(
                      hintText: "Vui lòng nhập tên sản phẩm...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập tên sản phẩm";
                      }
                      if (value.length > 20) {
                        return "Tên sản phẩm dài quá 20 ký tự";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Text("*", style: TextStyle(color: Colors.redAccent)),
                      SizedBox(width: 5),
                      Text("Giá sản phẩm"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: price,
                    decoration: const InputDecoration(
                      hintText: "Vui lòng nhập giá sản phẩm...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập giá sản phẩm";
                      }
                      if (int.parse(value) < 10000 || int.parse(value) > 100000000) {
                        return "Giá sản phẩm vượt quá giới hạn";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Text("Ảnh sản phẩm"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _imageFile == null
                              ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_upload_outlined),
                              SizedBox(width: 5),
                              Text('Chọn tệp tin (Tối đa 5MB)'),
                            ],
                          )
                              : Text('${_imageFile?.path}'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => submitProduct(context),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent),
                    child: const Text("Tạo sản phẩm"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
