class Shipping {
  late int id;
  late String title;
  late String path;
  late double progress = 0.0;
  late DateTime createdAt = DateTime.now();
  late DateTime updatedAt = DateTime.now();


  Shipping(this.title, this.path);

  Shipping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    path = json['path'];
    progress = json['progress'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'path': path,
      'progress': progress,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }
}