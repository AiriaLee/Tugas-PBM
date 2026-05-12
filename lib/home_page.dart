import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  bool loading = false;
  String token = '';

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  Future<void> loadTokenAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => loading = true);
    try {
      var response = await http.get(
        Uri.parse("https://task.itprojects.web.id/api/products"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List list = data['data']['products'];
        setState(() {
          products = list.map((e) => Product.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> addProduct(String name, int price, String description) async {
    try {
      var response = await http.post(
        Uri.parse("https://task.itprojects.web.id/api/products"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "price": price,
          "description": description,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchProducts();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      var response = await http.delete(
        Uri.parse("https://task.itprojects.web.id/api/products/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchProducts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ✅ SUBMIT TUGAS — ditaruh setelah deleteProduct()
  Future<void> submitTugas() async {
    try {
      var response = await http.post(
        Uri.parse("https://task.itprojects.web.id/api/products/submit"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": "Tugas PBM",
          "price": 32450000,
          "description": "Aplikasi katalog produk album stray kids",
          "github_url": "https://github.com/AiriaLee/Tugas-PBM.git",
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tugas berhasil dikumpulkan!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal submit: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Tambah Produk",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama Produk",
                labelStyle: const TextStyle(color: Colors.red),
                prefixIcon: const Icon(Icons.shopping_bag, color: Colors.red),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Harga",
                labelStyle: const TextStyle(color: Colors.red),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.red),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Deskripsi",
                labelStyle: const TextStyle(color: Colors.red),
                prefixIcon: const Icon(Icons.description, color: Colors.red),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              addProduct(
                nameCtrl.text,
                int.tryParse(priceCtrl.text) ?? 0,
                descCtrl.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String getImageForProduct(String name) {
    if (name.toLowerCase().contains('go live')) {
      return 'assets/images/Album_Go_Live.jpeg';
    }
    if (name.toLowerCase().contains('noeasy')) {
      return 'assets/images/Album_NoEasy.jpg';
    }
    if (name.toLowerCase().contains('oddinary')) {
      return 'assets/images/Album_Oddinary.jpg';
    }
    if (name.toLowerCase().contains('maxident')) {
      return 'assets/images/Album_Maxident.jpg';
    }
    if (name.toLowerCase().contains('5') && name.toLowerCase().contains('star')) {
      return 'assets/images/Album_5Star.jpg';
    }
    if (name.toLowerCase().contains('ate')) {
      return 'assets/images/Album_ate.jpg';
    }
    if (name.toLowerCase().contains('do')) {
      return 'assets/images/Album_DoIt.jpg';
    }
    return 'assets/images/Album_Go_Live.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Katalog Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // ✅ ACTIONS — tombol submit tugas di pojok kanan AppBar
        actions: [
          IconButton(
            onPressed: submitTugas,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            tooltip: 'Kumpulkan Tugas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: Colors.red, size: 64),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada produk",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade900),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            getImageForProduct(p.name),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          p.description,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Rp ${p.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.grey.shade900,
                                    title: const Text(
                                      "Hapus Produk",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content: Text(
                                      "Yakin ingin menghapus '${p.name}'?",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Batal",
                                            style: TextStyle(color: Colors.white54)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteProduct(p.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text("Hapus",
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}