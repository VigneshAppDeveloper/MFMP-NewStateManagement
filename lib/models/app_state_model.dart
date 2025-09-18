class AppStateModel {
  final String? token;
  final String? isFirstRegister;
  final String? stateId;
  final String? districtId;

  AppStateModel({
    required this.token,
    required this.isFirstRegister,
    required this.stateId,
    required this.districtId,
  });

  bool get isLoggedIn => token != null && token!.isNotEmpty;
  bool get hasLocationSet => stateId?.isNotEmpty == true && districtId?.isNotEmpty == true;
}
