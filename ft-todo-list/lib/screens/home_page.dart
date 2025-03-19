import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image/models/todo_model.dart';
import 'package:image/provider/category_provider.dart';
import 'package:image/provider/todo_provider.dart';
import 'package:image/screens/add_todo.dart';
import 'package:image/screens/edit_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Category? selectedCategory;
  String? selectedPriority; // Untuk menyimpan prioritas yang dipilih
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce; // Untuk debounce pencarian

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Fungsi untuk melakukan pencarian dengan debounce
  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {}); // Memperbarui UI setelah 500ms
    });
  }

  @override
  Widget build(BuildContext context) {
    var todoProvider = Provider.of<TodoProvider>(context);
    var categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTodoScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: "Cari To-Do...",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Dropdown untuk memilih kategori dan prioritas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Dropdown Kategori
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<Category>(
                        value: selectedCategory,
                        hint: Text("Pilih Kategori",
                            style: TextStyle(color: Colors.white)),
                        isExpanded: true,
                        dropdownColor: Colors.deepPurple.shade700,
                        onChanged: (Category? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<Category>(
                            value: null,
                            child: Text("Semua Kategori",
                                style: TextStyle(color: Colors.white)),
                          ),
                          ...categoryProvider.categories.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name,
                                  style: TextStyle(color: Colors.white)),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Dropdown Prioritas
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        hint: Text("Prioritas",
                            style: TextStyle(color: Colors.white)),
                        isExpanded: true,
                        dropdownColor: Colors.deepPurple.shade700,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPriority = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text("Semua Prioritas",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem<String>(
                            value: "rendah",
                            child: Text("Rendah",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem<String>(
                            value: "sedang",
                            child: Text("Sedang",
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem<String>(
                            value: "tinggi",
                            child: Text("Tinggi",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List To-Do sesuai kategori, prioritas, dan pencarian
            Expanded(
              child: Consumer<TodoProvider>(
                builder: (context, todoProvider, child) {
                  if (todoProvider.isLoading) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (todoProvider.errorMessage != null) {
                    return Center(
                        child: Text(todoProvider.errorMessage!,
                            style: TextStyle(color: Colors.white)));
                  }

                  // Filter To-Do berdasarkan kategori, prioritas, dan pencarian
                  List<Todo> filteredTodos = todoProvider.todos.where((todo) {
                    // Filter kategori
                    if (selectedCategory != null &&
                        todo.category.id != selectedCategory!.id) {
                      return false;
                    }
                    // Filter prioritas
                    if (selectedPriority != null &&
                        todo.priority != selectedPriority) {
                      return false;
                    }
                    // Filter pencarian
                    if (_searchController.text.isNotEmpty &&
                        !todo.title
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) &&
                        !todo.description
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) {
                      return false;
                    }
                    return true;
                  }).toList();

                  // Sorting berdasarkan prioritas
                  filteredTodos.sort((a, b) {
                    final priorityOrder = {"tinggi": 1, "sedang": 2, "rendah": 3};
                    return priorityOrder[a.priority]!
                        .compareTo(priorityOrder[b.priority]!);
                  });

                  return ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return AnimatedListItem(
                          index: index, todo: todo, todoProvider: todoProvider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET ANIMASI LIST TO-DO
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Todo todo;
  final TodoProvider todoProvider;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.todo,
    required this.todoProvider,
  });

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  bool _isChecked = false; // State untuk menyimpan status checkbox
  bool _showAnimation = false; // State untuk mengontrol tampilan animasi

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Checkbox(
            value: _isChecked,
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value ?? false; // Update status checkbox
                if (_isChecked) {
                  _showAnimation = true; // Tampilkan animasi
                  Timer(Duration(seconds: 2), () {
                    setState(() {
                      _showAnimation =
                          false; // Sembunyikan animasi setelah 2 detik
                    });
                  });
                }
              });
            },
            activeColor: Colors.deepPurple, // Warna checkbox ketika dicentang
          ),
          title: Text(
            widget.todo.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              decoration:
                  _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                widget.todo.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  decoration: _isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Kategori: ${widget.todo.category.name}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: _isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.label, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Label: ${widget.todo.label.name}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        decoration: _isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        widget.todo.priority == "rendah"
                            ? 1
                            : widget.todo.priority == "sedang"
                                ? 2
                                : 3,
                        (index) => Icon(Icons.star, size: 16, color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.purple),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Deadline: ${widget.todo.deadline}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                        decoration: _isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Tambahkan animasi Lottie di sini
              Visibility(
                visible: _showAnimation,
                child: Center(
                  child: Lottie.asset(
                    'assets/centang.json', // Path ke file Lottie
                    height: 100,
                    fit: BoxFit.cover,
                    repeat: false, // Animasi tidak berulang
                  ),
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.deepPurple),
            onSelected: (String value) {
              if (value == "edit") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTodoScreen(todo: widget.todo),
                  ),
                );
              } else if (value == "delete") {
                _confirmDeleteTodo();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Hapus"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTodo() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi",
            style: TextStyle(color: Colors.deepPurple)),
        content: Text("Apakah Anda yakin ingin menghapus To-Do ini?",
            style: TextStyle(color: Colors.grey[800])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal",
                style: TextStyle(color: Colors.deepPurple)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await widget.todoProvider.deleteTodo(widget.todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("To-Do berhasil dihapus",
                  style: TextStyle(color: Colors.white))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal menghapus To-Do: $e",
                  style: TextStyle(color: Colors.white))),
        );
      }
    }
  }
}
