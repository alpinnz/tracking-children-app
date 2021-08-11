class User {
  String uid;
  String username;
  String email;
  String role;
  int buildNumber;
  int createdAt;
  int updatedAt;

  User({
    this.uid,
    this.username,
    this.email,
    this.role,
    this.buildNumber,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? null;
    username = json['username'] ?? null;
    email = json['email'] ?? null;
    role = json['role'] ?? null;
    buildNumber = json['build_number'] ?? null;
    createdAt = json['created_at'] ?? null;
    updatedAt = json['updated_at'] ?? null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.uid != null) {
      data['uid'] = this.uid;
    }
    if (this.username != null) {
      data['username'] = this.username;
    }
    if (this.email != null) {
      data['email'] = this.email;
    }
    if (this.role != null) {
      data['role'] = this.role;
    }
    if (this.buildNumber != null) {
      data['build_number'] = this.buildNumber;
    }
    if (this.createdAt != null) {
      data['created_at'] = this.createdAt;
    }

    if (this.updatedAt != null) {
      data['updated_at'] = this.updatedAt;
    }
    return data;
  }
}
