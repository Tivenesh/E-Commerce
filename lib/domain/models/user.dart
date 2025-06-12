// lib/domain/models/user.dart
class User {
  final String id;
  String fullName;
  String email;
  String dateOfBirth;
  String gender;
  String phoneNumber;
  String? profileImage;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
    this.profileImage,
  });

  // Create a sample user for demo purposes
  static User sampleUser() {
    return User(
      id: 'user123',
      fullName: 'Cody Fisher',
      email: 'cody.fisher45@example.com',
      dateOfBirth: '12/07/1990',
      gender: 'Male',
      phoneNumber: '+1 234 453 231 506',
    );
  }
}
