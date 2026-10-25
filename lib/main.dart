import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warkop Platarium',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.light,
        ),
      ),
      home: const WarkopStockScreen(),
    );
  }
}

class WarkopItem {
  final UserModel model;
  final String category;

  WarkopItem({required this.model, required this.category});
}

class WarkopStockScreen extends StatefulWidget {
  const WarkopStockScreen({super.key});

  @override
  State<WarkopStockScreen> createState() => _WarkopStockScreenState();
}

class _WarkopStockScreenState extends State<WarkopStockScreen> {
  final UserService _userService = UserService();

  List<WarkopItem> _items = [
    WarkopItem(
      category: 'minuman',
      model: UserModel(id: 1, firstName: "Kopi Hitam", lastName: "Tubruk", email: "Stok: 45 Sachet", avatar: ""),
    ),
    WarkopItem(
      category: 'minuman',
      model: UserModel(id: 2, firstName: "Es Teh", lastName: "Manis", email: "Stok: 100 Porsi", avatar: ""),
    ),
    WarkopItem(
      category: 'minuman',
      model: UserModel(id: 3, firstName: "Kopi ijo", lastName: "bubuk", email: "Stok: 25 Sachet", avatar: ""),
    ),
    WarkopItem(
      category: 'makanan',
      model: UserModel(id: 4, firstName: "Mie", lastName: "Goreng", email: "Stok: 30 Bungkus", avatar: ""),
    ),
    WarkopItem(
      category: 'makanan',
      model: UserModel(id: 5, firstName: "Tempe", lastName: "Tepung", email: "Stok: 50 Porsi", avatar: ""),
    ),
    WarkopItem(
      category: 'makanan',
      model: UserModel(id: 4, firstName: "Mie", lastName: "Godok", email: "Stok: 30 Bungkus", avatar: ""),
    ),
  ];

  void _showFormDialog({WarkopItem? item, int? index}) {
    final nameController = TextEditingController(
      text: item != null ? "${item.model.firstName} ${item.model.lastName}".trim() : "",
    );
    final qtyController = TextEditingController(
      text: item != null ? item.model.email : "",
    );
    String selectedCategory = item != null ? item.category : 'minuman';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                item == null ? "Tambah Stok Warkop" : "Edit Stok Warkop",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Kategori Menu",
                      prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF1B4D3E)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'minuman', child: Text("☕ Minuman")),
                      DropdownMenuItem(value: 'makanan', child: Text("🍜 Makanan")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Menu / Bahan",
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF1B4D3E)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      labelText: "Jumlah Stok (misal: 50 Sachet)",
                      prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1B4D3E)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107), // Warna Kuning
                    foregroundColor: const Color(0xFF1B4D3E), // Teks Hijau
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final inputName = nameController.text.trim();
                    final inputDetail = qtyController.text.trim();

                    if (inputName.isEmpty || inputDetail.isEmpty) return;

                    Navigator.pop(context);

                    try {
                      if (item == null) {
                        final success = await _userService.createUser(inputName, inputDetail);
                        if (success) {
                          setState(() {
                            _items.add(
                              WarkopItem(
                                category: selectedCategory,
                                model: UserModel(
                                  id: _items.length + 1,
                                  firstName: inputName,
                                  lastName: "",
                                  email: inputDetail,
                                  avatar: "",
                                ),
                              ),
                            );
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("POST Berhasil! '$inputName' ditambahkan."),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } else {
                        final success = await _userService.updateUser(item.model.id, inputName, inputDetail);
                        if (success) {
                          setState(() {
                            _items[index!] = WarkopItem(
                              category: selectedCategory,
                              model: UserModel(
                                id: item.model.id,
                                firstName: inputName,
                                lastName: "",
                                email: inputDetail,
                                avatar: item.model.avatar,
                              ),
                            );
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("PUT Berhasil! Data ID ${item.model.id} diperbarui."),
                                backgroundColor: Colors.blue.shade700,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteItem(int id, int index) async {
    try {
      final success = await _userService.deleteUser(id);
      if (success) {
        setState(() {
          _items.removeAt(index);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("DELETE Berhasil! Bahan ID $id dihapus."),
              backgroundColor: Colors.orange.shade900,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          // GRADASI WARNA: Gabungan Hijau Tua (#1B4D3E) dan Kuning Khas Logo (#FFC107 / #FFD54F)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D2B22), // Hijau sangat tua
                Color(0xFF1B4D3E), // Hijau khas Platarium
                Color(0xFFFFC107), // Kuning cerah khas Platarium
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Judul & Logo
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'web/platarium.jpg',
                        height: 45,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Manajemen Stok Warkop",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD54F), // Warna Kuning untuk Tajuk
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar Navigasi dengan Akses Warna Kuning
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
                  ),
                  child: const TabBar(
                    indicatorColor: Color(0xFFFFC107), // Penanda Tab Warna Kuning
                    labelColor: Color(0xFFFFC107),     // Teks Tab Aktif Warna Kuning
                    unselectedLabelColor: Colors.white70,
                    indicatorWeight: 4,
                    tabs: [
                      Tab(icon: Icon(Icons.local_cafe_rounded), text: "Minuman"),
                      Tab(icon: Icon(Icons.ramen_dining_rounded), text: "Makanan"),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFC107), width: 2), // Bingkai Kuning
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: TabBarView(
                        children: [
                          _buildListCategory('minuman'),
                          _buildListCategory('makanan'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFFC107), // Butang Kuning Cerah
          foregroundColor: const Color(0xFF1B4D3E), // Ikon & Teks Hijau Tua
          onPressed: () => _showFormDialog(),
          icon: const Icon(Icons.add_circle_outline, size: 26),
          label: const Text(
            "Tambah Stok",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildListCategory(String category) {
    final filteredList = _items.where((item) => item.category == category).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          "Belum ada stok ${category == 'minuman' ? 'minuman' : 'makanan'}.",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final originalIndex = _items.indexOf(item);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1), // Latar Belakang Ikon Kuning Lembut
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFC107), width: 2),
              ),
              child: Icon(
                category == 'minuman' ? Icons.local_cafe : Icons.fastfood,
                color: const Color(0xFF1B4D3E), // Ikon Hijau
              ),
            ),
            title: Text(
              "${item.model.firstName} ${item.model.lastName}".trim(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B4D3E),
              ),
            ),
            subtitle: Text(
              item.model.email,
              style: const TextStyle(color: Color(0xFF2C7A62), fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF1B4D3E), size: 28),
                  tooltip: "Edit Stok",
                  onPressed: () => _showFormDialog(item: item, index: originalIndex),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                  tooltip: "Hapus Stok",
                  onPressed: () => _deleteItem(item.model.id, originalIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}