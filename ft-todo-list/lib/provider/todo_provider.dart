import 'package:flutter/material.dart';
import 'package:image/api/todo_api.dart';
import 'package:image/models/todo_model.dart';
import 'package:image/provider/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final TodoApi _apiService = TodoApi();

  void toggleTodoStatus(Todo todo) {
    todo.isDone = !todo.isDone;
    notifyListeners();
  }

  Future<void> getTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedTodos = await _apiService.fetchTodos();
      _todos = fetchedTodos ?? [];
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
      print('Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(Map<String, dynamic> todoData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Kirim data ke API
      final newTodo = await _apiService.createTodo(todoData);

      // Tambahkan todo baru ke list
      _todos.add(newTodo);
    } catch (e) {
      _errorMessage = e.toString();
      print("Error di TodoProvider: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(int id, Map<String, dynamic> todoData) async {
    try {
      Todo updatedTodo = await _apiService.updateTodo(id, todoData);
      int index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      print("Error update To-Do: $e");
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      print("Gagal menghapus To-Do: $e");
    }
  }

   void checkDeadlines() {
    final now = DateTime.now();

    for (var todo in _todos) {
      final difference = todo.deadline.difference(now).inHours;

      // Hanya kasih notifikasi jika deadline dalam 24 jam ke depan
      if (difference > 0 && difference <= 24) {
        NotificationService.showNotification(
          "⚠️ Deadline Hampir Tiba!",
          "Tugas '${todo.title}' akan jatuh tempo dalam $difference jam.",
        );
      }
    }
  }

}
