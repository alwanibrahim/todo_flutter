import 'package:flutter/material.dart';
import 'package:image/provider/category_provider.dart';
import 'package:image/provider/label_provider.dart';
import 'package:image/provider/todo_provider.dart';
import 'package:provider/provider.dart';
import 'package:image/models/todo_model.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priorityController = TextEditingController();
  int? _categoryId;
  int? _labelId;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    // Ambil data kategori saat screen pertama kali dibuka
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.fetchCategories();

    // Ambil data label saat screen pertama kali dibuka
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);
    labelProvider.fetchLabels();
  }

 void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Kategori Baru"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: "Nama Kategori",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isNotEmpty) {
                  final categoryProvider =
                      Provider.of<CategoryProvider>(context, listen: false);

                  await categoryProvider.addCategory(categoryController.text);

                  // Perbarui dropdown dengan kategori terbaru
                  if (categoryProvider.categories.isNotEmpty) {
                    setState(() {
                      _categoryId = categoryProvider.categories.last.id;
                    });
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    var labelProvider = Provider.of<LabelProvider>(context);

    // Tampilkan loading indicator jika data sedang dimuat
    if (categoryProvider.isLoading || labelProvider.isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // Tampilkan pesan error jika terjadi error
    if (categoryProvider.errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
            ),
          ),
          child: Center(
              child: Text(categoryProvider.errorMessage!,
                  style: TextStyle(color: Colors.white))),
        ),
      );
    }
    if (labelProvider.errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
            ),
          ),
          child: Center(
              child: Text(labelProvider.errorMessage!,
                  style: TextStyle(color: Colors.white))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah To-Do Baru',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: Container(
        // Pastikan Container mengisi seluruh layar
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade800],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
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
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Judul',
                            labelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Judul tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi',
                            labelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _priorityController.text.isNotEmpty
                              ? _priorityController.text
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Prioritas',
                            labelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'rendah', child: Text('Rendah')),
                            DropdownMenuItem(
                                value: 'sedang', child: Text('Sedang')),
                            DropdownMenuItem(
                                value: 'tinggi', child: Text('Tinggi')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _priorityController.text = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Prioritas harus dipilih';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _categoryId,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            ...categoryProvider.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                            DropdownMenuItem(
                              value:
                                  -1, // Value untuk opsi "Tambah Kategori Baru"
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.deepPurple),
                                  SizedBox(width: 8),
                                  Text("Tambah Kategori Baru"),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == -1) {
                              _showAddCategoryDialog();
                            } else {
                              setState(() {
                                _categoryId = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Kategori harus dipilih';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _labelId,
                          decoration: InputDecoration(
                            labelText: 'Label',
                            labelStyle: TextStyle(color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: labelProvider.labels.map((label) {
                            return DropdownMenuItem(
                              value: label.id,
                              child: Text(label.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _labelId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Label harus dipilih';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                _selectedDeadline = pickedDate;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Deadline',
                              labelStyle: TextStyle(color: Colors.deepPurple),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _selectedDeadline != null
                                  ? "${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}"
                                  : "Pilih Tanggal",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deadline harus dipilih')),
        );
        return;
      }

      // Format deadline ke string "YYYY-MM-DD"
      String formattedDeadline =
          "${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}";

      // Data yang dikirim ke API
      Map<String, dynamic> todoData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'priority': _priorityController.text,
        'deadline': formattedDeadline, // Kirim deadline yang dipilih
        'category_id': _categoryId,
        'label_id': _labelId,
      };

      await Provider.of<TodoProvider>(context, listen: false).addTodo(todoData);

      Navigator.pop(context);
    }
  }
}
