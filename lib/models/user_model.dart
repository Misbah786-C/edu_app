import '../enums/app_enums.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final String password; // stored in memory only – never persisted in plain text

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.password,
  });

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender.name,
        // password intentionally excluded from persistence
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        email: map['email'] ?? '',
        gender: Gender.values.firstWhere(
          (g) => g.name == map['gender'],
          orElse: () => Gender.preferNotToSay,
        ),
        password: '', // password not restored from storage
      );
}