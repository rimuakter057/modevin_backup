class UserModel {
  final int? id;
  final String name;
  final String role; // 'user' or 'admin'
  final String plan; // 'free' or 'paid'
  final String status; // 'active' or 'inactive'

  UserModel({
    this.id,
    required this.name,
    required this.role,
    required this.plan,
    required this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: map['role'] as String,
      plan: map['plan'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'role': role,
      'plan': plan,
      'status': status,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isPaid => plan == 'paid';
  bool get isActive => status == 'active';
}
