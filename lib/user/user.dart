class User {
  String id;
  String email;
  String name;
  bool isPasswordConfirm;
  double monthlyBudget;
  bool allowNotifications;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isPasswordConfirm,
    required this.monthlyBudget,
    required this.allowNotifications,
  });
}
