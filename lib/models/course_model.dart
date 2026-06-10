class Course {
  final int id;
  final String title;
  final String body;
  final int userId;

  const Course({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        userId: json['userId'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
      };

  Course copyWith({int? id, String? title, String? body, int? userId}) =>
      Course(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
      );
}