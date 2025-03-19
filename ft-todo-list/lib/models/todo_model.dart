class Todo {
  final int id;
  final int userId;
  final int categoryId;
  final int labelId;
  final String title;
  final String description;
  final String priority;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category; // Tambahkan properti category
  final Label label; // Tambahkan properti label
  late final bool isDone; // ✅ Tambahkan status selesai


  Todo({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.labelId,
    required this.title,
    required this.description,
    required this.priority,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.label,
    this.isDone = false
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int? ?? 0, // Berikan nilai default jika null
      userId: json['user_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      labelId: json['label_id'] as int? ?? 0,
      title: json['title'] as String? ?? '', // Berikan nilai default jika null
      description: json['description'] as String? ??
          '', // Berikan nilai default jika null
      priority:
          json['priority'] as String? ?? '', // Berikan nilai default jika null
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? '') ??
          DateTime.now(), // Handle jika deadline null atau format tidak valid
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(), // Handle jika created_at null atau format tidak valid
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(), // Handle jika updated_at null atau format tidak valid
      category: json['category'] != null
          ? Category.fromJson(json['category']
              as Map<String, dynamic>) // Parse nested category jika tidak null
          : Category(
              id: 0,
              userId: 0,
              name: 'No Category',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()), // Berikan nilai default jika null
      label: json['label'] != null
          ? Label.fromJson(json['label']
              as Map<String, dynamic>) // Parse nested label jika tidak null
          : Label(
              id: 0,
              userId: 0,
              name: 'No Label',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()), // Berikan nilai default jika null
    );
  }
}

class Category {
  final int id;
  final int userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Uncategorized',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Label {
  final int id;
  final int userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Label({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? 'No Label',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
