class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      };
}