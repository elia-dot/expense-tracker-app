class User {
  String id;
  String email;
  String name;
  bool isPasswordConfirm;
  double monthlyBudget;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isPasswordConfirm,
    required this.monthlyBudget,
  });
}
